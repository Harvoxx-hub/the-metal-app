# Metal App - Feature Migration Tasks

> **Migration Goal**: Migrate all features from old `features/` structure to new Clean Architecture in `presentation/views/`

## Migration Principles

Before migrating ANY feature:
1. **Understand the context** - What is this feature supposed to do?
2. **Identify flaws** - Don't copy redundant or flawed logic
3. **Design for new architecture** - Views call UserStateNotifier (single source of truth)
4. **No API calls in ViewModels** - ViewModels manage UI state only

---

## ✅ Completed Migrations

| Feature | New Location | Date |
|---------|--------------|------|
| Authentication (Login/Signup) | `presentation/views/auth/` | ✅ |
| Email Verification | `presentation/views/auth/verification_view.dart` | ✅ |
| Forgot Password | `presentation/views/auth/forgot_password_view.dart` | ✅ |
| Onboarding | `presentation/views/onboarding/` | ✅ |
| Splash | `presentation/views/splash/` | ✅ |
| Welcome | `presentation/views/welcome/` | ✅ |
| Profile Setup (7 screens) | `presentation/views/profile/` | ✅ |
| Dashboard | `presentation/views/dashboard/` | ✅ |
| Settings | `presentation/views/settings/settings_view.dart` | ✅ |
| Edit Profile | `presentation/views/settings/edit_profile_view.dart` | ✅ |
| Edit Preferences | `presentation/views/settings/edit_preferences_view.dart` | ✅ |
| **Home/Discovery** | `presentation/views/home/` | ✅ |
| **Chat System** | `presentation/views/chat/` | ✅ |
| **Thought/Feed** | `presentation/views/thought/` | ✅ |

---

## 📡 Backend Endpoints Status

### ✅ Existing Endpoints

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/v1/auth/login` | POST | User login | ✅ |
| `/api/v1/auth/signup` | POST | User registration | ✅ |
| `/api/v1/auth/refresh` | POST | Refresh access token | ✅ |
| `/api/v1/auth/send-verification-code` | POST | Send OTP for email verification | ✅ |
| `/api/v1/auth/verify-code` | POST | Verify OTP code | ✅ |
| `/api/v1/auth/reset-password` | POST | Reset password with OTP | ✅ |
| `/api/v1/users/me` | GET | Get current user profile | ✅ |
| `/api/v1/users/me` | PUT | Update current user profile | ✅ |
| `/api/v1/users/me/profile/complete` | POST | Complete profile setup | ✅ |

### ✅ Newly Created Endpoints

#### Discovery/Swipe Endpoints ✅
| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/v1/discovery/users` | GET | Get users for swiping (server-filtered) | ✅ |
| `/api/v1/discovery/swipe` | POST | Record swipe action (like/pass/superlike) | ✅ |
| `/api/v1/discovery/history` | GET | Get swipe history | ✅ |
| `/api/v1/discovery/undo` | POST | Undo last swipe | ✅ |

#### Connection Endpoints ✅
| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/v1/connections` | GET | Get all user connections | ✅ |
| `/api/v1/connections/:id` | GET | Get single connection | ✅ |
| `/api/v1/connections/:id` | PUT | Update connection settings | ✅ |
| `/api/v1/connections/:id` | DELETE | Remove connection (unmetal) | ✅ |
| `/api/v1/connections/:id/block` | POST | Block user | ✅ |

#### Chat/Message Endpoints ✅
| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/v1/messages/:connectionId` | GET | Get messages for connection (paginated) | ✅ |
| `/api/v1/messages` | POST | Send message | ✅ |
| `/api/v1/messages/:connectionId/audio` | POST | Send audio message | ✅ |
| `/api/v1/messages/:id` | DELETE | Delete message | ✅ |
| `/api/v1/messages/:connectionId/read` | PUT | Mark all messages as read | ✅ |
| `/api/v1/messages/:connectionId/clear` | DELETE | Clear chat history | ✅ |

#### Thought/Feed Endpoints ✅
| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/api/v1/thoughts` | GET | Get thoughts feed (paginated) | ✅ |
| `/api/v1/thoughts` | POST | Create thought (text/voice/repost) | ✅ |
| `/api/v1/thoughts/:id` | GET | Get single thought | ✅ |
| `/api/v1/thoughts/:id` | PUT | Update thought | ✅ |
| `/api/v1/thoughts/:id` | DELETE | Delete thought | ✅ |
| `/api/v1/thoughts/:id/reactions` | GET | Get reactions for thought | ✅ |
| `/api/v1/thoughts/:id/reactions` | POST | Add/toggle reaction | ✅ |
| `/api/v1/thoughts/:id/comments` | GET | Get comments (paginated) | ✅ |
| `/api/v1/thoughts/:id/comments` | POST | Add comment | ✅ |
| `/api/v1/thoughts/:id/comments/:cid` | DELETE | Delete comment | ✅ |
| `/api/v1/thoughts/:id/comments/:cid/reactions` | POST | React to comment | ✅ |

### 🔄 Endpoints To Be Created

#### User Management Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/users/:id` | GET | Get user by ID | 🔴 High |
| `/api/v1/users/me/location` | PUT | Update user location | 🔴 High |
| `/api/v1/users/me/blocked` | GET | Get blocked users | 🟡 Medium |
| `/api/v1/users/me/blocked/:id` | POST | Block user | 🟡 Medium |
| `/api/v1/users/me/blocked/:id` | DELETE | Unblock user | 🟡 Medium |
| `/api/v1/users/me` | DELETE | Delete account | 🟡 Medium |

