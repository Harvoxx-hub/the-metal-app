import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/auth_remote_data_source.dart';
import 'package:metal/data/datasources/remote/profile_remote_data_source.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source_provider.dart';
import 'package:metal/data/datasources/remote/verification_remote_data_source.dart';
import 'package:metal/data/datasources/remote/feedback_remote_data_source.dart';
import 'package:metal/data/datasources/remote/referral_remote_data_source.dart';
import 'package:metal/data/datasources/remote/report_remote_data_source.dart';
import 'package:metal/data/datasources/remote/metal_remote_data_source.dart';

/// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(dioClientProvider));
});

/// Profile Remote Data Source Provider
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(
    ref.read(dioClientProvider),
    mediaDataSource: ref.read(mediaRemoteDataSourceProvider),
  );
});

/// Verification Remote Data Source Provider
final verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
  return VerificationRemoteDataSource(ref.read(dioClientProvider));
});

/// Feedback Remote Data Source Provider
final feedbackRemoteDataSourceProvider =
    Provider<FeedbackRemoteDataSource>((ref) {
  return FeedbackRemoteDataSource(ref.read(dioClientProvider));
});

/// Referral Remote Data Source Provider
final referralRemoteDataSourceProvider =
    Provider<ReferralRemoteDataSource>((ref) {
  return ReferralRemoteDataSource(ref.read(dioClientProvider));
});

/// Report Remote Data Source Provider
final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource(ref.read(dioClientProvider));
});

/// Metal Remote Data Source Provider
final metalRemoteDataSourceProvider = Provider<MetalRemoteDataSource>((ref) {
  return MetalRemoteDataSource(ref.read(dioClientProvider));
});
