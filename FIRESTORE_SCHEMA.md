# Metal App – Firestore Database Schema

## 📁 Collection Overview

```
Firestore Root
├── users
├── metals
├── feedback
├── meltRequests
├── connections
├── thoughts
├── sparksTransactions
├── communities
├── communityMembers (subcollection under communities)
├── communityPosts (subcollection under communities)
├── notifications (subcollection under users)
├── blocked (subcollection under users)
├── swipes (subcollection under users)
├── messages (subcollection under connections)
├── blockReasons
└── reports
```

---

## 1. 👥 USERS Collection
**Path:** `/users/{userId}`

```json
{
  "id": "string",
  "username": "string",
  "fullname": "string",
  "email": "string",
  "emailVerified": "boolean",
  "workEmail": "string?",
  "workEmailVerified": "boolean?",
  "phone": "string",
  "dob": "string",
  "gender": "string",
  "description": "string?",
  "profilePhoto": "string?",
  "profileUpdated": "boolean?",
  "completedProfile": "boolean?",
  "isVerified": "boolean?",
  "isActivated": "boolean?",
  "metal": "string",
  "passion": ["string"],
  "connectWith": "string?",
  "connectionOption": ["string"],
  "address": {
    "street": "string?",
    "city": "string?",
    "state": "string?",
    "country": "string?",
    "zipCode": "string?"
  },
  "location": {
    "latitude": "number?",
    "longitude": "number?",
    "address": "string?"
  },
  "distance": "string?",
  "preferences": {
    "ageRange": "string?",
    "demography": "string?",
    "education": "string?",
    "ethnicity": "string?",
    "religion": "string?"
  },
  "extraData": {
    "profession": "string?",
    "education": "string?",
    "religion": "string?",
    "ethnicity": "string?",
    "language": "string?",
    "marriageStatus": "string?"
  },
  "showOnline": "boolean",
  "alwaysMetal": "boolean",
  "receiveNotification": "boolean",
  "showMyProfile": "boolean",
  "activateVoiceNote": "boolean",
  "activateVoiceCall": "boolean",
  "activateVideoCall": "boolean",
  "isOnline": "boolean",
  "lastActive": "string?",
  "fcmToken": "string?",
  "subscription": {
    "id": "string",
    "planName": "string",
    "duration": "number",
    "price": "number",
    "metaData": ["string"],
    "startingDate": "number",
    "endingDate": "number"
  },
  "sparkBalance": "number",
  "referralCode": "string?",
  "referredBy": "string?",
  "refreshToken": "string?",
  "appVersion": "string?",
  "createdAt": "string",
  "updatedAt": "string"
}
```

---

## 2. 🔗 CONNECTIONS Collection
**Path:** `/connections/{connectionId}`

```json
{
  "connectionId": "string",
  "users": ["string"],
  "connectedOn": "string",
  "status": "string",
  "lastMessage": "string?",
  "lastUpdatedAt": "string?",
  "lastSenderId": "string?",
  "unreadCount": "number",
  "isAnonymous": "boolean",
  "game": "string?",
  "dailyConversations": ["string"],
  "lastConversationDate": "string?",
  "initiatorId": "string?",
  "receiverId": "string?",
  "wasAnonymous": "boolean",
  "otherUser": "UserModel?"
}
```

---

## 3. 🗨️ THOUGHTS Collection
**Path:** `/thoughts/{thoughtId}`

```json
{
  "id": "string",
  "userId": "string",
  "content": "string", // For voice thoughts, this is the optional caption
  "type": "string", // "text" | "voice" | "repost" (default: "text")
  "audioUrl": "string?", // Present when type = "voice"
  "audioDuration": "number?", // Duration in seconds when type = "voice"
  "createdAt": "string",
  "connectionOnly": "boolean",
  // Repost-specific fields (present when type = "repost")
  "originalThoughtId": "string?",
  "originalUserId": "string?",
  "repostedAt": "string?",
  "authorMetadata": {
    "authorId": "string",
    "authorName": "string?",
    "authorGender": "string?",
    "authorAge": "number?",
    "authorLocationName": "string?",
    "authorLatitude": "number?",
    "authorLongitude": "number?",
    "authorRelationshipType": "string?",
    "authorCommunity": "string?",
    "authorIsVerified": "boolean?",
    "authorProfilePhoto": "string?"
  },
  "communityMetadata": {
    "communityId": "string",
    "communityName": "string",
    "categories": ["string"],
    "communityImage": "string?",
    "isPublic": "boolean"
  }
}
```

