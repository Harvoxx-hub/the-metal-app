# Backend API Rebuild Recommendations

## 📋 Current Architecture Analysis

### Current Real-time Mechanisms

#### 1. **Chat/Messaging System**
- **Current Implementation:**
  - Uses Firestore real-time listeners (`snapshots()`) for live message updates
  - Messages stored in: `/connections/{connectionId}/messages`
  - Connection metadata in: `/connections/{connectionId}`
  - Real-time stream: `MessageRepository.getMessages()` uses `.snapshots()`

- **Key Features:**
  - Real-time message delivery
  - Unread count tracking
  - Last message metadata
  - Daily conversation tracking
  - Melt status validation

#### 2. **Thoughts Real-time Updates**
- **Current Implementation:**
  - **Reactions:** Firestore stream on `/thoughts/{thoughtId}/reactions`
  - **Comments:** Firestore stream on `/thoughts/{thoughtId}/comments`
  - **Thought Feed:** One-time queries (not real-time) - `getThoughtForYou()` and `getThoughtExplore()`
  - Cloud Functions trigger notifications on thought updates

- **Key Features:**
  - Real-time reaction updates
  - Real-time comment updates
  - Notification triggers for new reactions/comments

#### 3. **Presence/Online Status**
- **Current Implementation:**
  - Firebase Realtime Database for presence tracking
  - Syncs to Firestore via Cloud Functions
  - Uses `.onDisconnect()` for automatic offline detection

---

## 🎯 Recommended API Architecture

### Option 1: WebSocket + REST API (RECOMMENDED) ⭐

#### **For Chat/Messaging:**

**1. WebSocket Server**
- **Technology:** 
  - Node.js: `socket.io` or `ws`
  - Python: `FastAPI` with `WebSockets` or `Django Channels`
  - Go: `gorilla/websocket` or `nhooyr.io/websocket`
  
- **Implementation:**
  ```javascript
  // Example: Socket.io server
  io.on('connection', (socket) => {
    // Join conversation room
    socket.on('join_conversation', (conversationId) => {
      socket.join(`conversation:${conversationId}`);
    });
    
    // Send message
    socket.on('send_message', async (data) => {
      // Save to database
      const message = await saveMessage(data);
      
      // Broadcast to conversation room
      io.to(`conversation:${data.conversationId}`)
        .emit('new_message', message);
    });
    
    // Typing indicators
    socket.on('typing', (data) => {
      socket.to(`conversation:${data.conversationId}`)
        .emit('user_typing', data);
    });
  });
  ```

- **Features:**
  - Real-time bidirectional communication
  - Room-based messaging (one room per conversation)
  - Typing indicators
  - Message read receipts
  - Online/offline status
  - Connection state management

**2. REST API Endpoints**
```
POST   /api/v1/messages                    # Send message
GET    /api/v1/conversations/:id/messages  # Get message history (paginated)
PUT    /api/v1/messages/:id/read           # Mark as read
DELETE /api/v1/messages/:id                 # Delete message
GET    /api/v1/conversations                # List conversations
POST   /api/v1/conversations                # Create conversation
PUT    /api/v1/conversations/:id            # Update conversation (unread count, etc.)
```

**3. Database Schema (PostgreSQL/MongoDB)**
```sql
-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES users(id),
  message TEXT,
  type VARCHAR(20), -- 'text', 'audio', 'un_melt', 'calls'
  content TEXT, -- URL for audio/media
  timestamp TIMESTAMP,
  is_read BOOLEAN DEFAULT FALSE,
  reply_to_message_id UUID REFERENCES messages(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Conversations table
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  users UUID[],
  last_message TEXT,
  last_updated_at TIMESTAMP,
  last_sender_id UUID,
  unread_count INT DEFAULT 0,
  melt_status VARCHAR(20), -- 'mutual', 'pending'
  daily_conversations DATE[],
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### **For Thoughts Real-time Updates:**

**1. WebSocket Server (Same server, different rooms)**
```javascript
// Join thought room for reactions/comments
socket.on('join_thought', (thoughtId) => {
  socket.join(`thought:${thoughtId}`);
});

// Add reaction
socket.on('add_reaction', async (data) => {
  const reaction = await saveReaction(data);
  
  // Broadcast to thought room
  io.to(`thought:${data.thoughtId}`)
    .emit('reaction_added', reaction);
});

