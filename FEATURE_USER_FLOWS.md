# Metal App - Feature User Flows

This document provides detailed, non-technical explanations of how various features work in the Metal app, focusing on complete end-to-end user experiences.

---

## 1. Direct Message from Discovery Card

### Overview
Users can send a direct message to someone they discover on the discovery card, which automatically creates a connection (called a "melt") between the two users.

### Complete User Flow

#### Step 1: Discovery
- User opens the app and navigates to the Discovery screen (Home)
- The app displays discovery cards showing other users nearby
- Each card shows:
  - User's profile photo (or metal avatar if anonymous)
  - Username and basic info (age, gender)
  - Location and distance
  - Prompts/answers (if available)
  - Passions and connection preferences
  - Recent thoughts

#### Step 2: Initiating Direct Message
- User sees a discovery card they're interested in
- User taps the **Message button** (pink message icon) at the bottom of the card
- A dialog appears titled "Message [Username]"

#### Step 3: Composing Message
- The dialog shows:
  - Recipient's username at the top
  - A brief explanation: "Send a quick message to start the conversation. You'll automatically connect when you send."
  - A text input field (up to 500 characters)
  - "Cancel" and "Send Message" buttons

#### Step 4: Sending Message
- User types their message in the text field
- User taps "Send Message" button
- The app shows a loading indicator while processing
- The message is sent to the backend

#### Step 5: Automatic Connection Creation
- When the message is sent, the backend automatically:
  - Creates a connection (melt) between the two users
  - Creates a chat conversation
  - Sends the initial message
  - Returns a connection ID

#### Step 6: Post-Send Experience
- The dialog closes automatically
- A success message appears: "Message sent! Opening chat..."
- The discovery card is removed from the discovery stack
- User is automatically navigated to the **Melt Metal** celebration screen
- The celebration screen shows:
  - Confirmation that they've melted (connected) with the other user
  - Connection details

#### Step 7: Accessing the Chat
- From the celebration screen, user can navigate to the chat window
- The chat window opens showing:
  - The initial message they sent
  - Full chat interface ready for continued conversation
  - Real-time messaging capabilities via WebSocket

### Key Points
- **No prior connection needed**: Users don't need to be connected before messaging
- **Automatic melt**: Sending a direct message automatically creates a connection
- **Immediate chat access**: Users can start chatting right away
- **One-way action**: The recipient doesn't need to accept - the connection is created automatically

### Error Handling
- If message is empty: User sees "Please enter a message"
- If sending fails: Error message appears and user can try again
- If connection creation fails: User sees "Message sent but could not open chat"

---

## 2. Message from Non-Connected User Profile Page

### Overview
Users can send a message to someone from their profile page, even if they're not connected. This also automatically creates a connection.

### Complete User Flow

#### Step 1: Accessing Profile
- User navigates to another user's profile page (from thoughts, connections list, or search)
- Profile page displays:
  - User's profile photo or metal avatar
  - Username and location
  - Two tabs: "Metal Thought" and "Metal Details"
  - Action buttons at the top

#### Step 2: Viewing Connection Status
- If users are **not connected**, the profile shows:
  - "Melt" button (primary action)
  - "Message" button (secondary action)
- If users are **already connected**, the profile shows:
  - "Send Spark" button
  - "Message" button (which opens existing chat)

#### Step 3: Initiating Message (Non-Connected)
- User taps the **"Message"** button
- A loading dialog appears: "Opening chat..."
- The app automatically:
  - Creates a melt request (connection) between the users
  - Waits for the connection to be established
  - Retrieves the connection ID

#### Step 4: Connection Creation Process
- The backend processes the melt request:
  - Creates a connection record
  - Establishes a chat conversation
  - Returns connection details including connection ID
- The app refreshes the profile to show updated connection status

#### Step 5: Opening Chat Window
- After connection is created (usually takes 300-500ms):
  - Loading dialog closes
  - User is automatically navigated to the chat window
  - Chat window opens showing:
    - Empty conversation (no initial message)
    - Full messaging interface ready to use
    - Real-time messaging capabilities

#### Step 6: Sending First Message
- User can immediately start typing and send messages
- Messages appear in real-time
- Both users can see the conversation

### Key Differences from Discovery Card Messaging
- **No initial message**: Unlike discovery card, this doesn't send an initial message
- **Profile context**: User is viewing full profile before messaging
- **Connection first**: Connection is created before chat opens (vs. simultaneous)
- **Manual first message**: User must type the first message themselves

### Error Handling
- If connection creation fails: Error toast appears, user can try again
- If connection ID not found: "Could not open chat. Try again." message
- If user tries to message themselves: "You cannot message yourself" toast

### Edge Cases
- **Profile completion check**: If current user's profile isn't complete, they may see a prompt to complete it first
- **Melt limit**: If user has reached 10 connections, they'll see a limit dialog before messaging
- **Pending melt**: If there's already a pending melt request, the button shows "Melt pending" (disabled)

---

## 3. Like on Discovery Card

### Overview
Users can express interest in someone by "liking" them on the discovery card. This records their interest and may result in a match if the other user has also liked them.

### Complete User Flow

#### Step 1: Viewing Discovery Card
- User sees a discovery card with another user's information
- Card displays all user details (photo, prompts, thoughts, etc.)

#### Step 2: Liking a User
User can like in two ways:

**Method A: Swipe Right**
- User swipes the card to the right (horizontal swipe)
- Card moves right with visual feedback (rotation, opacity change)
- When swipe distance exceeds threshold (100 pixels), action triggers

**Method B: Tap Like Button**
- User taps the **heart icon** (green) at the bottom of the card
- Action triggers immediately

