// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:metal/features/authentication/provider/auth.notifier.dart';
// import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';
// import 'package:metal/features/chat/provider/unmelt.notifier.dart';
 
// import 'package:metal/features/dashboard.dart/dashboard.dart';
// import 'package:metal/features/home_page/domain/entries/thought.model.dart';
// import 'package:metal/features/notification/data/repositories/notification.repository.dart';
// import 'package:metal/features/notification/provider/notification.notifier.dart';
 
// import 'package:metal/fcm/abstract_notification_dispatcher.dart';
// import 'package:metal/fcm/models/notification_payload_model.dart';
// import 'package:metal/fcm/models/push_type.dart';
 
// import 'package:metal/fcm/models/notification_payload_model.dart';
// import 'package:metal/route/routes.dart';

// class NotificationDispatcher extends AbstractNotificationDispatcher {
//   NotificationDispatcher._();

//   static final NotificationDispatcher _instance = NotificationDispatcher._();

//   static NotificationDispatcher get instance => _instance;

//   @override
//   Future<void> dispatchNotification(
//     NotificationPayloadModel? model, {
//     bool removeUntil = false,
//   }) async {
//     if (!await _isUserAuthorized() || model == null) return null;

//     switch (model.action) {
//       case PushType.message:
//         return _handleMessageNotification(model, removeUntil);
//       case PushType.new_connection:
//         return _handleNewConnectionNotification(model, removeUntil);
//       case PushType.thought_created:
//         return _handleThoughtNotification(model, removeUntil);
//       case PushType.reaction_added:
//         return _handleReactionNotification(model, removeUntil);
//       case PushType.sparks_transaction:
//         return _handleSparksNotification(model, removeUntil);
//       default:
//         return null;
//     }
//   }

//   Future<void> _handleMessageNotification(
//     NotificationPayloadModel model,
//     bool removeUntil,
//   ) async {
//     final connectionId = model.data?['connectionId'] as String?;
//     if (connectionId == null) return;

//     final connection = await _getConnection(connectionId);
//     if (connection == null) return;

//     final navigator = _getNavigator();
//     if (navigator == null) return;

//     if (removeUntil) {
//       navigator.pushNamedAndRemoveUntil(
//         AppRoutes.dashboardPage,
//         (route) => false,
//       );
//     }

//     await Future.delayed(const Duration(milliseconds: 500));
//     navigator.pushNamed(
//       AppRoutes.chatWindowsPage,
//       arguments: connection,
//     );
//   }

//   Future<void> _handleNewConnectionNotification(
//     NotificationPayloadModel model,
//     bool removeUntil,
//   ) async {
//     final connectionId = model.data?['connectionId'] as String?;
//     if (connectionId == null) return;

//     final connection = await _getConnection(connectionId);
//     if (connection == null) return;

//     final navigator = _getNavigator();
//     if (navigator == null) return;

//     if (removeUntil) {
//       navigator.pushNamedAndRemoveUntil(
//        AppRoutes.dashboardPage,
//         (route) => false,
//       );
//     }

//     await Future.delayed(const Duration(milliseconds: 500));
//     navigator.pushNamed(
//       AppRoutes.meltMetal,,
//       arguments: connection,
//     );
//   }

//   Future<void> _handleThoughtNotification(
//     NotificationPayloadModel model,
//     bool removeUntil,
//   ) async {
//     final thoughtId = model.data?['thoughtId'] as String?;
//     if (thoughtId == null) return;

//     final thought = await _getThought(thoughtId);
//     if (thought == null) return;

//     final navigator = _getNavigator();
//     if (navigator == null) return;

//     if (removeUntil) {
//       navigator.pushNamedAndRemoveUntil(
//        AppRoutes.dashboardPage,
//         (route) => false,
//       );
//     }

//     await Future.delayed(const Duration(milliseconds: 500));
//     navigator.pushNamed(
//      AppRoutes.dashboardPage,
//       arguments: thought,
//     );
//   }

//   Future<void> _handleReactionNotification(
//     NotificationPayloadModel model,
//     bool removeUntil,
//   ) async {
//     final thoughtId = model.data?['thoughtId'] as String?;
//     if (thoughtId == null) return;

//     final thought = await _getThought(thoughtId);
//     if (thought == null) return;

//     final navigator = _getNavigator();
//     if (navigator == null) return;

//     if (removeUntil) {
//       navigator.pushNamedAndRemoveUntil(
//         DashboardPage.route,
//         (route) => false,
//       );
//     }

//     await Future.delayed(const Duration(milliseconds: 500));
//     navigator.pushNamed(
//       ThoughtPage.route,
//       arguments: thought,
//     );
//   }

//   Future<void> _handleSparksNotification(
//     NotificationPayloadModel model,
//     bool removeUntil,
//   ) async {
//     final transactionId = model.data?['transactionId'] as String?;
//     if (transactionId == null) return;

//     final transaction = await _getTransaction(transactionId);
//     if (transaction == null) return;

//     final navigator = _getNavigator();
//     if (navigator == null) return;

//     if (removeUntil) {
//       navigator.pushNamedAndRemoveUntil(
//         DashboardPage.route,
//         (route) => false,
//       );
//     }

//     await Future.delayed(const Duration(milliseconds: 500));
//     navigator.pushNamed(
//       WalletPage.route,
//       arguments: transaction,
//     );
//   }

//   Future<bool> _isUserAuthorized() async {
//     final authState = await _getAuthState();
//     return authState?.isAuthenticated ?? false;
//   }

//   Future<AuthState?> _getAuthState() async {
//     final container = ProviderContainer();
//     return container.read(authenticationNotifierProvider);
//   }

//   Future<ConnectionModel?> _getConnection(String connectionId) async {
//     final container = ProviderContainer();
//     final connections = await container.read(connectionNotifierProvider.future);
//     return connections.firstWhere(
//       (connection) => connection.id == connectionId,
//       orElse: () => null,
//     );
//   }

//   Future<ThoughtModel?> _getThought(String thoughtId) async {
//     final container = ProviderContainer();
//     final thoughts = await container.read(thoughtNotifierProvider.future);
//     return thoughts.firstWhere(
//       (thought) => thought.id == thoughtId,
//       orElse: () => null,
//     );
//   }

//   Future<TransactionModel?> _getTransaction(String transactionId) async {
//     final container = ProviderContainer();
//     final transactions = await container.read(walletNotifierProvider.future);
//     return transactions.firstWhere(
//       (transaction) => transaction.id == transactionId,
//       orElse: () => null,
//     );
//   }

//   NavigatorState? _getNavigator() {
//     return Navigator.of(navigatorKey.currentContext!);
//   }
// }
