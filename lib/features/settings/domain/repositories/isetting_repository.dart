import 'package:metal/core/model/responces.dart';

abstract class ISettingRepository {
  // Basic block/unblock operations
  Future<Responses> blockUser(String id, String userName);
  Future<Responses> unBlockUser(String id);
  Future<Responses> getBlockedUsers();

  // Enhanced block operations
  Future<Responses> blockUserWithReason(
      {required String id,
      required String userName,
      required String reasonCode,
      String? customReason,
      bool isReported = false,
      String? reportDetails});

  Future<Responses> getBlockReasons(String blockedUserId);

  Future<Responses> updateBlockStatus(
      {required String blockedUserId,
      required bool isTemporary,
      String? expiryDate});

  // Block privacy settings
  Future<Responses> updateBlockPrivacySettings(
      {required String blockedUserId,
      required Map<String, bool> privacySettings});
}
