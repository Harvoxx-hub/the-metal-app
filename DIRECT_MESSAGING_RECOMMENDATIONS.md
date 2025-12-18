# Direct Messaging Feature - Implementation Recommendations

## 📋 Overview

This document outlines recommendations for implementing the ability to send direct messages without requiring mutual melting first. The recipient will need to melt back before they can reply.

## 🔍 Current System Analysis

### Existing Infrastructure
- **Connection Model** already supports `meltStatus` field:
  - `'mutual'` - Both users have melted (full chat access)
  - `'pending'` - One-way connection (sender can message, recipient cannot reply)
- **MessageRepository** has `createOrGetConnectionForDirectMessage()` method that:
  - Creates connection with `meltStatus: 'pending'`
  - Creates a melt request automatically
- **Connection creation** happens via Cloud Function trigger when mutual melt requests exist

### Current Flow
1. User A sends melt request to User B
2. User B sends melt request to User A
3. Cloud Function detects mutual requests → creates connection with `meltStatus: 'mutual'`
4. Both users can now chat freely

---

## 🎯 Recommended Approach: **Option 1 - Leverage Existing Infrastructure** ⭐ (RECOMMENDED)

### Why This Approach?
- ✅ **Minimal code changes** - infrastructure already exists
- ✅ **Consistent data model** - uses existing `meltStatus` field
- ✅ **Reuses existing melt request system**
- ✅ **Easiest to implement and maintain**

### Implementation Flow

#### **Step 1: Message Sending (Sender Side)**
When User A sends a message to User B (without existing connection):

1. **Check for existing connection**
   - If connection exists → use it
   - If not → proceed to create

2. **Create connection with pending status**
   ```dart
   // Already exists in MessageRepository.createOrGetConnectionForDirectMessage()
   - Create connection with meltStatus: 'pending'
   - Set initiatorId: senderId
   - Set receiverId: recipientId
   - Create melt request from sender to recipient
   ```

3. **Allow sender to send messages**
   - Sender can send unlimited messages
   - Messages stored normally in `connections/{connectionId}/messages`

#### **Step 2: Message Receiving (Recipient Side)**
When User B receives a message from User A (pending connection):

1. **Show connection in chat list**
   - Display connection with special indicator (e.g., badge, different styling)
   - Show "Melt to reply" or "Not melted yet" indicator

2. **Display messages**
   - Recipient can **view** all messages from sender
   - Recipient **cannot send** messages (UI blocked)

3. **UI Indication**
   - Chat input field disabled with message: "Melt with [Name] to reply"
   - Banner/header showing: "You haven't melted with this user yet"
   - Button to "Melt & Reply" that triggers melt action

#### **Step 3: Recipient Melts Back**
When User B melts with User A:

1. **Melt request created** (existing flow)
2. **Cloud Function detects mutual requests**
3. **Connection updated**: `meltStatus: 'pending'` → `meltStatus: 'mutual'`
4. **UI unlocks**: Recipient can now send messages

---

## 🏗️ Implementation Details

### 1. **UI Changes Required**

#### A. Chat List (`chat.list.dart`)
- Add visual indicator for pending connections
- Show badge/icon for "pending melt" status
- Different styling (e.g., grayed out or border color)

#### B. Chat Window (`chat.window.dart`)
- Check `connection.meltStatus` before rendering input
- If `meltStatus == 'pending'` and current user is receiver:
  - Disable message input
  - Show banner: "Melt with [Name] to reply"
  - Show "Melt & Reply" button

#### C. Chat Input (`chat.input.sheet.dart`)
- Add check: `if (connection.isMeltPending && isReceiver) { disable input }`
- Show helpful message instead of input field

#### D. Side Card (New Feature)
- Add "Message" button on user profile cards
- On tap: Navigate to chat window
- If no connection exists, create one with pending status

### 2. **Backend Changes Required**

#### A. Message Sending Logic
**File:** `lib/features/chat/data/repositories/message.repository.dart`

```dart
Future<Responses> sendMessage({
  required MessageModel message,
  required String conversationsId,
}) async {
  // Get connection to check meltStatus
  final connectionDoc = await _firestore
      .collection(FirebaseFirestoreCollectionKeys.connections)
      .doc(conversationsId)
      .get();
  
  if (connectionDoc.exists) {
    final data = connectionDoc.data()!;
    final meltStatus = data['meltStatus'] ?? 'mutual';
    final receiverId = data['receiverId'];
    
    // If pending and current user is receiver, block sending
    if (meltStatus == 'pending' && message.senderId == receiverId) {
      return Responses(
        success: false,
        message: "You need to melt with this user first to reply",
      );
    }
  }
  
  // Continue with normal message sending...
}
```

#### B. Connection Creation for Direct Message
**Already exists** in `createOrGetConnectionForDirectMessage()` - just need to ensure it's called from side card.

#### C. Cloud Function (No changes needed)
The existing `connectionTriggers.js` already handles:
- Detecting mutual melt requests
- Updating `meltStatus` to 'mutual'
- This will work automatically when recipient melts

### 3. **Data Model Updates**

#### Connection Model
**File:** `lib/features/thought/data/domain/entries/connection.model.dart`

Already has:
- ✅ `meltStatus` field
- ✅ `isMeltPending` getter
- ✅ `isMutualMelt` getter

**No changes needed** - model is ready!

### 4. **Helper Methods Needed**

