# Thought Creation Flow - Implementation Plan

## Overview
Implement a Facebook-like thought creation UI that supports:
1. **Text-only thoughts** - Just text content
2. **Text + Audio thoughts** - Text with optional audio attachment
3. **Audio-only thoughts** - Voice thoughts without text

## Current State Analysis

### Backend (`metal-BE`)
✅ **Already Supports:**
- `type: 'text'` or `type: 'voice'`
- `content` (required string, max 1000 chars)
- `audioUrl` (optional, required for `type: 'voice'`)
- `audioDuration` (optional, 1-120 seconds)

❌ **Issues:**
- Backend only allows audio for `type: 'voice'`
- Need to support `type: 'text'` with optional `audioUrl` (text + audio combo)

### Frontend (`metal`)
✅ **Already Has:**
- `MetalDialog` component (design system compliant)
- `BaseButton` component
- `BaseTextField` component
- Audio recording utilities (from chat input)
- Media upload service
- Thought repository and viewmodel

❌ **Missing:**
- Thought creation UI screen/widget
- Route implementation for `/postThought`
- UI for text + optional audio input

## Implementation Flow

### Phase 1: Backend Updates

#### 1.1 Update Thought Service (`metal-BE/src/services/thought.service.js`)
**Current Logic:**
```javascript
// Add audio fields for voice thoughts
if (type === 'voice') {
  if (!audioUrl) {
    throw new ApiError(400, 'Audio URL is required for voice thoughts');
  }
  thoughtObj.audioUrl = audioUrl;
  thoughtObj.audioDuration = audioDuration;
}
```

**New Logic:**
```javascript
// Add audio fields if provided (for both text and voice types)
if (audioUrl) {
  if (!audioDuration || audioDuration < 1 || audioDuration > 120) {
    throw new ApiError(400, 'Audio duration must be between 1 and 120 seconds');
  }
  thoughtObj.audioUrl = audioUrl;
  thoughtObj.audioDuration = audioDuration;
}

// Validate voice-only thoughts
if (type === 'voice' && !audioUrl) {
  throw new ApiError(400, 'Audio URL is required for voice-only thoughts');
}

// Validate text thoughts have content
if (type === 'text' && !content.trim()) {
  throw new ApiError(400, 'Content is required for text thoughts');
}
```

#### 1.2 Update Validation Schema (`metal-BE/src/validations/thought.validation.js`)
**Changes:**
- Make `content` optional when `type === 'voice'` (voice-only thoughts)
- Make `audioUrl` optional for `type === 'text'` (text + optional audio)
- Add conditional validation based on type

```javascript
body('content')
  .optional({ checkFalsy: true })
  .trim()
  .isString()
  .withMessage('Content must be a string')
  .isLength({ max: 1000 })
  .withMessage('Content cannot exceed 1000 characters')
  .custom((value, { req }) => {
    // Content required for text type, optional for voice
    if (req.body.type === 'text' && !value?.trim()) {
      throw new Error('Content is required for text thoughts');
    }
    return true;
  }),
```

### Phase 2: Frontend Updates

#### 2.1 Create Thought Creation Screen
**File:** `lib/presentation/views/thought/create_thought_screen.dart`

**Features:**
- Full-screen modal/bottom sheet (Facebook-style)
- Text input area (multiline, max 1000 chars)
- Audio recording/playback section (optional)
- Character counter
- Post button (disabled until valid input)
- Cancel/Discard button

**UI Structure:**
```
┌─────────────────────────────────┐
│  [X] Create Thought             │
├─────────────────────────────────┤
│                                 │
│  [Text Input Area]              │
│  (Multiline, placeholder)       │
│                                 │
│  [Audio Section]                │
│  - Record button                │
│  - Playback widget (if recorded)│
│  - Delete audio button           │
│                                 │
│  [Character Counter: 0/1000]    │
│                                 │
├─────────────────────────────────┤
│  [Cancel]        [Post]         │
└─────────────────────────────────┘
```

#### 2.2 Create Thought Input Widget
**File:** `lib/presentation/views/thought/widgets/create_thought_input.dart`

**Components:**
- `_TextInputSection` - Multiline text field
- `_AudioSection` - Audio recording/playback
- `_ActionButtons` - Cancel and Post buttons

#### 2.3 Update Thought DTO
**File:** `lib/domain/entities/thought_dto.dart`

**No changes needed** - Already supports optional `audioUrl` and `audioDuration`

#### 2.4 Update Thought Repository
**File:** `lib/data/repositories/thought/thought_repository.dart`