#### Spark Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/sparks` | GET | Get user sparks | 🟡 Medium |
| `/api/v1/sparks/send` | POST | Send spark to user | 🟡 Medium |
| `/api/v1/sparks/purchase` | POST | Purchase sparks | 🟡 Medium |

#### Notification Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/notifications` | GET | Get notifications | 🟡 Medium |
| `/api/v1/notifications/:id/read` | PUT | Mark as read | 🟢 Low |
| `/api/v1/notifications/settings` | PUT | Update notification settings | 🟢 Low |

#### Other Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/feedback` | POST | Submit feedback | 🟢 Low |
| `/api/v1/referrals` | GET | Get referral info | 🟢 Low |
| `/api/v1/referrals/code` | POST | Apply referral code | 🟢 Low |

---

## 🔄 Pending Migrations

### Phase 1: Core Features (High Priority)

#### 1. Home Page / Discovery ✅ COMPLETED

**Migration Summary:**
- ✅ Backend discovery service with server-side filtering
- ✅ All filtering logic moved to backend (gender, age, distance, demography)
- ✅ New Clean Architecture data layer
- ✅ New HomeView, HomeViewModel, widgets
- ✅ Dashboard updated to use new HomeView

**Files Created:**
```
Backend:
✅ functions/src/services/discovery.service.js
✅ functions/src/controllers/discovery.controller.js
✅ functions/src/routes/v1/discovery.routes.js
✅ functions/src/validations/discovery.validation.js

Flutter:
✅ lib/domain/entities/discovery_user_dto.dart
✅ lib/data/datasources/remote/discovery_remote_data_source.dart
✅ lib/data/repositories/discovery/discovery_repository.dart
✅ lib/presentation/viewmodels/home/home_viewmodel.dart
✅ lib/presentation/views/home/home_view.dart
✅ lib/presentation/views/home/widgets/enhanced_swipe_card.dart
✅ lib/presentation/views/home/widgets/discovery_user_card.dart
✅ lib/presentation/views/home/widgets/location_permission_screen.dart
```

**Key Improvements:**
- Server-side filtering (no Firestore queries in Flutter)
- Cursor-based pagination
- Match detection on swipe
- Clean separation of concerns

---

#### 2. Chat System ✅ COMPLETED

**Migration Summary:**
- ✅ Backend message service with CRUD operations
- ✅ Backend connection service for chat management
- ✅ Cursor-based pagination for messages
- ✅ New Clean Architecture data layer (DTOs, Repository, Remote Data Source)
- ✅ New ChatListView, ChatWindowView, ViewModels
- ✅ Dashboard updated to use new ChatListView

**Files Created:**
```
Backend:
✅ functions/src/services/message.service.js
✅ functions/src/services/connection.service.js
✅ functions/src/controllers/message.controller.js
✅ functions/src/controllers/connection.controller.js
✅ functions/src/validations/message.validation.js
✅ functions/src/validations/connection.validation.js
✅ functions/src/routes/v1/message.routes.js (updated)
✅ functions/src/routes/v1/connection.routes.js (updated)

Flutter:
✅ lib/domain/entities/message_dto.dart
✅ lib/data/models/message_model.dart
✅ lib/data/datasources/remote/chat_remote_data_source.dart
✅ lib/data/repositories/chat/chat_repository.dart
✅ lib/presentation/viewmodels/chat/chat_list_viewmodel.dart
✅ lib/presentation/viewmodels/chat/chat_window_viewmodel.dart
✅ lib/presentation/viewmodels/chat/chat_viewmodel_providers.dart
✅ lib/presentation/views/chat/chat_list_view.dart
✅ lib/presentation/views/chat/chat_window_view.dart
✅ lib/presentation/views/chat/widgets/chat_app_bar.dart
✅ lib/presentation/views/chat/widgets/chat_input.dart
✅ lib/presentation/views/chat/widgets/chat_message_list.dart
```

**Key Improvements:**
- REST API for all CRUD operations (no direct Firestore in Flutter)
- Melt status enforcement (initiator/receiver messaging rules)
- Optimistic UI updates for message sending
- Reply to message support
- Audio message support
- Block user and clear chat functionality
- Unread message badges with counts

