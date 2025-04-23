enum MeltRequestState {
  noRequest, // No melt request exists between the users
  pending, // A melt request exists but has not been reciprocated
 
  unmelted, // The melt action has been reverted
  connected, // Users are already connected (new state for the updated flow)
}
 

// New enum for connection status
 
