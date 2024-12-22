//  {
//             "type": "Purchase",
//             "amount": "322",
//             "numberOfSparks": 944,
//             "receiver": null,
//             "date": "15/02/2024",
//             "time": "11:32 AM"
//         },

import 'package:json_annotation/json_annotation.dart';

part 'spark.model.g.dart';

@JsonSerializable(explicitToJson: true)
class SparkModel {
  String? type;
  String? amount;
  int? sparks;
  String? receiverId;

  String? userId;
  String? timestamp;

  SparkModel(
      {this.type,
      this.amount,
      this.sparks,
      this.receiverId,
      this.userId,
      this.timestamp});

  factory SparkModel.fromJson(Map<String, dynamic> json) =>
      _$SparkModelFromJson(json);

  Map<String, dynamic> toJson() => _$SparkModelToJson(this);
}
