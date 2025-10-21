import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

/// Represents the structure of the explore feed with featured and unfeatured sections
class ExploreFeedModel {
  final List<ThoughtModel> featuredThoughts;
  final List<ThoughtModel> unfeaturedThoughts;
  final bool showDivider;

  const ExploreFeedModel({
    required this.featuredThoughts,
    required this.unfeaturedThoughts,
    required this.showDivider,
  });

  /// Total count including divider if needed
  int get totalItemCount {
    final baseCount = featuredThoughts.length + unfeaturedThoughts.length;
    return showDivider ? baseCount + 1 : baseCount;
  }

  /// Check if the index is the divider position
  bool isDividerIndex(int index) {
    return showDivider && index == featuredThoughts.length;
  }

  /// Get the thought at a specific index, accounting for the divider
  ThoughtModel? getThoughtAtIndex(int index) {
    if (index < featuredThoughts.length) {
      return featuredThoughts[index];
    } else if (showDivider && index == featuredThoughts.length) {
      return null; // This is the divider position
    } else {
      final unfeaturedIndex = showDivider
          ? index - featuredThoughts.length - 1
          : index - featuredThoughts.length;

      if (unfeaturedIndex >= 0 && unfeaturedIndex < unfeaturedThoughts.length) {
        return unfeaturedThoughts[unfeaturedIndex];
      }
    }
    return null;
  }

  /// Check if we have any thoughts to display
  bool get isEmpty => featuredThoughts.isEmpty && unfeaturedThoughts.isEmpty;

  /// Check if we only have featured thoughts
  bool get hasOnlyFeatured =>
      featuredThoughts.isNotEmpty && unfeaturedThoughts.isEmpty;

  /// Check if we only have unfeatured thoughts
  bool get hasOnlyUnfeatured =>
      featuredThoughts.isEmpty && unfeaturedThoughts.isNotEmpty;
}