#### A. Check if user can send message
```dart
bool canSendMessage(ConnectionModel connection, String currentUserId) {
  if (connection.isMutualMelt) return true;
  if (connection.isMeltPending) {
    // Only initiator can send when pending
    return connection.initiatorId == currentUserId;
  }
  return false;
}
```

#### B. Check if user is receiver in pending connection
```dart
bool isReceiverInPendingConnection(ConnectionModel connection, String currentUserId) {
  return connection.isMeltPending && 
         connection.receiverId == currentUserId;
}
```

---

## 🎨 UI/UX Recommendations

### Visual Indicators

1. **Chat List Item (Pending Connection)**
   - Badge: "Melt to reply" or icon indicator
   - Slightly grayed out or different border color
   - Show unread count normally

2. **Chat Window Header**
   - Banner above messages: "You haven't melted with [Name] yet"
   - Styled differently (e.g., pink/amber background)

3. **Message Input Area**
   - Disabled input field
   - Placeholder: "Melt with [Name] to reply"
   - Large "Melt & Reply" button (primary action)
   - Button navigates to melt screen or triggers melt directly

4. **Message Bubbles**
   - Display normally (recipient can read all messages)
   - No special styling needed

### User Flow

**Scenario 1: User A messages User B (new)**
1. User A clicks "Message" on User B's profile
2. Connection created with `meltStatus: 'pending'`
3. User A can immediately send messages
4. User B receives notification
5. User B opens chat → sees messages but cannot reply
6. User B sees "Melt & Reply" button
7. User B clicks → melts with User A
8. Connection updates to `meltStatus: 'mutual'`
9. User B can now reply

**Scenario 2: User A messages User B (existing pending)**
1. User A sends another message
2. Connection already exists with `meltStatus: 'pending'`
3. Message stored normally
4. User B still cannot reply until melting

---

## ⚠️ Alternative Approaches (Not Recommended)

### Option 2: Separate "Pending Messages" Collection
- ❌ More complex data model
- ❌ Requires migration logic
- ❌ Duplicates existing infrastructure
- ❌ More code to maintain

### Option 3: Message-Level Permissions
- ❌ More granular than needed
- ❌ Complex permission checks
- ❌ Performance overhead

---

## 📝 Implementation Checklist

### Phase 1: Backend Logic
- [ ] Update `sendMessage()` to check `meltStatus` and block receiver
- [ ] Ensure `createOrGetConnectionForDirectMessage()` is accessible
- [ ] Add helper methods: `canSendMessage()`, `isReceiverInPendingConnection()`
- [ ] Test connection creation with pending status

### Phase 2: UI Updates
- [ ] Update chat list to show pending indicator
- [ ] Update chat window to disable input for receivers
- [ ] Add "Melt & Reply" button/action
- [ ] Add banner/header for pending connections
- [ ] Update chat input to show disabled state

### Phase 3: Side Card Integration
- [ ] Add "Message" button to user profile cards
- [ ] Implement navigation to chat with connection creation
- [ ] Handle edge cases (existing connections, etc.)

### Phase 4: Testing
- [ ] Test sender can send messages in pending connection
- [ ] Test receiver cannot send messages
- [ ] Test receiver can view messages
- [ ] Test melt action unlocks chat
- [ ] Test existing mutual connections still work
- [ ] Test notifications for pending messages

---

## 🚀 Quick Start Implementation

### Step 1: Add Helper Method
Add to `ConnectionModel` or create utility:

```dart
extension ConnectionModelExtension on ConnectionModel {
  bool canUserSendMessage(String userId) {
    if (isMutualMelt) return true;
    if (isMeltPending) {
      return initiatorId == userId; // Only initiator can send
    }
    return false;
  }
  
  bool isUserReceiver(String userId) {
    return isMeltPending && receiverId == userId;
  }
}
```

### Step 2: Update Message Sending
In `MessageRepository.sendMessage()`:

```dart
// After getting connectionDoc
final connection = ConnectionModel.fromJson(connectionDoc.data()!);
if (!connection.canUserSendMessage(message.senderId)) {
  return Responses(
    success: false,
    message: "You need to melt with this user first to reply",
  );
}
```

### Step 3: Update Chat Input
In `ChatBottomSheet` or `ChatInputSheet`:

```dart
final canSend = connection.canUserSendMessage(currentUserId);
if (!canSend && connection.isUserReceiver(currentUserId)) {
  // Show "Melt & Reply" button instead of input
  return _buildMeltToReplyButton();
}
// Normal input
```

---

## 📊 Summary

**Recommended Approach:** Option 1 - Leverage Existing Infrastructure

**Key Benefits:**
- ✅ Minimal code changes
- ✅ Reuses existing `meltStatus` field
- ✅ Consistent with current architecture
- ✅ Easy to maintain and extend

**Estimated Implementation Time:**
- Backend logic: 2-3 hours
- UI updates: 4-6 hours
- Testing & polish: 2-3 hours
- **Total: ~8-12 hours**

**Risk Level:** Low (existing infrastructure supports this)

---

## ❓ Questions to Consider

1. **Notifications:** Should pending messages trigger notifications? (Recommended: Yes)
2. **Message Limits:** Should there be a limit on messages sender can send before recipient melts? (Recommended: No limit)
3. **Auto-melt:** Should we offer "Quick Melt" button that melts and sends message in one action? (Recommended: Yes, for better UX)
4. **Connection List:** Should pending connections appear in main chat list or separate section? (Recommended: Same list with indicator)

---

## ✅ Approval Needed

Please review and approve this approach before implementation. If approved, we'll proceed with the implementation following this plan.



