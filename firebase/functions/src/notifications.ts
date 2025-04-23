// Create connection notifications for both users when a connection is formed
export async function createConnectionNotifications(
  user1Id: string,
  user2Id: string,
  connectionData: any
) {
  try {
    // Get user data to personalize notifications
    const user1Doc = await admin.firestore().collection('users').doc(user1Id).get();
    const user2Doc = await admin.firestore().collection('users').doc(user2Id).get();
    
    if (!user1Doc.exists || !user2Doc.exists) {
      console.error('One or both users do not exist');
      return;
    }
    
    const user1Data = user1Doc.data();
    const user2Data = user2Doc.data();
    
    // Create notification for user1
    const notification1 = {
      recipientIds: [user1Id],
      title: 'New Connection!',
      subTitle: `You've connected with ${user2Data?.displayName || 'a new user'}`,
      type: 'new_connection',
      data: {
        connectionId: connectionData.connectionId, // Include connection ID
        otherUserId: user2Id, // Include other user ID
        status: 'active'
      },
      androidNotification: { priority: 'high' },
      iosNotification: { headers: {} },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    };
    
    // Create notification for user2
    const notification2 = {
      recipientIds: [user2Id],
      title: 'New Connection!',
      subTitle: `You've connected with ${user1Data?.displayName || 'a new user'}`,
      type: 'new_connection',
      data: {
        connectionId: connectionData.connectionId, // Include connection ID
        otherUserId: user1Id, // Include other user ID
        status: 'active'
      },
      androidNotification: { priority: 'high' },
      iosNotification: { headers: {} },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    };
    
    // Create notifications in Firestore
    const batch = admin.firestore().batch();
    const notif1Ref = admin.firestore().collection('notifications').doc();
    const notif2Ref = admin.firestore().collection('notifications').doc();
    
    batch.set(notif1Ref, { ...notification1, id: notif1Ref.id });
    batch.set(notif2Ref, { ...notification2, id: notif2Ref.id });
    
    await batch.commit();
    
    // Also send FCM notifications if tokens exist
    await sendFCMNotification(user1Id, notification1);
    await sendFCMNotification(user2Id, notification2);
    
  } catch (error) {
    console.error('Error creating connection notifications:', error);
  }
} 