#### Step 3: Recording the Like
- The app records the swipe action:
  - Sends "like" action to backend with target user ID
  - Backend records the swipe in database
  - Backend checks if this is a mutual like (match)

#### Step 4: Match Detection
- Backend checks:
  - Has the target user already liked the current user?
  - If yes: **Match detected!**
  - If no: Like is recorded, no match yet

#### Step 5A: No Match Scenario
- If no match:
  - Card is removed from discovery stack
  - Next card appears automatically
  - Like is saved in user's swipe history
  - Target user will see the like in their notifications (if they check)
  - If target user later likes back, a match will be created

#### Step 5B: Match Scenario
- If match detected:
  - Card is removed from discovery stack
  - **Match celebration screen** appears automatically
  - Screen shows:
    - "It's a Melt!" or similar celebration message
    - Both users' information
    - Connection details
  - User is navigated to the **Melt Metal** screen
  - Connection is automatically created
  - Both users can now message each other

#### Step 6: Post-Like Experience
- User continues discovering other people
- If match occurred, they can access the new connection from:
  - Connections list
  - Chat list
  - Melt Metal screen

### Visual Feedback
- **During swipe**: Card rotates slightly and becomes semi-transparent
- **After like**: Card slides off screen, next card appears
- **On match**: Celebration animation and screen transition

### Key Points
- **One-way action**: Liking doesn't require the other user's immediate response
- **Match potential**: Creates opportunity for future match if mutual
- **Immediate match**: If mutual like exists, connection is instant
- **Swipe history**: All likes are saved and can be reviewed later

### Error Handling
- If network fails: Error toast appears, card remains visible
- If user already liked: Backend prevents duplicate, no error shown
- If user is blocked: Action is prevented, appropriate message shown

---

## 4. Dismiss on Discovery Card

### Overview
Users can dismiss (pass on) someone they're not interested in. This removes them from discovery and records the action.

### Complete User Flow

#### Step 1: Viewing Discovery Card
- User sees a discovery card with another user's information
- Card displays all user details

#### Step 2: Dismissing a User
User can dismiss in two ways:

**Method A: Swipe Left**
- User swipes the card to the left (horizontal swipe)
- Card moves left with visual feedback (rotation, opacity change)
- When swipe distance exceeds threshold (100 pixels), action triggers

**Method B: Tap Dismiss Button**
- User taps the **X icon** (red) at the bottom of the card
- Action triggers immediately

#### Step 3: Recording the Dismiss
- The app records the swipe action:
  - Sends "pass" action to backend with target user ID
  - Backend records the dismiss in database
  - Backend marks this user as "passed" for the current user

#### Step 4: Card Removal
- Card is immediately removed from discovery stack
- Next card appears automatically
- User won't see this person again in discovery (unless they undo)

#### Step 5: Backend Processing
- Backend records:
  - User ID who dismissed
  - Target user ID who was dismissed
  - Timestamp of action
  - Action type: "pass"
- This prevents the dismissed user from appearing again in discovery

#### Step 6: Continuing Discovery
- User sees the next discovery card
- Process continues seamlessly
- If discovery stack gets low (< 5 cards), app automatically loads more users

### Visual Feedback
- **During swipe**: Card rotates slightly and becomes semi-transparent
- **After dismiss**: Card slides off screen to the left, next card appears
- **Smooth transition**: No jarring movements, fluid card replacement

### Key Points
- **Permanent action**: Dismissed users won't reappear in discovery
- **No notification**: Dismissed user doesn't receive any notification
- **Reversible**: User can undo last dismiss (if available)
- **Privacy**: Other user never knows they were dismissed

### Undo Functionality
- If user accidentally dismisses someone:
  - User can tap "Undo" button (if available)
  - Last dismiss action is reversed
  - User reappears in discovery stack
  - Only works for the most recent dismiss

### Error Handling
- If network fails: Error toast appears, card remains visible
- If user already dismissed: Backend prevents duplicate, no error shown
- If action fails: Card stays visible, user can try again

### Auto-Loading More Users
- When discovery stack gets low:
  - App automatically fetches more users from backend
  - New cards appear seamlessly
  - User experience is uninterrupted
  - Pagination cursor is used to avoid duplicates

---

## Additional Notes

### Connection Limits
- Users can have a maximum of **10 active connections** (melts)
- If limit is reached:
  - User must "unmelt" (disconnect) from someone before connecting to new people
  - Limit dialog appears when trying to exceed limit
  - Message: "You are limited to a total of 10 Connections"

### Real-Time Updates
- All messaging uses **WebSocket** for real-time delivery
- Messages appear instantly for both users
- Read receipts are updated in real-time
- Typing indicators can be shown (if implemented)

### Privacy Features
- **Anonymous mode**: Users can choose to be anonymous until connected
- **Profile photos**: Only visible to connected users (if not anonymous)
- **Blocked users**: Cannot interact with blocked users
- **Location privacy**: Distance shown, not exact location

### Discovery Algorithm
- Users are shown based on:
  - Geographic proximity
  - User preferences (age, gender, etc.)
  - Connection status (not already connected)
  - Swipe history (not previously dismissed)
  - Active status

---

## Summary

All four features share common patterns:
1. **User-initiated actions** from discovery cards or profiles
2. **Backend processing** that handles connection creation and data storage
3. **Real-time updates** via WebSocket for messaging
4. **Smooth UI transitions** with visual feedback
5. **Error handling** with user-friendly messages
6. **Automatic connection creation** when messaging non-connected users

The app prioritizes user experience with immediate feedback, smooth animations, and seamless transitions between screens.