// Add comment
socket.on('add_comment', async (data) => {
  const comment = await saveComment(data);
  
  io.to(`thought:${data.thoughtId}`)
    .emit('comment_added', comment);
});
```

**2. REST API Endpoints**
```
GET    /api/v1/thoughts                    # Get thoughts feed (paginated)
POST   /api/v1/thoughts                    # Create thought
GET    /api/v1/thoughts/:id                # Get thought by ID
PUT    /api/v1/thoughts/:id                # Update thought
DELETE /api/v1/thoughts/:id                # Delete thought

GET    /api/v1/thoughts/:id/reactions      # Get reactions
POST   /api/v1/thoughts/:id/reactions      # Add reaction
DELETE /api/v1/thoughts/:id/reactions/:id  # Remove reaction

GET    /api/v1/thoughts/:id/comments       # Get comments
POST   /api/v1/thoughts/:id/comments       # Add comment
PUT    /api/v1/comments/:id                 # Update comment
DELETE /api/v1/comments/:id                # Delete comment
```

**3. Polling Alternative for Thought Feed**
- If WebSocket is too heavy for feed updates:
  - Use REST API with pagination
  - Client polls every 30-60 seconds for new thoughts
  - Or use Server-Sent Events (SSE) for one-way updates

---

### Option 2: Server-Sent Events (SSE) + REST API

**Pros:**
- Simpler than WebSocket (one-way, server to client)
- Built on HTTP, easier to scale
- Automatic reconnection

**Cons:**
- One-way only (client must use REST for sending)
- Less efficient for bidirectional chat

**Implementation:**
```javascript
// SSE endpoint
app.get('/api/v1/thoughts/:id/stream', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  
  // Send updates when reactions/comments change
  const stream = thoughtUpdateStream(req.params.id);
  stream.on('data', (data) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  });
});
```

---

### Option 3: GraphQL Subscriptions

**Technology:** Apollo Server, Hasura, or custom GraphQL server

**Pros:**
- Type-safe subscriptions
- Single endpoint for all operations
- Built-in real-time capabilities

**Cons:**
- More complex setup
- Learning curve

**Implementation:**
```graphql
type Subscription {
  messageAdded(conversationId: ID!): Message!
  reactionAdded(thoughtId: ID!): Reaction!
  commentAdded(thoughtId: ID!): Comment!
}
```

---

## 🏗️ Recommended Tech Stack

### Backend Framework Options:

1. **Node.js + Express + Socket.io** ⭐ (Easiest migration)
   - Fastest to implement
   - Large ecosystem
   - Good WebSocket support

2. **Node.js + Fastify + Socket.io**
   - Higher performance than Express
   - Modern async/await patterns

3. **Python + FastAPI + WebSockets**
   - Great for ML/AI features
   - Type hints and validation
   - Fast performance

4. **Go + Gin/Echo + Gorilla WebSocket**
   - Highest performance
   - Low memory footprint
   - Great for high concurrency

5. **Rust + Actix Web + Tokio**
   - Maximum performance
   - Memory safety
   - Steeper learning curve

### Database Options:

1. **PostgreSQL** ⭐ (Recommended)
   - ACID compliance
   - JSON support for flexible schemas
   - Great for relational data (conversations, messages)
   - Extensions: `pg_notify` for real-time triggers

2. **MongoDB**
   - Document-based (similar to Firestore)
   - Easy migration from Firestore
   - Change streams for real-time updates

3. **Redis** (for caching + pub/sub)
   - Use for:
     - Message queue
     - Presence tracking
     - Real-time pub/sub
     - Session management

### Message Queue (Optional but Recommended):

- **RabbitMQ** or **Redis Pub/Sub**
  - Decouple WebSocket server from business logic
  - Scale WebSocket servers horizontally
  - Reliable message delivery

---

## 📐 Architecture Diagram

```
┌─────────────┐
│   Flutter   │
│    App      │
└──────┬──────┘
       │
       ├─── WebSocket ────┐
       │                  │
       └─── REST API ─────┤
                          │
                   ┌──────▼──────┐
                   │   API       │
                   │   Gateway   │
                   │  (Nginx/    │
                   │   Kong)     │
                   └──────┬──────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  WebSocket   │  │   REST API   │  │  Background  │
│   Server     │  │   Server     │  │   Workers    │
│  (Socket.io) │  │  (Express)   │  │  (Jobs)      │
└───────┬──────┘  └───────┬──────┘  └───────┬──────┘
        │                 │                 │
        └─────────────────┼─────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│ PostgreSQL   │  │    Redis     │  │   Storage    │
│  (Main DB)   │  │  (Cache +    │  │  (S3/GCS)    │
│              │  │   Pub/Sub)   │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🔄 Migration Strategy

