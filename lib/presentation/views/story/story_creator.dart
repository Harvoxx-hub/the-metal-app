import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metal/presentation/viewmodels/story/story_viewmodel_providers.dart';

/// Story Creator - Interface for creating new stories
class StoryCreator extends ConsumerStatefulWidget {
  const StoryCreator({super.key});

  @override
  ConsumerState<StoryCreator> createState() => _StoryCreatorState();
}

class _StoryCreatorState extends ConsumerState<StoryCreator> {
  File? _selectedFile;
  String? _mediaType;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _mediaType = isVideo ? 'video' : 'image';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick media: $e')),
        );
      }
    }
  }

  Future<void> _createStory() async {
    if (_selectedFile == null || _mediaType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo or video')),
      );
      return;
    }

    final contentType = _mediaType == 'video' ? 'video/mp4' : 'image/jpeg';

    final success = await ref.read(storyViewModelProvider.notifier).createStory(
          file: _selectedFile!,
          mediaType: _mediaType!,
          contentType: contentType,
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story created successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage =
            ref.read(storyViewModelProvider).errorMessage ?? 'Failed to create story';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Story'),
        actions: [
          if (_selectedFile != null)
            TextButton(
              onPressed: storyState.isCreating ? null : _createStory,
              child: storyState.isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _selectedFile == null ? _buildMediaPicker() : _buildPreview(),
    );
  }

  Widget _buildMediaPicker() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a photo or video to share',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _pickMedia(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickMedia(ImageSource.gallery),
            icon: const Icon(Icons.photo),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
            icon: const Icon(Icons.videocam),
            label: const Text('Choose Video'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (_mediaType == 'image')
                Image.file(
                  _selectedFile!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              if (_mediaType == 'video')
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_outline, size: 80),
                      const SizedBox(height: 16),
                      const Text('Video Preview'),
                    ],
                  ),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                      _mediaType = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: 'Add a caption (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
