# Notification testing guide

This document lists **in-app and push notifications** the Metal app can show, how **QA can trigger** each one, and who receives it. It reflects the **`metal-BE`** `createNotification` flows and the Flutter notification types (`NotificationType` / `PushType`).

## Prerequisites

- **Two test accounts** (User A and User B) with completed profiles, discovery access, and (where needed) an existing **connection** or **meetup**.
- **Push enabled**: device permissions on; in-app **Settings → Notifications** toggles on for the relevant category (matches, messages, reactions, etc.).
- **FCM token registered**: log in on a physical device or emulator with Google Play; token is registered after auth.
- **Meetup reminders** require the **meetup reminder job** to run (scheduled server task), not only UI actions.

## Quick reference: types and how to trigger

| Stored / API `type` | Common FCM `data.type` (push) | How to trigger (tester actions) | Recipient |
|---------------------|-------------------------------|-----------------------------------|-----------|
| `profile_liked` | `profile_liked` | User A opens **Discovery**, **likes** User B’s card (no mutual melt yet). | User B |
| `melted` (from `match`) | `melted` | **Mutual melt**: e.g. both users melt each other, or like flow creates a match (`discovery.service` / `melt.service`). Notification uses alias `match` → stored as `melted`. | Both users (separate notifications) |
| `sparks_sent` (from `spark`) | `sparks_sent` | User A sends **Sparks** to User B (sparks transfer). | User B |
| `referral_joined` (from `referral`) | `referral_joined` | New user signs up with User A’s **referral code**; referral is applied (`referral.service`). | Referrer and new user (two notifications) |
| `unmetal_request` (from `unmetal_requested`) | `unmetal_request` | In an **anonymous** chat connection, User A requests **Unmelt** (reveal identities). | Other user in connection |
| `unmetal_acceptance` (from `unmetal_accepted`) | `unmetal_acceptance` | User B **approves** the unmelt request. | User who requested unmelt |
| `unmetal_requires_more_time` | `unmetal_requires_more_time` | User B **declines** or defers unmelt (requires more time flow). | Requester |
| `message` | `message` | User A sends a **chat message** in an existing connection (`message.service`). | Other user in connection |
| `prompt_reaction` | `prompt_reaction` | User A sends a **prompt reaction / indicated interest** in the messaging flow (`message.service`). | Recipient |
| `direct_message` | `direct_message` | User A sends a **direct message from discovery** (pending DM; no connection until accepted). | Recipient |
| `thought_reaction` | `reaction_added` | User A adds an **emoji reaction** on User B’s **thought** (not on own thought). | Thought owner |
| `thought_comment` | `comment` | User A **comments** on User B’s thought. | Thought owner |
| `thought_repost` | `thought_repost` | User A **reposts** User B’s thought (repost notifies original author). | Original thought author |
| `meetup_invite` | `meetup_invite` | Host (or allowed user) **invites** another user to a meetup by username. | Invited user |
| `meetup_reminder` | `meetup_reminder` | **Scheduled job** sends reminders to **accepted** attendees (`meetup-reminder.service.js`). | Accepted attendees |
| `meetup_rsvp_update` | `meetup_rsvp_update` | Someone **accepts** RSVP to creator’s meetup (not the creator themselves). | Meetup creator |
| `meetup_rsvp_declined` | `meetup_rsvp_declined` | Someone **declines** RSVP to creator’s meetup. | Meetup creator |
| `meetup_created` | `meetup_created` | Host uses **broadcast meetup** to nearby/community members (`meetup.service` broadcast). | Users in broadcast audience |

## Notes for testers

### Push vs in-app list

- **Push** (lock screen / tray): FCM payload includes string `type` (see **FCM `data.type`** column). All values are sent as **strings** in `data`.
- **In-app list**: **Profile → Notifications** loads the same notification documents from the API. Tapping a row uses `NotificationType`; behavior may differ slightly from tray (e.g. **direct message** may show accept/reject sheet).

### Types defined in the app but not created in current `metal-BE` `createNotification` scan

The Flutter app also recognizes these strings; they may come from **older data**, **admin tools**, or **future/backend updates**:

- `thought_created`
- `community_post`
- `meetup_capacity_reached`
- `thought_reminder` (often used for **“post a thought”** style prompts; may be Remote Config / in-app dialog rather than this API)
- Generic `system` (fallback when `type` is unknown)

If QA needs these, confirm with engineering whether the backend or a job emits them.

### Melt request (`melt_request`)

The schema supports **`melt_request`** notifications, but **`melt.service.js`** explicitly does **not** send a push when only a **pending melt request** is created; recipients discover pending melts in the app UI. Do not expect a notification for “incoming melt request only.”

### Duplicates and settings

- **Match** notifications may be **deduped** for a short window if the same `connectionId` would notify twice (`notification.service.js`).
- If **push doesn’t arrive**, check **notification settings** for that category and that the user document has a valid **`fcmToken`**.

### Meetup reminders

To test **meetup_reminder**, you need a meetup with **accepted** RSVPs and the **reminder cron/job** to have run for the configured intervals (see `meetup-reminder.service.js`). Manual UI action alone may not fire it without the job.

## Suggested test matrix (smoke)

1. **Like** → B receives `profile_liked`; tap opens sender profile (tray + in-app).
2. **Mutual match / melt** → both receive `melted`; tap goes to profile or chat per payload.
3. **Chat message** → `message` with `connectionId`; tap opens **that** chat when `connectionId` is present.
4. **Prompt reaction** → `prompt_reaction` with `connectionId`; tap opens chat.
5. **Direct message** → `direct_message`; tap may show **accept/reject** before chat.
6. **Thought reaction / comment / repost** → opens **thought detail** with correct `thoughtId`.
7. **Unmelt request / accept / more time** → opens chat when `connectionId` is present.
8. **Sparks** → opens sparks area.
9. **Referral** → opens refer-earn / home per navigation rules.
10. **Meetup invite / RSVP / broadcast** → opens meetup detail when `meetupId` is present.

## Reference: backend files

| File | Role |
|------|------|
| `src/services/notification.service.js` | Creates Firestore notification + FCM push; `mapDocTypeToFcmPushType` for thought reactions/comments |
| `src/constants/notificationSchema.js` | `NOTIFICATION_TYPES`, `TYPE_ALIASES` (`like` → `profile_liked`, `match` → `melted`, etc.) |
| `src/services/discovery.service.js` | Like + match notifications |
| `src/services/melt.service.js` | Match (mutual) notifications only (no push for one-way melt request) |
| `src/services/message.service.js` | `message`, `prompt_reaction`, `direct_message` |
| `src/services/thought.service.js` | `thought_reaction`, `thought_comment`, `thought_repost` |
| `src/services/connection.service.js` | `unmetal_requested` → `unmetal_request`, `unmetal_accepted`, `unmetal_requires_more_time` |
| `src/services/sparks.service.js` | `spark` → `sparks_sent` |
| `src/services/referral.service.js` | `referral` → `referral_joined` |
| `src/services/meetup.service.js` | Meetup invite, RSVP, broadcast `meetup_created` |
| `src/services/meetup-reminder.service.js` | `meetup_reminder` |

## Flutter reference

- Push routing: `lib/core/services/notification_navigation_service.dart` (`navigateFromPayload` / `navigateFromNotification`).
- Push type strings: `lib/fcm/models/push_type.dart`.
- In-app models: `lib/domain/entities/notification_dto.dart` (`NotificationType`).

---

*Last updated from codebase review; align with deployed API if behaviors differ per environment.*
