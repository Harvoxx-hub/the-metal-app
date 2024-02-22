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
  int? numberOfSparks;
  String? receiver;
  String? date;
  String? time;

  SparkModel({
    this.type,
    this.amount,
    this.numberOfSparks,
    this.receiver,
    this.date,
    this.time,
  });

  factory SparkModel.fromJson(Map<String, dynamic> json) =>
      _$SparkModelFromJson(json);

  Map<String, dynamic> toJson() => _$SparkModelToJson(this);
}
