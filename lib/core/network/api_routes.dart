/// API endpoint definitions
/// Centralized location for all API routes
/// Add your endpoints here as they become available
class ApiRoutes {
  // Base API version
  static const String apiVersion = '/api/v1';

  // Helper methods to build full paths
  static String buildPath(String endpoint) {
    return endpoint;
  }

  static String buildPathWithId(String endpoint, String id) {
    return '$endpoint/$id';
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String sendVerificationCode = '/auth/send-verification-code';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';

  // User/Profile endpoints
  static const String getUserProfile = '/users/me';
  static const String updateUserProfile = '/users/me';
  static const String completeProfile = '/users/me/profile/complete';
  static const String getUserById = '/users'; // /users/:id

  // Discovery endpoints
  static const String discoveryUsers = '/discovery/users';
  static const String discoveryUsersInRadius = '/discovery/users-in-radius';
  static const String discoverySwipe = '/discovery/swipe';
  static const String discoveryHistory = '/discovery/history';
  static const String discoveryUndo = '/discovery/undo';

  // Connection endpoints
  static const String connections = '/connections';
  static const String connectionById = '/connections'; // /connections/:id

  // Message endpoints
  static const String messages = '/messages';
  static const String messagesByConnection =
      '/messages'; // GET /messages/:connectionId
  static const String messageById = '/messages'; // GET/DELETE /messages/:id
  static const String messagesAudio =
      '/messages/audio'; // POST - upload audio message
  static const String markMessageRead = '/messages'; // PUT /messages/:id/read
  static const String markAllMessagesRead =
      '/messages'; // PUT /messages/:connectionId/read-all
  static const String promptReaction =
      '/messages/prompt-reaction'; // POST - send prompt reaction
  static const String directMessage =
      '/messages/direct-message'; // POST - send direct message from discovery
  static const String clearChat =
      '/connections'; // DELETE /connections/:id/messages

  // Block/Unmetal endpoints
  static const String blockConnection =
      '/connections'; // POST /connections/:id/block
  static const String unmeltAction =
      '/connections'; // POST /connections/:id/unmelt

  // Thought endpoints
  static const String thoughts = '/thoughts';
  static const String thoughtById = '/thoughts'; // GET/PUT/DELETE /thoughts/:id
  static const String thoughtReactions =
      '/thoughts'; // GET/POST /thoughts/:id/reactions
  static const String thoughtComments =
      '/thoughts'; // GET/POST /thoughts/:id/comments
  static const String deleteComment =
      '/thoughts'; // DELETE /thoughts/:id/comments/:commentId
  static const String commentReaction =
      '/thoughts'; // POST /thoughts/:id/comments/:commentId/reactions

  // Melt endpoints
  static const String melt = '/melt'; // POST - create melt request
  static const String meltStatus = '/melt/status'; // GET /melt/status/:userId
  static const String meltPending =
      '/melt/pending'; // GET - pending melt requests
  static const String meltCancel = '/melt'; // DELETE /melt/:userId
  static const String meltUnmelt = '/melt/unmelt'; // POST /melt/unmelt/:userId

  // Media endpoints
  static const String mediaUpload =
      '/media/upload-url'; // POST - request signed upload URL
  static const String mediaMakePublic =
      '/media/make-public'; // POST - make file publicly readable

  // Spark endpoints
  static const String sparks =
      '/sparks'; // GET - get balance and transaction history
  static const String sparksSend = '/sparks/send'; // POST - send sparks to user

  // Blocked users endpoints
  static const String blockedUsers =
      '/users/me/blocked'; // GET - list blocked users
  static const String blockUser =
      '/users/me/blocked'; // POST /users/me/blocked/:userId - block user
  static const String unblockUser =
      '/users/me/blocked'; // DELETE /users/me/blocked/:userId - unblock user

  // Account management endpoints
  static const String deleteAccount = '/users/me'; // DELETE - delete account

  // Notification endpoints
  static const String notifications =
      '/notifications'; // GET - get notifications with filters
  static const String notificationRead =
      '/notifications'; // PUT /notifications/:id/read - mark as read
  static const String notificationReadAll =
      '/notifications/read-all'; // PUT - mark all as read
  static const String notificationSettings =
      '/notifications/settings'; // PUT - update notification preferences
  static const String notificationDevices =
      '/notifications/devices'; // POST - register FCM device token
  static const String notificationAction =
      '/notifications'; // POST /notifications/:id/action - execute action

  // Story/Eyes endpoints
  static const String stories =
      '/stories'; // GET - get stories feed, POST - create story
  static const String storyById =
      '/stories'; // DELETE /stories/:id - delete story
  static const String storyView =
      '/stories'; // POST /stories/:id/view - mark story as viewed

  // Community endpoints
  static const String communities =
      '/communities'; // GET - get communities list, POST - create community
  static const String communityById =
      '/communities'; // GET /communities/:id - get community details
  static const String communityJoin =
      '/communities'; // POST /communities/:id/join - join community
  static const String communityLeave =
      '/communities'; // DELETE /communities/:id/leave - leave community
  static const String communityMembers =
      '/communities'; // GET /communities/:id/members - get community members

  // Work Email Verification endpoints
  static const String workEmailVerification =
      '/verification/work-email'; // POST - request work email verification
  static const String workEmailVerify =
      '/verification/work-email/verify'; // POST - verify work email code

  // Feedback endpoints
  static const String feedback = '/feedback'; // POST - submit feedback

  // Referral endpoints
  static const String referrals = '/referrals'; // GET - get referral info
  static const String applyReferral =
      '/referrals/apply'; // POST - apply referral code

  // Report endpoints
  static const String reportUser = '/reports/user'; // POST - report user
  static const String reportContent =
      '/reports/content'; // POST - report content (thought/comment/message)

  // Metal endpoints
  static const String metals = '/metals'; // GET - get all metals

  // Prompt endpoints
  static const String promptQuestions =
      '/prompts/questions'; // GET - get all questions
  static const String promptUser =
      '/prompts/user'; // GET /prompts/user/:userId, POST - save prompts

  // Meetup endpoints
  static const String meetups =
      '/meetups'; // GET - get meetups list, POST - create meetup
  static const String meetupById = '/meetups'; // GET/PUT/DELETE /meetups/:id
  static const String meetupRsvp = '/meetups'; // POST /meetups/:id/rsvp
  static const String meetupInvite = '/meetups'; // POST /meetups/:id/invite
  static const String meetupAttendees =
      '/meetups'; // GET /meetups/:id/attendees
  static const String meetupBroadcast =
      '/meetups'; // POST /meetups/:id/broadcast
}
