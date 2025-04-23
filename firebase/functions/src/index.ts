import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createConnectionNotifications } from './notifications';

admin.initializeApp();

// When a mutual melt is detected, create a connection
export const handleMutualMelt = functions.firestore
  .document('meltRequests/{requestId}')
  .onCreate(async (snapshot, context) => {
    const newMeltRequest = snapshot.data();
    const { requesterId, recipientId, isAnonymous, createdAt } = newMeltRequest;

    // Look for a reciprocal melt request (recipient has also requested the requester)
    const reciprocalRequestsQuery = admin.firestore()
      .collection('meltRequests')
      .where('requesterId', '==', recipientId)
      .where('recipientId', '==', requesterId);

    const reciprocalRequests = await reciprocalRequestsQuery.get();

    // If there's a reciprocal request, create a connection
    if (!reciprocalRequests.empty) {
      const reciprocalRequest = reciprocalRequests.docs[0].data();
      
      // Create a new connection document
      const connectionData = {
        users: [requesterId, recipientId],
        connectedOn: admin.firestore.FieldValue.serverTimestamp(),
        status: 'active',
        isAnonymous: isAnonymous || reciprocalRequest.isAnonymous,
        dailyConversations: [],
        unreadCount: 0,
        
        // Store melt request data (from both requests)
        initiatorId: reciprocalRequest.requesterId, // The user who initiated first
        receiverId: requesterId, // The user who completed the connection
        wasAnonymous: isAnonymous || reciprocalRequest.isAnonymous, // Keep anonymity state
        originalRequestTimestamp: reciprocalRequest.createdAt, // When the first request was created
        completedRequestTimestamp: createdAt, // When the connection was completed
      };

      // Create the connection
      await admin.firestore()
        .collection('connections')
        .add(connectionData);

      // Delete both melt requests
      const batch = admin.firestore().batch();
      batch.delete(snapshot.ref); // Delete the current request
      batch.delete(reciprocalRequests.docs[0].ref); // Delete the reciprocal request
      
      await batch.commit();
      
      // Create a notification for both users about the new connection
      await createConnectionNotifications(requesterId, recipientId, connectionData);
    }
  }); 