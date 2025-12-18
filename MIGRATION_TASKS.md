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

### 🔄 Endpoints To Be Created

#### Connection Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/connections` | GET | Get all user connections | 🔴 High |
| `/api/v1/connections/:id` | GET | Get single connection | 🔴 High |
| `/api/v1/connections` | POST | Create connection (melt request) | 🔴 High |
| `/api/v1/connections/:id` | DELETE | Remove connection (unmetal) | 🟡 Medium |
| `/api/v1/connections/:id/block` | POST | Block user | 🟡 Medium |

#### Chat/Message Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/messages/:connectionId` | GET | Get messages for connection | 🔴 High |
| `/api/v1/messages` | POST | Send message | 🔴 High |
| `/api/v1/messages/:id` | DELETE | Delete message | 🟡 Medium |
| `/api/v1/messages/:id/read` | PUT | Mark message as read | 🟡 Medium |

#### Thought/Feed Endpoints
| Endpoint | Method | Description | Priority |
|----------|--------|-------------|----------|
| `/api/v1/thoughts` | GET | Get thoughts feed | 🔴 High |
| `/api/v1/thoughts` | POST | Create thought | 🔴 High |
| `/api/v1/thoughts/:id` | GET | Get single thought | 🟡 Medium |
| `/api/v1/thoughts/:id` | DELETE | Delete thought | 🟡 Medium |
| `/api/v1/thoughts/:id/react` | POST | React to thought | 🟡 Medium |
| `/api/v1/thoughts/:id/comments` | GET | Get comments | 🟡 Medium |
| `/api/v1/thoughts/:id/comments` | POST | Add comment | 🟡 Medium |

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

#### 2. Chat System
- [ ] **Location**: `features/chat/`
- [ ] **Components**:
  - [ ] `chat.page.dart` - Chat list
  - [ ] `chat.window/` - Chat conversation (9 files)
  - [ ] `games/` - In-chat games
  - [ ] `widget/` - Chat widgets
- [ ] **Providers to review** (10 providers):
  - [ ] `chat.message.notifier.dart`
  - [ ] `get.chatlist.notifier.dart`
  - [ ] `send.message.notifier.dart`
  - [ ] etc.
- [ ] **New Location**: `presentation/views/chat/`
- [ ] **Complexity**: 🔴 High
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/messages/:connectionId`
  - [ ] `POST /api/v1/messages`
  - [ ] Real-time: Keep Firestore listeners for messages

#### 3. Thought / Feed
- [ ] **Location**: `features/thought/`
- [ ] **Components**:
  - [ ] `thought_screen.dart` - Feed screen
  - [ ] `post_thought.dart` - Create post
  - [ ] `thought_details.page.dart` - Post details
  - [ ] `comment_bottom_sheet.dart` - Comments
  - [ ] `widget/` - Feed widgets (8 files)
- [ ] **Providers to review** (16 providers):
  - [ ] `send.thoughts.dart`
  - [ ] `get.thoughts.explore.dart`
  - [ ] `comment.provider.dart`
  - [ ] `reaction.provider.dart`
  - [ ] etc.
- [ ] **New Location**: `presentation/views/thought/`
- [ ] **Complexity**: 🔴 High
- [ ] **Requires Endpoints**:
  - [ ] `GET /api/v1/thoughts`
  - [ ] `POST /api/v1/thoughts`
  - [ ] `POST /api/v1/thoughts/:id/react`
  - [ ] `GET/POST /api/v1/thoughts/:id/comments`

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
| Phase 1 | Core | 1 | 3 |
| Phase 2 | Social | 0 | 3 |
| Phase 3 | Secondary | 0 | 3 |
| Phase 4 | Support | 0 | 7 |
| **Total** | | **1** | **16** |

---

## Backend Endpoints Summary

| Category | Total Endpoints | Created | Pending |
|----------|-----------------|---------|---------|
| Auth | 6 | 6 | 0 |
| Users | 6 | 3 | 3 |
| Discovery | 4 | 4 | 0 |
| Connections | 5 | 0 | 5 |
| Messages | 4 | 0 | 4 |
| Thoughts | 7 | 0 | 7 |
| Sparks | 3 | 0 | 3 |
| Notifications | 3 | 0 | 3 |
| Other | 3 | 0 | 3 |
| **Total** | **41** | **13** | **28** |

---

*Last Updated: December 2024*
