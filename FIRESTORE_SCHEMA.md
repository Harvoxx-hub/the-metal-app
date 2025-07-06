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
├── notifications (subcollection under users)
├── blocked (subcollection under users)
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
  "content": "string",
  "createdAt": "string",
  "connectionOnly": "boolean"
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
  ]
}
```

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

## 7. 📢 NOTIFICATIONS Subcollection
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

## 8. 💬 MESSAGES Subcollection
**Path:** `/connections/{connectionId}/messages/{messageId}`

```json
{
  "id": "string?",
  "message": "string",
  "senderId": "string",
  "type": "string",
  "content": "string?",
  "timestamp": "string",
  "isRead": "boolean"
}
```

---

## 9. 🎭 METALS Collection
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

## 10. 📝 FEEDBACK Collection
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

## 11. 🚫 BLOCK REASONS Collection
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

## 12. 🏴 REPORTS Collection
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

## 🔗 Key Relationships

- **Users ↔ Connections:** Many-to-many through `connections.users` array
- **Users ↔ Thoughts:** One-to-many (`thoughts.userId`)
- **Users ↔ Sparks:** One-to-many (`sparksTransactions.userId`)
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