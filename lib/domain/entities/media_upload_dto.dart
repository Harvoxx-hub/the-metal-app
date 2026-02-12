/// Media upload URL response data transfer object
class MediaUploadDto {
  final String uploadUrl; // S3 presigned URL for uploading
  final String publicUrl; // Public URL to use in API requests after upload

  MediaUploadDto({
    required this.uploadUrl,
    required this.publicUrl,
  });
}

/// Media upload request data
class MediaUploadRequestDto {
  final MediaUploadType mediaType;
  final MediaUploadPurpose purpose;
  final String contentType; // MIME type (e.g., 'image/jpeg', 'video/mp4')
  final int fileSize; // File size in bytes

  MediaUploadRequestDto({
    required this.mediaType,
    required this.purpose,
    required this.contentType,
    required this.fileSize,
  });
}

/// Media upload types
enum MediaUploadType {
  image,
  video,
  audio,
}

/// Media upload purposes
enum MediaUploadPurpose {
  profile,
  thought,
  message,
  story,
}
