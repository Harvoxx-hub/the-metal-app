import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metal/presentation/viewmodels/profile/profile_photo_viewmodel.dart';

/// Utility class for picking images.
class ImagePickerUtil {
  /// Opens a modal bottom sheet to choose between camera and gallery,
  /// picks an image, and uploads it using the profileImageProvider.
  static Future<void> pickImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();

    final option = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (option != null) {
      final pickedFile = await picker.pickImage(source: option);
      if (pickedFile != null) {
        // Consider adding loading indicators here if needed
        try {
          await ref
              .read(profilePhotoViewModelProvider.notifier)
              .uploadProfilePhoto(
                photoFile: File(pickedFile.path),
                contentType: 'image/jpeg',
              );
          // Optionally, show a success message or handle the result
        } catch (e) {
          // Optionally, show an error message
          print('Error uploading image: $e');
        }
      }
    }
  }
}
