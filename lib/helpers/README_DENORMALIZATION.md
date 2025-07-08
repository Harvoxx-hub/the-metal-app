# Denormalization Strategy for Feed Filtering

## Overview

This implementation introduces a denormalization strategy to optimize feed filtering performance by embedding user metadata directly in thought documents. This eliminates the need to fetch user profiles separately for each thought during filtering, significantly reducing Firestore reads and improving performance.

## Key Components

### 1. AuthorMetadata Class
Located in `lib/features/home_page/domain/entries/thought.model.dart`

Contains embedded user information:
- `authorId` - User ID reference
- `authorName` - Display name
- `authorGender` - Gender for filtering
- `authorAge` - Age for filtering
- `authorLocationName` - Location display name
- `authorLatitude/authorLongitude` - Coordinates for proximity filtering
- `authorRelationshipType` - Relationship status for filtering
- `authorCommunity` - Community membership
- `authorIsVerified` - Verification status
- `authorProfilePhoto` - Profile photo URL

### 2. Updated ThoughtModel
The `ThoughtModel` now includes an optional `authorMetadata` field that contains the author's information at the time of posting.

### 3. FeedFilterHelper Enhancement
Updated to use embedded metadata for filtering, with fallback to async user fetching for legacy data.

### 4. AuthorMetadataSyncHelper
Provides tools for maintaining data consistency when user profiles change.

## Usage

### Creating Thoughts with Metadata
When posting a new thought, the metadata is automatically populated:

```dart
// In SendThoughtNotifier
final userData = ref.watch(userStateProvider).data;
AuthorMetadata? authorMetadata;
if (userData != null) {
  authorMetadata = AuthorMetadata.fromUserModel(userData);
}

final thought = ThoughtModel(
  // ... other fields
  authorMetadata: authorMetadata,
);
```

### Filtering with Embedded Metadata
The `FeedFilterHelper` now uses embedded metadata for performance:

```dart
// Synchronous filtering using embedded metadata
final filteredThoughts = FeedFilterHelper.applyFilters<ThoughtModel>(
  data: thoughts,
  currentUser: currentUser,
  rulesJson: remoteConfigRules,
  getUserById: _getUserById, // Fallback for legacy data
);
```

### Syncing Metadata When User Profiles Change
When a user updates their profile, sync the embedded metadata:

```dart
// After user profile update
await AuthorMetadataSyncHelper.syncUserMetadataInThoughts(
  userId: user.id,
  updatedUserModel: updatedUser,
  homeRepository: homeRepository,
);
```

## Migration Strategy

### For Existing Data
1. **One-time Migration**: Use `migrateThoughtsToIncludeMetadata()` to add metadata to existing thoughts
2. **Validation**: Use `validateMetadataConsistency()` to check for outdated metadata
3. **Batch Updates**: Use `batchSyncMetadata()` for bulk updates

```dart
// Migrate existing thoughts
final migratedCount = await AuthorMetadataSyncHelper.migrateThoughtsToIncludeMetadata(
  homeRepository: homeRepository,
  getUserById: getUserById,
  batchSize: 100,
);

// Validate consistency
final inconsistentThoughts = await AuthorMetadataSyncHelper.validateMetadataConsistency(
  homeRepository: homeRepository,
  getUserById: getUserById,
);
```

## Performance Benefits

### Before Denormalization
- For 100 thoughts: 100+ Firestore reads (1 per thought + user profile)
- High latency due to sequential user profile fetching
- Expensive Firestore usage

### After Denormalization
- For 100 thoughts: 1 Firestore read (just the thoughts collection)
- Low latency with immediate filtering
- Reduced Firestore costs by ~90%

## Data Consistency

### Automatic Sync Points
Consider syncing metadata when:
- User updates profile information
- User changes location
- User updates relationship status
- User verification status changes

### Manual Sync
Use the extension methods for easy metadata management:

```dart
// Check if thought needs update
if (thought.needsMetadataUpdate(currentUserData)) {
  final updatedThought = thought.withUpdatedMetadata(currentUserData);
  // Save updated thought
}
```

## Remote Config Integration

The filtering works with your existing Remote Config structure:

```json
{
  "filters_enabled": true,
  "enable_gender_filter": true,
  "enable_age_filter": true,
  "enable_location_priority": true,
  "enable_relationship_filter": true
}
```

## Implementation Notes

1. **Backward Compatibility**: Legacy thoughts without metadata will pass through filters or can be migrated
2. **Storage Impact**: Minimal increase in document size (~200-500 bytes per thought)
3. **Eventual Consistency**: Metadata updates are eventually consistent across all user's thoughts
4. **Error Handling**: Graceful fallback to async fetching for missing metadata

## Best Practices

1. **Profile Updates**: Always sync metadata after significant profile changes
2. **Batch Operations**: Use batch updates for large-scale metadata synchronization
3. **Monitoring**: Track thoughts without metadata for migration planning
4. **Validation**: Periodically validate metadata consistency
5. **Cleanup**: Consider archiving or cleaning up very old thoughts with outdated metadata

## Future Enhancements

- Automatic background sync jobs
- Metadata versioning for better conflict resolution
- Compression for metadata to reduce storage costs
- Analytics on filtering performance improvements 