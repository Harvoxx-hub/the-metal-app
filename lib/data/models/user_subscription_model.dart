/// User Subscription Model
/// Maps subscription data from API/Firestore
class UserSubscriptionModel {
  final String id;
  final String planName;
  final int duration;
  final double price;
  final List<String> metaData;
  final int startingDate;
  final int endingDate;

  UserSubscriptionModel({
    required this.id,
    required this.planName,
    required this.duration,
    required this.price,
    required this.metaData,
    required this.startingDate,
    required this.endingDate,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Subscription data is required');
    }

    return UserSubscriptionModel(
      id: json['id'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      metaData: json['metaData'] != null
          ? (json['metaData'] as List).map((e) => e.toString()).toList()
          : [],
      startingDate: json['startingDate'] as int? ?? 0,
      endingDate: json['endingDate'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'duration': duration,
      'price': price,
      'metaData': metaData,
      'startingDate': startingDate,
      'endingDate': endingDate,
    };
  }
}