### ➡️ Reactions Subcollection
**Path:** `/thoughts/{thoughtId}/reactions/{reactionId}`

```json
{
  "id": "string",
  "userId": "string",
  "thoughtId": "string",
  "emoji": "string",
  "createdAt": "string"
}
```

### ➡️ Comments Subcollection
**Path:** `/thoughts/{thoughtId}/comments/{commentId}`

```json
{
  "id": "string",
  "userId": "string",
  "thoughtId": "string",
  "content": "string",
  "createdAt": "string",
  "reactions": [
    { "userId": "string", "emoji": "string" }
  ],
  "replyToCommentId": "string?",
  "replyToUserId": "string?",
  "replyToContent": "string?",
  "replyLevel": "number",
  "isDeleted": "boolean"
}
```

**Reply Structure:**
- `replyToCommentId`: ID of the comment being replied to (null for top-level comments)
- `replyToUserId`: ID of the user who wrote the original comment
- `replyToContent`: Truncated preview of the original comment content
- `replyLevel`: Depth level (0 = top-level comment, 1 = reply to comment, 2 = reply to reply)
- `isDeleted`: Soft delete flag for removed comments

---

## 4. 🔄 MELT REQUESTS Collection
**Path:** `/meltRequests/{requestId}`

```json
{
  "requesterId": "string",
  "recipientId": "string",
  "senderId": "string",
  "isAnonymous": "boolean",
  "createdAt": "string",
  "status": "string"
}
```

---

## 5. ⚡ SPARKS TRANSACTIONS Collection
**Path:** `/sparksTransactions/{transactionId}`

```json
{
  "type": "string",
  "sparks": "number",
  "amount": "string?",
  "userId": "string",
  "timestamp": "string",
  "receiverId": "string?",
  "receiverName": "string?",
  "senderName": "string?",
  "referredUserId": "string?",
  "referredName": "string?",
  "referrerId": "string?",
  "referrerName": "string?"
}
```

---

## 6. 🔒 BLOCKED Subcollection
**Path:** `/users/{userId}/blocked/{blockedUserId}`

```json
{
  "id": "string",
  "name": "string",
  "blockedAt": "string",
  "isTemporary": "boolean?",
  "expiryDate": "string?",
  "privacySettings": {
    "hideProfile": "boolean?",
    "blockMessages": "boolean?",
    "blockCalls": "boolean?"
  },
  "updatedAt": "string?"
}
```

---

## 7. 👆 SWIPES Subcollection
**Path:** `/users/{userId}/swipes/{swipeId}`

```json
{
  "targetUserId": "string",
  "action": "string",
  "timestamp": "string",
  "createdAt": "string"
}
```

**Action Types:**
- `"like"` - User liked the target user
- `"pass"` - User passed on the target user  
- `"superLike"` - User super liked the target user

---

## 8. 📢 NOTIFICATIONS Subcollection
**Path:** `/users/{userId}/notifications/{notificationId}`

```json
{
  "recipientIds": ["string"],
  "title": "string",
  "subTitle": "string",
  "type": "string",
  "data": "object",
  "timestamp": "string",
  "isRead": "boolean",
  "androidNotification": { "priority": "string" },
  "iosNotification": { "headers": "object" }
}
```

---

## 9. 💬 MESSAGES Subcollection
**Path:** `/connections/{connectionId}/messages/{messageId}`

```json
{
  "id": "string?",
  "message": "string",
  "senderId": "string",
  "type": "string",
  "content": "string?",
  "timestamp": "string",
  "isRead": "boolean",
  "replyToMessageId": "string?",
  "replyToMessageText": "string?",
  "replyToSenderId": "string?",
  "replyToMessageType": "string?"
}
```

**Reply Fields:**
- `replyToMessageId`: ID of the message being replied to (null for regular messages)
- `replyToMessageText`: Truncated preview text of the original message
- `replyToSenderId`: ID of the original message sender
- `replyToMessageType`: Type of the original message (text, audio, calls, un_melt)

---

## 10. 🎭 METALS Collection
**Path:** `/metals/{metalId}`

```json
{
  "id": "string?",
  "title": "string",
  "desc": "string",
  "img": "string"
}
```

