import 'package:metal/domain/entities/media_upload_dto.dart';

/// Media upload URL response model from API
class MediaUploadModel {
  final String uploadUrl;
  final String publicUrl;

  MediaUploadModel({
    required this.uploadUrl,
    required this.publicUrl,
  });

  factory MediaUploadModel.fromJson(Map<String, dynamic> json) {
    return MediaUploadModel(
      uploadUrl: json['uploadUrl'] as String,
      publicUrl: json['publicUrl'] as String,
    );
  }

  /// Convert to domain DTO
  MediaUploadDto toDomain() {
    return MediaUploadDto(
      uploadUrl: uploadUrl,
      publicUrl: publicUrl,
    );
  }
}

/// Media upload request model
class MediaUploadRequestModel {
  final String mediaType;
  final String purpose;
  final String contentType;
  final int fileSize;

  MediaUploadRequestModel({
    required this.mediaType,
    required this.purpose,
    required this.contentType,
    required this.fileSize,
  });

  factory MediaUploadRequestModel.fromDto(MediaUploadRequestDto dto) {
    return MediaUploadRequestModel(
      mediaType: _mediaTypeToString(dto.mediaType),
      purpose: _purposeToString(dto.purpose),
      contentType: dto.contentType,
      fileSize: dto.fileSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaType': mediaType,
      'purpose': purpose,
      'contentType': contentType,
      'fileSize': fileSize,
    };
  }

  static String _mediaTypeToString(MediaUploadType type) {
    switch (type) {
      case MediaUploadType.image:
        return 'image';
      case MediaUploadType.video:
        return 'video';
      case MediaUploadType.audio:
        return 'audio';
    }
  }

  static String _purposeToString(MediaUploadPurpose purpose) {
    switch (purpose) {
      case MediaUploadPurpose.profile:
        return 'profile';
      case MediaUploadPurpose.thought:
        return 'thought';
      case MediaUploadPurpose.message:
        return 'message';
      case MediaUploadPurpose.story:
        return 'story';
    }
  }
}