#### 3. Thought / Feed ✅ COMPLETED

**Migration Summary:**
- ✅ Backend thought service with full CRUD operations
- ✅ Reactions and comments support via API
- ✅ New tab structure: Thoughts, Community, Link Up
- ✅ Removed For You/Explore split - single unified feed
- ✅ New Clean Architecture data layer (Remote Data Source, Repository)
- ✅ New ThoughtScreen with TabBar, ViewModels
- ✅ Dashboard updated to use new ThoughtScreen

**Files Created:**
```
Backend:
✅ functions/src/services/thought.service.js
✅ functions/src/controllers/thought.controller.js (updated)
✅ functions/src/validations/thought.validation.js
✅ functions/src/routes/v1/thought.routes.js (updated)

Flutter:
✅ lib/data/datasources/remote/thought_remote_data_source.dart
✅ lib/data/repositories/thought/thought_repository_abstract.dart
✅ lib/data/repositories/thought/thought_repository.dart
✅ lib/presentation/viewmodels/thought/thought_feed_viewmodel.dart
✅ lib/presentation/viewmodels/thought/thought_providers.dart
✅ lib/presentation/views/thought/thought_screen.dart
```

**New Tab Structure:**
1. **Thoughts** - All thoughts feed (API-based, paginated)
2. **Community** - Placeholder for future community features
3. **Link Up** - Placeholder for future link up features

**Key Improvements:**
- REST API for all operations (no more direct Firestore queries)
- Single unified feed (no For You/Explore complexity)
- Cursor-based pagination
- Full CRUD for thoughts, reactions, and comments
- Clean separation of concerns with Clean Architecture

---

### Phase 2: Social Features (Medium Priority)

#### 4. My Metals / Connections
- [ ] **Location**: `features/my.metals/`
- [ ] **Components**:
  - [ ] `my.melted.metals.dart` - Connections list
  - [ ] `my.melted.user.dart` - Single connection view
  - [ ] `melt.metal.dart` - Melt/connect action
  - [ ] `user.profile.dart` - User profile in context
  - [ ] `metal.tabs/` - Profile tabs
- [ ] **New Location**: `presentation/views/connections/`
- [ ] **Complexity**: 🟡 Medium
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/connections`
  - [ ] `GET /api/v1/connections/:id`

#### 5. Profile View
- [ ] **Location**: `features/profile/presentation/`
- [ ] **Components**:
  - [ ] `profile.page.dart` - Main profile
  - [ ] `tab.screen/` - Profile tabs (4 files)
  - [ ] `pages/work_email_page.dart`
- [ ] **Providers**:
  - [ ] `upload.profile.image.notifier.dart`
  - [ ] `delete.user.notifier.dart`
- [ ] **New Location**: `presentation/views/profile_view/`
- [ ] **Complexity**: 🟡 Medium

#### 6. Sparks
- [ ] **Location**: `features/sparks_page/`
- [ ] **Components**:
  - [ ] `sparks_page.dart` - Main sparks view
  - [ ] `buy.spark/` - Purchase sparks
  - [ ] `send.spark/` - Send sparks
  - [ ] `refer.earn/` - Referral sparks
- [ ] **Providers**:
  - [ ] `buy.spark.notifier.dart`
  - [ ] `send.spark.notifier.dart`
  - [ ] `get.spark.notifier.dart`
- [ ] **New Location**: `presentation/views/sparks/`
- [ ] **Complexity**: 🟡 Medium
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/sparks`
  - [ ] `POST /api/v1/sparks/send`

---

### Phase 3: Secondary Features

#### 7. Eyes (Stories)
- [ ] **Location**: `features/eyes/`
- [ ] **Components**:
  - [ ] `eyes.intro.screen.dart`
  - [ ] `eye.select.media.dart`
  - [ ] `eye.preview.media.dart`
  - [ ] `view.eyes.dart`
- [ ] **New Location**: `presentation/views/eyes/`
- [ ] **Complexity**: 🟡 Medium

#### 8. Community
- [ ] **Location**: `features/community/`
- [ ] **Components**:
  - [ ] `community_discovery_screen.dart`
  - [ ] `community_profile_screen.dart`
  - [ ] `create_community_screen.dart`
- [ ] **New Location**: `presentation/views/community/`
- [ ] **Complexity**: 🟡 Medium

#### 9. Notifications
- [ ] **Location**: `features/notification/`
- [ ] **Components**:
  - [ ] `notification.page.dart`
  - [ ] `notification.item.dart`