---

## 11. 📝 FEEDBACK Collection
**Path:** `/feedback/{feedbackId}`

```json
{
  "userId": "string",
  "content": "string",
  "timestamp": "string",
  "status": "string?"
}
```

---

## 12. 🚫 BLOCK REASONS Collection
**Path:** `/blockReasons/{reasonId}`

```json
{
  "id": "string",
  "userId": "string",
  "blockedUserId": "string",
  "reasonCode": "string",
  "customReason": "string?",
  "isReported": "boolean",
  "reportDetails": "string?",
  "timestamp": "string"
}
```

---

## 13. 🏴 REPORTS Collection
**Path:** `/reports/{reportId}`

```json
{
  "id": "string",
  "reporterId": "string",
  "reportedUserId": "string",
  "reasonCode": "string",
  "customReason": "string?",
  "reportDetails": "string",
  "status": "string",
  "timestamp": "string"
}
```

---

## 14. 🏘️ COMMUNITIES Collection
**Path:** `/communities/{communityId}`

```json
{
  "id": "string",
  "name": "string",
  "nameLower": "string", // lowercase of name for case-insensitive search
  "description": "string",
  "bannerImage": "string?",
  "creatorId": "string",
  "creatorName": "string",
  "memberCount": "number",
  "isPublic": "boolean",
  "tags": ["string"],
  "createdAt": "string",
  "updatedAt": "string",
  "rules": "string?"
}
```

### ➡️ Community Members Subcollection
**Path:** `/communities/{communityId}/members/{memberId}`

```json
{
  "id": "string",
  "userId": "string",
  "userName": "string",
  "userPhoto": "string?",
  "role": "string",
  "joinedAt": "string",
  "isActive": "boolean"
}
```

**Role Types:**
- `"creator"` - Community creator
- `"admin"` - Community administrator
- `"member"` - Regular community member

### ➡️ Community Posts Subcollection
**Path:** `/communities/{communityId}/posts/{postId}`

```json
{
  "id": "string",
  "communityId": "string",
  "authorId": "string",
  "authorName": "string",
  "authorPhoto": "string?",
  "content": "string",
  "imageUrl": "string?",
  "createdAt": "string",
  "updatedAt": "string",
  "likeCount": "number",
  "commentCount": "number",
  "isEdited": "boolean"
}
```

### ➡️ Post Reactions Subcollection
**Path:** `/communities/{communityId}/posts/{postId}/reactions/{reactionId}`

```json
{
  "id": "string",
  "userId": "string",
  "postId": "string",
  "emoji": "string",
  "createdAt": "string"
}
```

### ➡️ Post Comments Subcollection
**Path:** `/communities/{communityId}/posts/{postId}/comments/{commentId}`

```json
{
  "id": "string",
  "postId": "string",
  "authorId": "string",
  "authorName": "string",
  "authorPhoto": "string?",
  "content": "string",
  "createdAt": "string",
  "updatedAt": "string",
  "likeCount": "number",
  "replyToCommentId": "string?",
  "replyToUserId": "string?",
  "replyToContent": "string?",
  "replyLevel": "number",
  "isDeleted": "boolean"
}
```

---

## 🔗 Key Relationships

- **Users ↔ Connections:** Many-to-many through `connections.users` array
- **Users ↔ Thoughts:** One-to-many (`thoughts.userId`)
- **Users ↔ Sparks:** One-to-many (`sparksTransactions.userId`)
- **Users ↔ Communities:** Many-to-many through `communityMembers` subcollection
- **Communities ↔ Posts:** One-to-many (subcollection)
- **Communities ↔ Members:** One-to-many (subcollection)
- **Posts ↔ Reactions:** One-to-many (subcollection)
- **Posts ↔ Comments:** One-to-many (subcollection)
- **Connections ↔ Messages:** One-to-many (subcollection)
- **Users ↔ Notifications:** One-to-many (subcollection)
- **Users ↔ Blocked:** One-to-many (subcollection)
- **Users ↔ MeltRequests:** Many-to-many (`meltRequests.requesterId/recipientId`)

---

## 📊 Data Types Legend

- `"string"` – Text field
- `"number"` – Numeric field
- `"boolean"` – True/false field
- `["type"]` – Array of specified type
- `"object"` – Nested object/map
- `"type?"` – Optional field
- `= value` – Default value 