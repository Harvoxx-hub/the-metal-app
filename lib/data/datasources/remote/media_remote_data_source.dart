import 'dart:io';
import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';

/// Remote data source for media operations
/// Handles media upload requests using signed URLs (S3 presigned pattern)
class MediaRemoteDataSource {
  final DioClient _client;

  MediaRemoteDataSource(this._client);

  /// Request a signed upload URL for media
  /// Returns uploadUrl (for uploading file) and publicUrl (for API references)
  ///
  /// Usage:
  /// 1. Call this method to get upload URL
  /// 2. Upload file to uploadUrl directly
  /// 3. Use publicUrl in subsequent API calls (e.g., createThought, updateProfile)
  Future<MediaUploadResponse> requestUploadUrl({
    required MediaType mediaType,
    required MediaPurpose purpose,
    required String contentType,
    required int fileSize,
  }) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.mediaUpload),
      data: {
        'mediaType': mediaType.value,
        'purpose': purpose.value,
        'contentType': contentType,
        'fileSize': fileSize,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MediaUploadResponse.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get upload URL');
  }

  /// Upload file to the presigned URL
  /// This uploads directly to cloud storage (S3, GCS, etc.)
  Future<void> uploadFileToUrl(String uploadUrl, File file, String contentType) async {
    try {
      // Create a separate Dio instance for direct upload (no auth headers)
      final dio = Dio();

      final fileBytes = await file.readAsBytes();

      final response = await dio.put(
        uploadUrl,
        data: Stream.fromIterable(fileBytes.map((e) => [e])),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileBytes.length,
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Complete upload flow: Request URL -> Upload File -> Return public URL
  /// This is a convenience method that combines both steps
  Future<String> uploadMedia({
    required File file,
    required MediaType mediaType,
    required MediaPurpose purpose,
    required String contentType,
  }) async {
    final fileSize = await file.length();

    // Step 1: Request presigned URL
    final uploadResponse = await requestUploadUrl(
      mediaType: mediaType,
      purpose: purpose,
      contentType: contentType,
      fileSize: fileSize,
    );

    // Step 2: Upload file to presigned URL
    await uploadFileToUrl(
      uploadResponse.uploadUrl,
      file,
      contentType,
    );

    // Step 3: Return public URL for use in API requests
    return uploadResponse.publicUrl;
  }
}

/// Media types supported by the API
enum MediaType {
  image('image'),
  video('video'),
  audio('audio');

  final String value;
  const MediaType(this.value);
}

/// Media purposes (determines upload folder and access control)
enum MediaPurpose {
  profile('profile'),
  thought('thought'),
  message('message'),
  story('story');

  final String value;
  const MediaPurpose(this.value);
}

/// Response from media upload URL request
class MediaUploadResponse {
  final String uploadUrl;  // S3 presigned URL for direct upload
  final String publicUrl;  // Public URL to reference in API calls

  MediaUploadResponse({
    required this.uploadUrl,
    required this.publicUrl,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      uploadUrl: json['uploadUrl'] as String,
      publicUrl: json['publicUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadUrl': uploadUrl,
      'publicUrl': publicUrl,
    };
  }
}
