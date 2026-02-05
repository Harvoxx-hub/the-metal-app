# Analysis: Why "You have a new Melt!" Notification Shows as System Type

## Root Cause

The notification is created by **metal-function** (Firebase Cloud Functions), not metal-BE. It uses a **different schema** than what the Flutter app expects.

---

## 1. Where "You have a new Melt!" Is Created

**File:** `metal-function/functions/controllers/send_notification.js`  
**Trigger:** `onConnectionCreated` (lines 184–233) – fires when a new connection is created in Firestore

```javascript
const notification = {
  recipientIds: [user1, user2],
  title: "You have a new Melt!",
  subTitle: "Check out your new Melt connection now on Metal App!",
  type: "new_connection",  // ← Different from metal-BE's "melted" or "match"
  data: {
    connectionId: context.params.connectionId,
    connectedOn: connection.connectedOn,
    status: connection.status,
    // ❌ No senderId – other user's ID is missing
  },
  // ...
};
```

---

## 2. metal-function Notification Schema (What Gets Stored)

`sendNotification()` in metal-function writes directly to Firestore:

```
users/{recipientId}/notifications/{docId}
```

**Stored document shape:**

| Field | Value |
|-------|--------|
| `title` | "You have a new Melt!" |
| `subTitle` | "Check out your new Melt connection now on Metal App!" |
| `type` | `"new_connection"` |
| `data` | `{ connectionId, connectedOn, status }` |
| `timestamp` | ISO string |
| `isRead` | false |

**Missing fields used by metal-BE schema:**

- `category` → always null
- `content` → not set (uses `subTitle` instead)
- `user` → not set
- `senderId` → not in `data`
- `metadata` → not set

---

## 3. metal-BE Schema (What Flutter Expects)

** metal-BE melt notifications** (melt.service.js, discovery.service.js) use `createNotification()` and `buildNotificationDocument()`:

| Field | Value |
|-------|--------|
| `type` | `"melted"` (from TYPE_ALIASES: match → melted) |
| `category` | `"match"` |
| `user` | `{ id: senderId, username, avatar_url }` |
| `content` | `{ message: body }` |
| `metadata` | `{ connectionId, ... }` |
| `data` includes | `senderId`, `connectionId`, etc. |

---

## 4. Why It Becomes System Type

**Step 1 – metal-BE API** (`normalizeNotificationForResponse`):  
Returns `type: "new_connection"` because that’s what metal-function stored.

**Step 2 – Flutter `NotificationModel.fromJson`:**  
- `rawType = "new_connection"`
- `rawType == 'system'` is false
- `isMeltLike` only runs when `rawType == 'system'`
- `type` stays `"new_connection"`

**Step 3 – Flutter `NotificationType.fromString("new_connection")`:**  
- No `case 'new_connection'` in the switch
- Falls through to `default: return NotificationType.system`

So: **`"new_connection"` is treated as `NotificationType.system` because it is not mapped in `NotificationType.fromString`.**

---

## 5. Summary

| Aspect | metal-function (actual) | metal-BE (expected) |
|--------|-------------------------|---------------------|
| Type | `new_connection` | `melted` |
| Category | not set (null) | `match` |
| Sender/other user | not included | `user.id`, `senderId` |
| Content | `subTitle` | `content.message` |

---

## 6. Fix Options

### Option A: Map `new_connection` to `melted` (Flutter)

Add to `NotificationType.fromString`:

```dart
case 'new_connection':
  return NotificationType.melted;
```

This corrects the type, but navigation to the other user’s profile will still fail because `senderId` / `user` is missing.

### Option B: Update metal-function to use metal-BE schema (recommended)

Change `onConnectionCreated` to store:

- `type: "melted"` (or `"match"` so metal-BE schema maps it)
- `data.senderId` = the other user’s ID (from `connection.users`)
- `user: { id: otherUserId, ... }` if you adopt the full metal-BE structure

### Option C: Extract other user from `connectionId` (backend)

If metal-function keeps its current payload, metal-BE’s `normalizeNotificationForResponse` could resolve the connection, get the other user’s ID, and add `senderId` / `user` for notifications with `type: "new_connection"` and a `connectionId` in `data`.