- [ ] **New Location**: `presentation/views/notification/`
- [ ] **Complexity**: 🟢 Low
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/notifications`

---

### Phase 4: Support Features

#### 10. Feedback
- [ ] **Location**: `features/feedback/`
- [ ] **Components**:
  - [ ] `feedback.page.dart`
- [ ] **New Location**: `presentation/views/feedback/`
- [ ] **Complexity**: 🟢 Low
- [ ] **Requires Endpoints**:
  - [ ] `POST /api/v1/feedback`

#### 11. Refer & Earn
- [ ] **Location**: `features/refer.earn/`
- [ ] **Components**:
  - [ ] `refer.earn.dart`
- [ ] **New Location**: `presentation/views/referral/`
- [ ] **Complexity**: 🟢 Low

#### 12. Upgrade / Payments
- [ ] **Location**: `features/upgrade/`
- [ ] **Components**:
  - [ ] `upgrade.page.dart`
  - [ ] `make.payment.dart`
  - [ ] Payment integration
- [ ] **New Location**: `presentation/views/upgrade/`
- [ ] **Complexity**: 🟡 Medium

#### 13. Blocked Users
- [ ] **Location**: `features/settings/presentation/`
- [ ] **Components**:
  - [ ] `blocked.user.dart`
  - [ ] Block widgets
- [ ] **New Location**: `presentation/views/settings/blocked_users_view.dart`
- [ ] **Complexity**: 🟢 Low
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/users/me/blocked`

#### 14. Delete Account
- [ ] **Location**: `features/settings/presentation/`
- [ ] **Components**:
  - [ ] `delete.screen.dart`
- [ ] **New Location**: `presentation/views/settings/delete_account_view.dart`
- [ ] **Complexity**: 🟢 Low
- [ ] **Requires Endpoints**:
  - [ ] `DELETE /api/v1/users/me`

#### 15. Unmetal (Unmatch)
- [ ] **Location**: `features/unmetal/`
- [ ] **Components**:
  - [ ] `unmetal_dialog.dart`
- [ ] **New Location**: `presentation/widgets/dialogs/`
- [ ] **Complexity**: 🟢 Low
- [ ] **Requires Endpoints**:
  - [ ] `DELETE /api/v1/connections/:id`

#### 16. Work Email Verification
- [ ] **Location**: `features/verification/`
- [ ] **Components**:
  - [ ] Work email verification flow
- [ ] **New Location**: `presentation/views/verification/`
- [ ] **Complexity**: 🟢 Low

---

## Architecture Reference

### New Structure Pattern
```
presentation/
├── views/
│   └── [feature]/
│       ├── [feature]_view.dart      # Main view
│       └── widgets/                  # Feature-specific widgets
├── viewmodels/
│   └── [feature]/
│       └── [feature]_viewmodel.dart # UI state only (no API calls)
└── widgets/
    └── [shared widgets]
```

### Single Source of Truth
```dart
// ✅ CORRECT - Use userStateProvider for ALL user operations
await ref.read(userStateProvider.notifier).updateUserField(
  field: 'fieldName',
  value: newValue,
);

// ❌ WRONG - Don't make API calls in views or viewmodels
await apiClient.patch('/user', data: {...});
```

### Clean Architecture Pattern
```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌────────────┐    ┌─────────────────┐    ┌─────────────┐  │
│  │    View    │───▶│    ViewModel    │───▶│   Provider  │  │
│  │  (Widget)  │    │   (UI State)    │    │ (Riverpod)  │  │
│  └────────────┘    └─────────────────┘    └─────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                           │
│  ┌────────────────────┐    ┌──────────────────────────────┐ │
│  │     Use Cases      │    │           DTOs               │ │
│  │ (Business Logic)   │    │  (Domain Entities)           │ │
│  └────────────────────┘    └──────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        DATA LAYER                            │
│  ┌───────────────────┐    ┌───────────────────────────────┐ │
│  │    Repository     │───▶│       Remote Data Source      │ │
│  │ (Implementation)  │    │         (API Calls)           │ │
│  └───────────────────┘    └───────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Progress Tracker

| Phase | Features | Completed | Total |
|-------|----------|-----------|-------|
| Phase 1 | Core | 3 | 3 |
| Phase 2 | Social | 0 | 3 |
| Phase 3 | Secondary | 0 | 3 |
| Phase 4 | Support | 0 | 7 |
| **Total** | | **3** | **16** |

---

## Backend Endpoints Summary

| Category | Total Endpoints | Created | Pending |
|----------|-----------------|---------|---------|
| Auth | 6 | 6 | 0 |
| Users | 6 | 3 | 3 |
| Discovery | 4 | 4 | 0 |
| Connections | 5 | 5 | 0 |
| Messages | 6 | 6 | 0 |
| Thoughts | 11 | 11 | 0 |
| Sparks | 3 | 0 | 3 |
| Notifications | 3 | 0 | 3 |
| Other | 3 | 0 | 3 |
| **Total** | **47** | **35** | **12** |

---

*Last Updated: December 2024*
