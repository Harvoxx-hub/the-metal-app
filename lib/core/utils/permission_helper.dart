import 'dart:io';
import 'package:flutter/material.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/dialog/enhanced.dialog.dart';
import '../../widgets/text_views.dart';

/// Result of a location permission check/request.
class LocationPermissionResult {
  final bool granted;
  final bool permanentlyDenied;

  const LocationPermissionResult({
    required this.granted,
    required this.permanentlyDenied,
  });
}

class PermissionHelper {
  static Future<bool> requestCallPermissions(BuildContext context) async {
    if (Platform.isIOS) {
      return await _requestIOSCallPermissions(context);
    } else if (Platform.isAndroid) {
      return await _requestAndroidCallPermissions(context);
    }
    return false;
  }

  static Future<bool> _requestIOSCallPermissions(BuildContext context) async {
    // Check current permission status
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final notificationStatus = await Permission.notification.status;

    // If camera and microphone are already granted, return true (notification is optional)
    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      // Optionally, request notification permission in the background (non-blocking)
      if (!notificationStatus.isGranted &&
          !notificationStatus.isPermanentlyDenied) {
        Permission.notification.request();
      }
      return true;
    }

    // Check for permanently denied permissions (only camera and microphone)
    final permanentlyDeniedPermissions = <Permission>[];
    if (cameraStatus.isPermanentlyDenied) {
      permanentlyDeniedPermissions.add(Permission.camera);
    }
    if (microphoneStatus.isPermanentlyDenied) {
      permanentlyDeniedPermissions.add(Permission.microphone);
    }

    // If any permissions are permanently denied, show settings dialog
    if (permanentlyDeniedPermissions.isNotEmpty) {
      final shouldOpenSettings = await _showPermissionSettingsDialog(context);

      if (shouldOpenSettings) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    // Request permissions that are not granted (only camera and microphone)
    final permissionsToRequest = <Permission>[];
    if (!cameraStatus.isGranted) {
      permissionsToRequest.add(Permission.camera);
    }
    if (!microphoneStatus.isGranted) {
      permissionsToRequest.add(Permission.microphone);
    }

    if (permissionsToRequest.isNotEmpty) {
      final results = await permissionsToRequest.request();
      final allGranted = results.values.every((s) => s.isGranted);

      // Optionally, request notification permission in the background (non-blocking)
      if (!notificationStatus.isGranted &&
          !notificationStatus.isPermanentlyDenied) {
        Permission.notification.request();
      }

      return allGranted;
    }

    return true;
  }