### Phase 1: Setup Infrastructure
1. Set up PostgreSQL database
2. Set up Redis for caching/pub-sub
3. Create REST API server with basic endpoints
4. Set up WebSocket server

### Phase 2: Migrate Chat
1. Create messages/conversations tables
2. Implement REST endpoints for chat
3. Implement WebSocket for real-time messaging
4. Migrate existing Firestore data
5. Update Flutter app to use new API
6. Test thoroughly

### Phase 3: Migrate Thoughts
1. Create thoughts/reactions/comments tables
2. Implement REST endpoints
3. Implement WebSocket for reactions/comments
4. Migrate existing data
5. Update Flutter app
6. Test

### Phase 4: Optimize & Scale
1. Add caching layer (Redis)
2. Implement message queue
3. Add load balancing
4. Monitor and optimize

---

## 🔐 Authentication & Authorization

### JWT Tokens
```javascript
// Generate token on login
const token = jwt.sign(
  { userId: user.id, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);

// Verify on WebSocket connection
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  socket.userId = decoded.userId;
  next();
});
```

### REST API Auth
```javascript
// Middleware
const authenticate = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  req.user = decoded;
  next();
};
```

---

## 📊 Real-time Update Patterns

### Pattern 1: Room-based (Recommended for Chat)
```javascript
// Client joins conversation room
socket.emit('join_conversation', conversationId);

// Server broadcasts to room
io.to(`conversation:${conversationId}`).emit('new_message', message);
```

### Pattern 2: User-based (For notifications)
```javascript
// Track user connections
const userRooms = new Map(); // userId -> Set of socketIds

socket.on('connect', () => {
  userRooms.set(userId, socket.id);
});

// Send to specific user
io.to(userRooms.get(userId)).emit('notification', data);
```

### Pattern 3: Broadcast (For thought feed updates)
```javascript
// Broadcast to all connected clients
io.emit('new_thought', thought);

// Or to specific users (based on connections)
const connectedUserIds = getConnectedUserIds(thought.userId);
connectedUserIds.forEach(userId => {
  io.to(userRooms.get(userId)).emit('new_thought', thought);
});
```

---

## 🚀 Performance Considerations

### 1. Connection Pooling
- Use connection pools for database
- Limit concurrent WebSocket connections per user

### 2. Caching
- Cache frequently accessed data (user profiles, conversations)
- Use Redis for session management

### 3. Message Batching
- Batch multiple updates into single WebSocket message
- Reduce network overhead

### 4. Pagination
- Always paginate message history
- Use cursor-based pagination for better performance

### 5. Rate Limiting
- Limit API requests per user
- Prevent abuse

---

## 📱 Flutter Client Implementation

### WebSocket Client
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  
  void connect(String token) {
    socket = IO.io(
      'https://api.metal.com',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .build(),
    );
    
    socket.onConnect((_) {
      print('Connected');
    });
    
    socket.on('new_message', (data) {
      // Handle new message
    });
  }
  
  void sendMessage(String conversationId, String message) {
    socket.emit('send_message', {
      'conversationId': conversationId,
      'message': message,
    });
  }
}
```

### REST API Client
```dart
// Use existing ApiService or create new one
final response = await apiService.post(
  'messages',
  body: {
    'conversationId': conversationId,
    'message': message,
  },
);
```

---

## 🎯 Final Recommendation

**For Chat:** Use **WebSocket (Socket.io)** + REST API
- Real-time bidirectional communication
- Room-based messaging
- Typing indicators
- Read receipts

**For Thoughts:**
- **Reactions/Comments:** WebSocket (same server, different rooms)
- **Thought Feed:** REST API with polling (every 30-60s) OR WebSocket broadcast

**Tech Stack:**
- **Backend:** Node.js + Express + Socket.io
- **Database:** PostgreSQL (main) + Redis (cache/pub-sub)
- **Deployment:** Docker + Kubernetes or AWS ECS/Lambda

**Why This Approach:**
1. ✅ Real-time updates for chat and reactions/comments
2. ✅ Scalable architecture
3. ✅ Easy migration path from Firestore
4. ✅ Cost-effective (no Firestore read/write costs)
5. ✅ More control over data and queries
6. ✅ Better performance for complex queries

---

## 📚 Additional Resources

- [Socket.io Documentation](https://socket.io/docs/v4/)
- [PostgreSQL Real-time with LISTEN/NOTIFY](https://www.postgresql.org/docs/current/sql-notify.html)
- [Redis Pub/Sub](https://redis.io/docs/manual/pubsub/)
- [WebSocket Best Practices](https://www.ably.com/topic/websockets)


