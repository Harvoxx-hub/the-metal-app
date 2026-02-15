import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metal/core/utils/permission_helper.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

/// Signature for when location permission is granted (caller may update profile then pop).
typedef OnLocationGranted = Future<void> Function()?;

/// Location permission screen
/// Shows when user hasn't granted location permissions.
/// [onEnablePressed] when set and not permanently denied: show "Enable Location" button (request in-app).
/// [onLocationGranted] called when permission is granted (e.g. after returning from Settings); awaited before pop.
class LocationPermissionScreen extends StatelessWidget {
  final bool isPermanentlyDenied;
  final OnLocationGranted onLocationGranted;
  final VoidCallback? onEnablePressed;

  const LocationPermissionScreen({
    super.key,
    this.isPermanentlyDenied = false,
    this.onLocationGranted,
    this.onEnablePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  size: 60,
                  color: AppColors.metalPinkColour,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const TextView(
                text: "Unable to connect",
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Description
              TextView(
                text: isPermanentlyDenied
                    ? "To use Metal, you need to enable your location sharing so we can show you who's around."
                    : "To use Metal, you need to enable your location sharing so we can show you who's around.",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Instructions
              if (isPermanentlyDenied) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionStep("1", "Go to Settings"),
                      const SizedBox(height: 12),
                      _buildInstructionStep("2", "Tap Metal"),
                      const SizedBox(height: 12),
                      _buildInstructionStep("3", "Tap Location"),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                          "4", 'Select "While Using the App"'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionStep(
                          "1", "Go to Settings > Metal > Location"),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                          "2", "Enable Location While Using the App"),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Enable Location (in-app request) when not permanently denied
              if (!isPermanentlyDenied && onEnablePressed != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: BaseButton(
                    buttonText: "Enable Location",
                    onPressed: onEnablePressed,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Open Settings Button
              SizedBox(
                width: double.infinity,
                child: BaseButton(
                  buttonText: "Open Settings",
                  onPressed: () async {
                    await openAppSettings();
                    // Check if permission was granted after returning from settings
                    if (context.mounted) {
                      _checkPermissionAfterSettings(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.metalPinkColour,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: TextView(
              text: number,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextView(
            text: text,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _checkPermissionAfterSettings(BuildContext context) async {
    // Poll a few times: system may take a moment to update after returning from Settings
    const initialDelay = Duration(milliseconds: 800);
    const pollInterval = Duration(milliseconds: 600);
    const maxAttempts = 3;

    await Future.delayed(initialDelay);

    for (var attempt = 0; attempt < maxAttempts && context.mounted; attempt++) {
      if (await PermissionHelper.hasLocationPermission()) {
        await onLocationGranted?.call();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(pollInterval);
      }
    }
  }
}
