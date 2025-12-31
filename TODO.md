# Metal App - TODO List

## 📱 Chat Features

### High Priority
- [x] **Copy Message Text** (`lib/presentation/views/chat/widgets/chat_message_list.dart:396`)
  - ✅ Implement copy to clipboard functionality for text messages
  - ✅ Allow users to copy message content
  - ✅ Only show copy option for text messages (not audio)
  - ✅ Show snackbar feedback when message is copied

- [x] **Photo Upload** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:273`)
  - ✅ Implement photo/image upload functionality in chat
  - ✅ Support image selection from gallery (via ImagePickerUtil)
  - ✅ Handle image compression and upload (via centralized ProfilePhotoViewModel)
  - ✅ Only show upload dialog when user doesn't have profile photo
  - ✅ Show proper loading states and success/error messages
  - ✅ Uses existing centralized flow (ImagePickerUtil + ProfilePhotoViewModel)

- [ ] **Push Notifications** (`metal-BE/src/services/message.service.js:210`)
  - Send push notification to other user when message is sent
  - Implement notification service for real-time alerts

### Medium Priority
- [ ] **Emoji Picker** (`lib/presentation/views/chat/widgets/chat_input.dart:292`)
  - Add emoji picker to chat input
  - Allow users to select and send emojis

- [ ] **Video Call** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:103`)
  - Implement video calling functionality
  - Integrate video call SDK (WebRTC or similar)
  - Handle call UI and state management

- [ ] **Audio Call** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:121`)
  - Implement audio/voice calling functionality
  - Integrate audio call SDK
  - Handle call UI and state management

- [ ] **Clear Chat** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:309`)
  - Implement clear/delete all messages functionality
  - Add confirmation dialog
  - Handle backend deletion

- [ ] **Unblock User** (`lib/presentation/views/chat/widgets/chat_app_bar.dart:343`)
  - Implement unblock functionality
  - Allow users to unblock previously blocked users

### Low Priority
- [ ] **Game Picker** (`lib/presentation/views/chat/widgets/chat_input.dart:365`)
  - Add game picker/selector in chat input
  - Allow users to send game invites or play games together

- [ ] **Melt Action** (`lib/presentation/views/chat/widgets/chat_input.dart:468`)
  - Implement melt action in chat input
  - Handle melt request/response flow

---

## 🔔 Notifications & Navigation

- [ ] **Notification Navigation** (`lib/presentation/views/notification/notification_view.dart:121`)
  - Navigate to notification target (thought, message, etc.)
  - Handle deep linking from notifications
  - Implement proper routing based on notification type

- [ ] **Community Profile Routes** (`lib/core/services/notification_navigation_service.dart:235,243`)
  - Add community profile route when community feature is migrated
  - Handle navigation to community profiles from notifications

- [ ] **Deep Link Auth Check** (`lib/core/services/deep_link_service.dart:241`)
  - Check if user is logged in before handling deep links
  - Redirect to login if not authenticated
  - Preserve deep link intent after login

---

## 🏗️ Architecture Migration

### Clean Architecture Implementation
- [ ] **Routes Re-implementation** (`lib/route/routes.dart:247,252`)
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

- [ ] **Video Verification** (`lib/presentation/views/dashboard/widgets/verification.dialog.dart:4,39`)
  - Re-implement video verification in new architecture
  - Re-implement video verification provider
  - Migrate verification flow to Clean Architecture

- [ ] **User Query Provider** (`lib/presentation/views/spark/widgets/send_spark_dialog.dart:6`)
  - Implement getUsersByQueryProvider in new architecture
  - Support user search functionality
  - Integrate with new architecture pattern

---

## 🔗 Connection Features

- [ ] **Unmelt Functionality** (`lib/presentation/views/connection/widgets/metal_details_tab.dart:278`)
  - Implement unmelt (reveal identity) functionality
  - Allow users to reveal their identity after melting
  - Handle unmelt request/response flow

---

## 🧹 Backend Tasks

- [ ] **User Cleanup Job** (`metal-BE/src/services/user.service.js:529`)
  - Schedule background job for user data cleanup
  - Implement periodic cleanup of inactive users
  - Handle data retention policies

---

## 📊 Priority Summary

### 🔴 High Priority
1. Copy Message Text
2. Photo Upload
3. Push Notifications (Backend)
4. Notification Navigation

### 🟡 Medium Priority
1. Video/Audio Calls
2. Emoji Picker
3. Clear Chat
4. Unblock User

### 🟢 Low Priority
1. Game Picker
2. Architecture Migrations (Ongoing)
3. Deep Link Improvements
4. Unmelt Functionality

---

## 📝 Notes

- Architecture migrations are ongoing and should be prioritized based on feature needs
- Some features may depend on backend API availability
- Consider user feedback when prioritizing features
- Test all features thoroughly before marking as complete

---

**Last Updated:** December 30, 2025

