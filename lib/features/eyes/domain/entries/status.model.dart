import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

part 'status.model.g.dart';

@JsonSerializable(explicitToJson: true)
class StatusModel {
  String? file;
  String? text;
  int? id;
  List? views;
  int? postedAt;
  bool? isActive;

  StatusModel({
    this.file,
    this.text,
    this.id,
    this.views,
    this.isActive,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
  String getFormattedDate() {
    if (postedAt == null) {
      return 'No date available';
    }
    final dateTime = DateTime.fromMillisecondsSinceEpoch(postedAt! * 1000);
    DateTime now = DateTime.now();
  Duration diff = now.difference(dateTime);
  
  if (diff.inDays == 0) {
    // Same day, show time as HH:mm
    return DateFormat('HH:mm').format(dateTime);
  } else if (diff.inDays == 1) {
    // Yesterday
    return 'Yesterday';
  } else {
    // Older dates, show date as dd/MM/yy
    return DateFormat('dd/MM/yy').format(dateTime);
  }
  }
}

@JsonSerializable()
class StatusData {
  final List<StatusModel> status;
  final String username;
  final Metal metal;

  StatusData({
    required this.status,
    required this.username,
    required this.metal,
  });

  factory StatusData.fromJson(Map<String, dynamic> json) =>
      _$StatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$StatusDataToJson(this);
}
