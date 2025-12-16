import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class LocationPermissionScreen extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback? onLocationGranted;

  const LocationPermissionScreen({
    super.key,
    this.isPermanentlyDenied = false,
    this.onLocationGranted,
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
              // Icon or illustration
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
                      _buildInstructionStep(
                        "1",
                        "Go to Settings",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        "2",
                        "Tap Metal",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        "3",
                        "Tap Location",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        "4",
                        "Select \"While Using the App\"",
                      ),
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
                        "1",
                        "Go to Settings > Metal > Location",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        "2",
                        "Enable Location While Using the App",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
    // Wait a bit for the system to update permission status
    await Future.delayed(const Duration(milliseconds: 500));

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission granted, notify callback
      if (onLocationGranted != null) {
        onLocationGranted!();
      }
      // Pop the screen
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}