  static Future<bool> _requestAndroidCallPermissions(
      BuildContext context) async {
    // Check system alert window permission (required for call overlays)
    final systemAlertStatus = await Permission.systemAlertWindow.status;

    if (systemAlertStatus.isDenied) {
      // Show explanation dialog for Android users
      final shouldRequest =
          await _showAndroidPermissionExplanationDialog(context);

      if (shouldRequest) {
        final result = await Permission.systemAlertWindow.request();

        if (result.isPermanentlyDenied) {
          // Show settings dialog for permanently denied permission
          final shouldOpenSettings = await _showAndroidSettingsDialog(context);
          if (shouldOpenSettings) {
            await openAppSettings();
            return false;
          }
          return false;
        }

        return result.isGranted;
      } else {
        // User chose not to grant permission
        await _showAndroidLimitedFunctionalityDialog(context);
        return false;
      }
    } else if (systemAlertStatus.isPermanentlyDenied) {
      // Permission is permanently denied, show settings dialog
      final shouldOpenSettings = await _showAndroidSettingsDialog(context);
      if (shouldOpenSettings) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    return systemAlertStatus.isGranted;
  }

  static Future<bool> _showPermissionSettingsDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Permissions Required',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'Camera and microphone permissions are required for video calls.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  TextView(
                    text:
                        'Please enable them in Settings to use call features.',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              primaryButtonText: 'Open Settings',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Cancel',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  static Future<bool> _showAndroidPermissionExplanationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Display Over Apps',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'To show incoming calls when the app is in the background, we need permission to display over other apps.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'This allows you to:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'See incoming calls', 'Even when using other apps'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Answer calls quickly', 'Without opening the app'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Call notifications', 'Display properly on screen'),
                ],
              ),
              primaryButtonText: 'Grant Permission',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Not Now',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  static Future<bool> _showAndroidSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Permission Required',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'The "Display over other apps" permission is required for call features.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  TextView(
                    text: 'Please enable it in Settings:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Go to Settings', 'Apps & notifications'),
                  const SizedBox(height: 4),
                  _buildPermissionItem('Find this app', 'Metal'),
                  const SizedBox(height: 4),
                  _buildPermissionItem('Enable', 'Display over other apps'),
                ],
              ),
              primaryButtonText: 'Open Settings',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Cancel',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  static Future<void> _showAndroidLimitedFunctionalityDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedDialog(
          title: 'Limited Call Features',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextView(
                text:
                    'Without display permission, call features will be limited:',
                fontSize: 14,
              ),
              const SizedBox(height: 12),
              _buildPermissionItem('Incoming calls', 'May not show properly'),
              const SizedBox(height: 8),
              _buildPermissionItem(
                  'Call notifications', 'May not display correctly'),
              const SizedBox(height: 8),
              _buildPermissionItem(
                  'Background calls', 'May not work as expected'),
              const SizedBox(height: 8),
              TextView(
                text: 'You can enable this permission later in Settings.',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
          primaryButtonText: 'OK',
          onPrimaryButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  static Future<bool> checkCallPermissions() async {
    if (Platform.isIOS) {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      // Notification permission is optional for calls
      return cameraStatus.isGranted && microphoneStatus.isGranted;
    } else if (Platform.isAndroid) {
      final systemAlertStatus = await Permission.systemAlertWindow.status;
      return systemAlertStatus.isGranted;
    }
    return false;
  }

  // Add a method to show permission explanation dialog
  static Future<bool> showPermissionExplanationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Call Permissions',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text: 'To make and receive calls, we need access to:',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionItem('Camera', 'For video calls'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Microphone', 'For voice and video calls'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Notifications', 'For call notifications'),
                ],
              ),
              primaryButtonText: 'Grant Permissions',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Not Now',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  static Widget _buildPermissionItem(String permission, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: const BoxDecoration(
            color: AppColors.metalPinkColour,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: permission,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              TextView(
                text: description,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Add a method to show limited functionality dialog
  static Future<void> showLimitedFunctionalityDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedDialog(
          title: 'Limited Functionality',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextView(
                text:
                    'Some call features may be limited due to permission restrictions.',
                fontSize: 14,
              ),
              const SizedBox(height: 8),
              TextView(
                text: 'You can enable permissions later in Settings.',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
          primaryButtonText: 'OK',
          onPrimaryButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // Add a specific method for Android display over apps permission
  static Future<bool> requestAndroidDisplayPermission(
      BuildContext context) async {
    if (!Platform.isAndroid) {
      return true; // Not applicable on iOS
    }

    final systemAlertStatus = await Permission.systemAlertWindow.status;

    if (systemAlertStatus.isGranted) {
      return true;
    }

    if (systemAlertStatus.isPermanentlyDenied) {
      final shouldOpenSettings = await _showAndroidSettingsDialog(context);
      if (shouldOpenSettings) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    // Show explanation dialog
    final shouldRequest =
        await _showAndroidPermissionExplanationDialog(context);

    if (shouldRequest) {
      final result = await Permission.systemAlertWindow.request();

      if (result.isPermanentlyDenied) {
        final shouldOpenSettings = await _showAndroidSettingsDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
          return false;
        }
        return false;
      }

      return result.isGranted;
    } else {
      await _showAndroidLimitedFunctionalityDialog(context);
      return false;
    }
  }

  // Add a method to check if Android display permission is granted
  static Future<bool> hasAndroidDisplayPermission() async {
    if (!Platform.isAndroid) {
      return true; // Not applicable on iOS
    }

    final systemAlertStatus = await Permission.systemAlertWindow.status;
    return systemAlertStatus.isGranted;
  }

  // ============================================
  // Location Permission (permission_handler - single source of truth)
  // ============================================

  /// Check if location (when in use) permission is granted.
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Get current location permission status.
  static Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  /// Request location permission. Returns true if granted.
  /// Before showing "permanently denied" UI, call this once (e.g. "Ask every time" may show dialog).
  static Future<LocationPermissionResult> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return LocationPermissionResult(granted: true, permanentlyDenied: false);
    }
    if (status.isPermanentlyDenied) {
      return LocationPermissionResult(granted: false, permanentlyDenied: true);
    }
    status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return LocationPermissionResult(granted: true, permanentlyDenied: false);
    }
    if (status.isPermanentlyDenied) {
      return LocationPermissionResult(granted: false, permanentlyDenied: true);
    }
    return LocationPermissionResult(granted: false, permanentlyDenied: false);
  }

  /// Check if location is permanently denied (user must go to Settings).
  static Future<bool> isLocationPermanentlyDenied() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isPermanentlyDenied;
  }

  // Add a method specifically for incoming call scenarios
  static Future<bool> handleIncomingCallPermissions(
      BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android, display permission is critical for incoming calls
      final hasDisplayPermission = await hasAndroidDisplayPermission();

      if (!hasDisplayPermission) {
        // Show a more urgent dialog for incoming calls
        final shouldRequest = await _showIncomingCallPermissionDialog(context);

        if (shouldRequest) {
          return await requestAndroidDisplayPermission(context);
        } else {
          await _showIncomingCallLimitedDialog(context);
          return false;
        }
      }

      return true;
    } else if (Platform.isIOS) {
      // For iOS, check camera and microphone permissions
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        final shouldRequest = await _showIncomingCallPermissionDialog(context);

        if (shouldRequest) {
          final results =
              await [Permission.camera, Permission.microphone].request();
          return results[Permission.camera]!.isGranted &&
              results[Permission.microphone]!.isGranted;
        } else {
          await _showIncomingCallLimitedDialog(context);
          return false;
        }
      }

      return true;
    }

    return false;
  }

  static Future<bool> _showIncomingCallPermissionDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Incoming Call',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text: Platform.isAndroid
                        ? 'To answer incoming calls properly, we need permission to display over other apps.'
                        : 'To answer incoming calls, we need camera and microphone permissions.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'This ensures you can:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'See incoming calls', 'Even when using other apps'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Answer calls quickly', 'Without missing them'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Proper call display', 'Full call interface'),
                ],
              ),
              primaryButtonText: 'Grant Permission',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Skip',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  static Future<void> _showIncomingCallLimitedDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedDialog(
          title: 'Call Limitations',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextView(
                text:
                    'Without proper permissions, incoming calls may not display correctly.',
                fontSize: 14,
              ),
              const SizedBox(height: 12),
              TextView(
                text: 'You may:',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              _buildPermissionItem(
                  'Miss incoming calls', 'If app is in background'),
              const SizedBox(height: 8),
              _buildPermissionItem(
                  'Have limited call UI', 'Reduced functionality'),
              const SizedBox(height: 8),
              TextView(
                text:
                    'Consider enabling permissions in Settings for better call experience.',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
          primaryButtonText: 'OK',
          onPrimaryButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // Add a method to show permission explanation dialog only if not shown before
  static Future<bool> showPermissionExplanationDialogIfNeeded(
      BuildContext context) async {
    // Check if permissions are already granted
    final hasPermissions = await checkCallPermissions();

    if (hasPermissions) {
      return true; // No need to show dialog if permissions are already granted
    }

    // Show the explanation dialog
    return await showPermissionExplanationDialog(context);
  }

  // Add a method to request permissions only if needed
  static Future<bool> requestCallPermissionsIfNeeded(
      BuildContext context) async {
    // Check if permissions are already granted
    final hasPermissions = await checkCallPermissions();

    if (hasPermissions) {
      return true; // No need to request if already granted
    }

    // Request permissions
    return await requestCallPermissions(context);
  }

  /// Show location permission dialog
  /// Returns true if user wants to grant permission, false otherwise
  static Future<bool> showLocationPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Location Permission',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'Metal needs access to your location to provide you with better matches and location-based features.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'This allows you to:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Find nearby matches',
                      'Connect with people in your area'),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Location-based features',
                      'Enhanced discovery experience'),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Better recommendations',
                      'Personalized for your location'),
                ],
              ),
              primaryButtonText: 'Grant Permission',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Not Now',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  /// Show location permission settings dialog (for permanently denied)
  /// Returns true if user wants to open settings, false otherwise
  static Future<bool> showLocationSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Location Permission Required',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'Location permission is required to use Metal\'s location-based features. Please enable it in your device settings.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'To enable location permission:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Open Settings', 'Go to app settings'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Enable Location', 'Turn on location permission'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Return to App', 'Come back and try again'),
                ],
              ),
              primaryButtonText: 'Open Settings',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Cancel',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  /// Show location service disabled dialog
  static Future<void> showLocationServiceDisabledDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedDialog(
          title: 'Location Services Disabled',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextView(
                text:
                    'Location services are currently disabled on your device. Please enable them to use location-based features.',
                fontSize: 14,
              ),
              const SizedBox(height: 12),
              TextView(
                text: 'To enable location services:',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              _buildPermissionItem('Open Settings', 'Go to device settings'),
              const SizedBox(height: 8),
              _buildPermissionItem(
                  'Enable Location Services', 'Turn on location services'),
              const SizedBox(height: 8),
              _buildPermissionItem('Return to App', 'Come back and try again'),
            ],
          ),
          primaryButtonText: 'Open Settings',
          onPrimaryButtonPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
          secondaryButtonText: 'Cancel',
          onSecondaryButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // ============================================
  // iOS App Launch Permission Requests
  // ============================================

  /// Request microphone and camera permissions on iOS app launch
  /// Shows native iOS permission dialogs
  static Future<void> requestIOSMediaPermissionsOnLaunch() async {
    if (!Platform.isIOS) {
      return;
    }

    // Simply request both permissions - iOS will show dialogs if needed
    // If already granted or denied, this returns immediately
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  // ============================================
  // Voice Note / Microphone Permission Methods
  // ============================================

  /// Request microphone permission for voice notes with proper dialog flow
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    // Check current permission status
    var microphoneStatus = await Permission.microphone.status;

    // If already granted, return true
    if (microphoneStatus.isGranted) {
      return true;
    }

    // On iOS, if status shows denied but user might have granted it in settings,
    // try requesting to refresh the status (won't show dialog if already granted)
    if (Platform.isIOS && microphoneStatus.isDenied) {
      final refreshedStatus = await Permission.microphone.request();
      if (refreshedStatus.isGranted) {
        return true;
      }
      // Update status after refresh attempt
      microphoneStatus = await Permission.microphone.status;
    }

    // If permanently denied, show settings dialog
    if (microphoneStatus.isPermanentlyDenied) {
      final shouldOpenSettings = await _showMicrophoneSettingsDialog(context);

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    // Show explanation dialog first
    final shouldRequest =
        await _showMicrophonePermissionExplanationDialog(context);

    if (!shouldRequest) {
      return false;
    }

    // Request the permission
    final result = await Permission.microphone.request();

    // Check if permanently denied after request
    if (result.isPermanentlyDenied) {
      final shouldOpenSettings = await _showMicrophoneSettingsDialog(context);

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return result.isGranted;
  }

  /// Show microphone permission explanation dialog for voice notes
  static Future<bool> _showMicrophonePermissionExplanationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Microphone Access',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'To send voice messages, Metal needs access to your microphone.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'This allows you to:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Record voice notes',
                      'Send audio messages to your matches'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Express yourself', 'Share your voice instead of typing'),
                  const SizedBox(height: 8),
                  _buildPermissionItem('Personal connection',
                      'Create more meaningful conversations'),
                ],
              ),
              primaryButtonText: 'Allow Microphone',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Not Now',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  /// Show microphone settings dialog when permission is permanently denied
  static Future<bool> _showMicrophoneSettingsDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return EnhancedDialog(
              title: 'Microphone Permission Required',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text:
                        'Microphone access has been denied. To send voice messages, please enable it in Settings.',
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  TextView(
                    text: 'To enable microphone:',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Open Settings', 'Go to app permissions'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Enable Microphone', 'Turn on microphone access'),
                  const SizedBox(height: 8),
                  _buildPermissionItem(
                      'Return to App', 'Come back and try again'),
                ],
              ),
              primaryButtonText: 'Open Settings',
              onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: 'Cancel',
              onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  /// Check if microphone permission is granted
  /// This method checks the current status without requesting permission
  /// On iOS, if status is denied, it may try to refresh to get accurate state
  static Future<bool> hasMicrophonePermission() async {
    var microphoneStatus = await Permission.microphone.status;

    if (microphoneStatus.isGranted) {
      return true;
    }

    // On iOS, if status shows denied, try requesting to refresh status
    // This won't show a dialog if permission is already granted in settings
    if (Platform.isIOS && microphoneStatus.isDenied) {
      final refreshedStatus = await Permission.microphone.request();
      return refreshedStatus.isGranted;
    }

    return microphoneStatus.isGranted;
  }
}
