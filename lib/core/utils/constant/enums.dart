 enum MeltRequestState {
  noRequest, // No melt request exists between the users
  pending,   // A melt request exists but has not been reciprocated
  
  mutual,    // Both users have sent a melt request
}