**Update `createThought` method:**
```dart
Future<BaseState<ThoughtDto>> createThought({
  required String? content, // Make nullable for voice-only
  String type = 'text',
  String? audioUrl,
  int? audioDuration,
  // ... rest
}) async {
  // Determine type based on content and audio
  final actualType = _determineThoughtType(content, audioUrl);
  
  // Validate based on type
  if (actualType == 'text' && (content == null || content.trim().isEmpty)) {
    return BaseState.error('Content is required for text thoughts');
  }
  
  if (actualType == 'voice' && audioUrl == null) {
    return BaseState.error('Audio is required for voice thoughts');
  }
  
  // ... rest of implementation
}

String _determineThoughtType(String? content, String? audioUrl) {
  if (audioUrl != null && (content == null || content.trim().isEmpty)) {
    return 'voice';
  }
  return 'text'; // Text with optional audio
}
```

#### 2.5 Update Routes
**File:** `lib/route/routes.dart`

**Implement the route:**
```dart
case AppRoutes.postThought:
  return MaterialPageRoute(
    builder: (_) => const CreateThoughtScreen(),
  );
```

### Phase 3: Integration with Existing Systems

#### 3.1 Reuse Audio Recording
**Leverage:** `lib/presentation/views/chat/widgets/voice_recording_widget.dart`
- Extract audio recording logic into a reusable component
- Or create a simplified version for thoughts

#### 3.2 Reuse Media Upload
**Leverage:** Existing media upload service from chat
- Use same `mediaUpload` endpoint
- Use same `mediaMakePublic` endpoint
- Reuse audio upload logic from `chat_input.dart`

#### 3.3 Design System Compliance
**Use:**
- `MetalDialog` for confirmation dialogs (discard changes)
- `BaseButton` for Post/Cancel buttons
- `TextView` for labels and text
- `AppColors` for consistent colors
- Border radius: 20px (design guide)

### Phase 4: User Experience Flow

#### 4.1 Opening Create Thought
1. User taps "Post Thought" button (from dashboard/reminder dialog)
2. Full-screen modal slides up from bottom
3. Text input is focused automatically
4. Keyboard appears

#### 4.2 Text Input
1. User types text (max 1000 characters)
2. Character counter updates in real-time
3. Post button enabled when:
   - Text has content (for text thoughts), OR
   - Audio is recorded (for voice thoughts), OR
   - Both (for text + audio)

#### 4.3 Audio Recording (Optional)
1. User taps microphone icon
2. Permission check (reuse `PermissionHelper`)
3. Recording starts (visual feedback)
4. User can stop recording
5. Audio playback preview appears
6. User can delete and re-record
7. Audio duration displayed

#### 4.4 Posting Thought
1. User taps "Post" button
2. Validation:
   - Text thoughts: Must have content
   - Voice thoughts: Must have audio
   - Text + Audio: Must have at least one
3. If audio exists:
   - Upload audio to Firebase Storage
   - Get download URL
   - Make file public
4. Create thought via API
5. Show success feedback
6. Close modal
7. Refresh thought feed

#### 4.5 Discarding Thought
1. User taps "Cancel" or back button
2. If changes exist, show confirmation dialog:
   - "Discard thought?"
   - "You have unsaved changes"
   - [Cancel] [Discard]
3. If confirmed, close modal without saving

### Phase 5: Error Handling

#### 5.1 Validation Errors
- Show inline error messages
- Disable Post button until valid
- Character limit warning at 900/1000

#### 5.2 Network Errors
- Show snackbar with retry option
- Keep draft state (don't lose user input)

#### 5.3 Audio Errors
- Permission denied: Show dialog (reuse existing)
- Upload failed: Show error, allow retry
- Playback failed: Show error, allow re-record

## File Structure

```
lib/presentation/views/thought/
├── create_thought_screen.dart          # Main screen
├── widgets/
│   ├── create_thought_input.dart       # Input widget
│   ├── thought_audio_section.dart      # Audio recording/playback
│   └── thought_text_input.dart         # Text input section
└── thought_screen.dart                 # Existing (feed view)

lib/presentation/viewmodels/thought/
├── create_thought_viewmodel.dart      # ViewModel for creation
└── thought_providers.dart             # Update providers
```

## Backend Changes Summary

1. **`thought.service.js`**: Allow audio for text thoughts
2. **`thought.validation.js`**: Conditional validation based on type
3. **No database changes needed** - Schema already supports it

## Frontend Changes Summary

1. **New Screen**: `CreateThoughtScreen`
2. **New Widgets**: Input components
3. **Update Repository**: Handle type determination
4. **Update Routes**: Implement postThought route
5. **Reuse**: Audio recording, media upload, design components

## Testing Checklist

- [ ] Text-only thought creation
- [ ] Audio-only thought creation
- [ ] Text + Audio thought creation
- [ ] Character limit enforcement (1000)
- [ ] Audio duration limit (120s)
- [ ] Permission handling
- [ ] Upload error handling
- [ ] Discard confirmation
- [ ] Feed refresh after posting
- [ ] Design system compliance

## Next Steps

1. Start with backend updates (Phase 1)
2. Create basic UI structure (Phase 2.1)
3. Integrate audio recording (Phase 2.2)
4. Connect to API (Phase 2.4)
5. Add polish and error handling (Phase 4-5)



