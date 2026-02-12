# Metal App - Complete TODO List Summary

## 📱 Chat Features

### High Priority
- [x] **Push Notifications** (`metal-BE/src/services/message.service.js:218-230`)
  - ✅ Send push notification to other user when message is sent
  - ✅ Implemented via `createNotification()` which calls `sendPushNotification()` internally
  - ✅ Respects user notification settings
  - ✅ Handles FCM token validation and cleanup

### Medium Priority
- [x] **Emoji Picker** (`lib/presentation/views/chat/widgets/chat_input.dart:285-520`)
  - ✅ Added emoji picker widget to chat input
  - ✅ Toggle emoji picker visibility on button tap
  - ✅ Insert emoji at cursor position in text field
  - ✅ Hide keyboard when emoji picker is shown
  - ✅ Hide emoji picker when text field is tapped
  - ✅ Visual feedback: emoji button changes color when picker is visible

- [ ] **Video Call** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:113`)
  - Implement video calling functionality
  - Integrate video call SDK (WebRTC or similar)
  - Handle call UI and state management

- [ ] **Audio Call** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:131`)
  - Implement audio/voice calling functionality
  - Integrate audio call SDK
  - Handle call UI and state management

- [x] **Clear Chat** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:433-451`)
  - ✅ Implemented clear/delete all messages functionality
  - ✅ Confirmation dialog already present (shows before clearing)
  - ✅ Handles backend deletion via chat repository
  - ✅ Refreshes chat messages after clearing

- [x] **Unblock User** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:470-493`)
  - ✅ Implemented unblock functionality
  - ✅ Uses profile repository to unblock user
  - ✅ Confirmation dialog already present
  - ✅ Refreshes chat list after unblocking
  - ✅ Navigates back after successful unblock

### Low Priority
- [ ] **Game Picker** (`lib/presentation/views/chat/widgets/chat_input.dart:364`)
  - Add game picker/selector in chat input
  - Allow users to send game invites or play games together



## 🔔 Notifications & Navigation
- [ ] **Melt Action** (`lib/presentation/views/chat/widgets/chat_input.dart:467`)
  - Implement melt action in chat input
  - Handle melt request/response flow

---
- [ ] **Notification Navigation** (`lib/presentation/views/notification/notification_view.dart:121`)
  - Navigate to notification target (thought, message, etc.)
  - Handle deep linking from notifications
  - Implement proper routing based on notification type

- [ ] **Community Profile Routes** (`lib/core/services/notification_navigation_service.dart:235,243`)
  - Add community profile route when community feature is migrated
  - Handle navigation to community profiles from notifications

- [ ] **Deep Link Auth Check** (`lib/core/services/deep_link_service.dart:265`)
  - Check if user is logged in before handling deep links
  - Redirect to login if not authenticated
  - Preserve deep link intent after login

---

## 🏗️ Architecture Migration

### Clean Architecture Implementation
- [ ] **Routes Re-implementation** (`lib/route/routes.dart:282`)
  - Re-implement routes in Clean Architecture
  - Re-implement postThought and thoughtDetails in new architecture
  - Migrate all routes to new architecture pattern

- [ ] **User Fetching** (`lib/presentation/views/connection/connection_detail_screen.dart:12,76`)
  - Re-implement user fetching in new architecture (GET /api/v1/users/{userId})
  - Get user data using new architecture
  - Replace temporary placeholders with proper implementation

- [ ] **User-Specific Thought Tab** (`lib/presentation/views/connection/connection_detail_screen.dart:16,156`)
  - Re-implement user-specific thought tab in new architecture
  - Implement user-specific thought feed
  - Load thoughts for specific user profile

 

---

## 🔗 Connection Features

- [ ] **Unmelt Functionality** (`lib/presentation/views/connection/widgets/metal_details_tab.dart:278`)
  - Implement unmelt (reveal identity) functionality
  - Allow users to reveal their identity after melting
  - Handle unmelt request/response flow

---

## 📅 Meetup Features

- [ ] **Edit Meetup Screen** (`lib/presentation/views/meetup/meetup_detail_view.dart:104`)
  - Navigate to edit screen for meetups
  - Allow users to edit their created meetups

- [ ] **Community Multi-Select Dialog** (`lib/presentation/views/meetup/create_meetup_screen.dart:95`)
  - Implement community multi-select dialog
  - Allow users to select multiple communities for meetup

---

## 🔧 Infrastructure & Services

- [x] **FCM Token Update** (`lib/fcm/fcm_client.dart:183-252`)
  - ✅ Implemented token storage and registration via notification repository
  - ✅ Added `registerTokenWithBackend()` method to register after authentication
  - ✅ Token refresh stores new token for later registration
  - ✅ Fixed API request format to match backend expectations (deviceToken, platform, appVersion)
  - ✅ Updated notification repository and data source interfaces

- [x] **Android Push Model** (`lib/fcm/models/android_push_model.dart`)
  - ✅ Removed TODO comment
  - ✅ Model structure is complete and functional

- [x] **iOS Push Model** (`lib/fcm/models/ios_push_model.dart`)
  - ✅ Removed TODO comment
  - ✅ Model structure is complete and functional

---

## 🧹 Backend Tasks

- [ ] **User Cleanup Job** (`metal-BE/src/services/user.service.js:529`)
  - Schedule background job for user data cleanup
  - Implement periodic cleanup of inactive users
  - Handle data retention policies

---

## 🎨 UI/Styling

- [x] **Remove Starter Styles** (`lib/res/style/cr_style.dart:361`)
  - Remove starter default styles
  - Clean up unused style definitions

---

## 📊 Priority Summary

### 🔴 High Priority (4 items)
1. Push Notifications (Backend)
2. Notification Navigation
3. Deep Link Auth Check
4. User Query Provider (Architecture Migration)

### 🟡 Medium Priority (7 items)
1. Video Call
2. Audio Call
3. Emoji Picker
4. Clear Chat
5. Unblock User
6. Edit Meetup Screen
7. Community Multi-Select Dialog

### 🟢 Low Priority (8 items)
1. Game Picker
2. Melt Action
3. Unmelt Functionality
4. FCM Token Update
5. Android/iOS Push Models
6. Remove Starter Styles
7. Routes Re-implementation (Architecture)
8. User Fetching (Architecture)

---

## 📝 Notes

- Architecture migrations are ongoing and should be prioritized based on feature needs
- Some features may depend on backend API availability
- Consider user feedback when prioritizing features
- Test all features thoroughly before marking as complete
- Total TODO items: **19 unique tasks**

---

**Last Updated:** January 2025
**Total TODOs Found:** 19 items (excluding completed tasks)
