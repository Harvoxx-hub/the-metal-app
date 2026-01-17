import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/thought/create_thought_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/views/thought/widgets/thought_text_input.dart';
import 'package:metal/presentation/views/thought/widgets/thought_audio_section.dart';

/// Create Thought Screen - Facebook-style thought creation
class CreateThoughtScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? communityMetadata;

  const CreateThoughtScreen({
    super.key,
    this.communityMetadata,
  });

  @override
  ConsumerState<CreateThoughtScreen> createState() => _CreateThoughtScreenState();
}

class _CreateThoughtScreenState extends ConsumerState<CreateThoughtScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (!_hasChanges) {
        setState(() {
          _hasChanges = true;
        });
      }
    });
    // Auto-focus text input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDiscardDialog(),
    );

    return shouldDiscard ?? false;
  }

  Widget _buildDiscardDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const TextView(
        text: 'Discard thought?',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: const TextView(
        text: 'You have unsaved changes. Are you sure you want to discard?',
        fontSize: 14,
        color: Colors.black87,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const TextView(
            text: 'Cancel',
            fontSize: 16,
            color: AppColors.metalPinkColour,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const TextView(
            text: 'Discard',
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(createThoughtViewModelProvider);
    final viewModel = ref.read(createThoughtViewModelProvider.notifier);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.metalBlack),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: TextView(
            text: widget.communityMetadata != null
                ? 'Post to ${widget.communityMetadata!['communityName'] ?? 'Community'}'
                : 'Create Thought',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBlack,
          ),
          actions: [
            TextButton(
              onPressed: viewModelState.canPost
                  ? () => _handlePost(viewModel)
                  : null,
              child: TextView(
                text: 'Post',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: viewModelState.canPost
                    ? AppColors.metalPinkColour
                    : Colors.grey,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Community indicator (if posting to community)
                      if (widget.communityMetadata != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.metalPinkColour.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.metalPinkColour.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 20,
                                color: AppColors.metalPinkColour,
                              ),
                              const Gap(8),
                              Expanded(
                                child: TextView(
                                  text: 'Posting to ${widget.communityMetadata!['communityName'] ?? 'Community'}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.metalPinkColour,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Text input section
                      ThoughtTextInput(
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: (text) {
                          viewModel.updateText(text);
                          setState(() {
                            _hasChanges = true;
                          });
                        },
                        maxLength: 1000,
                        hintText: widget.communityMetadata != null
                            ? 'Share your thoughts with the community...'
                            : "What's on your mind?",
                      ),
                      const Gap(16),
                      // Audio section
                      ThoughtAudioSection(
                        onAudioRecorded: (audioPath, duration) {
                          viewModel.updateAudio(audioPath, duration);
                          setState(() {
                            _hasChanges = true;
                          });
                        },
                        onAudioDeleted: () {
                          viewModel.clearAudio();
                          setState(() {
                            _hasChanges = true;
                          });
                        },
                        audioUrl: viewModelState.audioUrl,
                        audioDuration: viewModelState.audioDuration,
                      ),
                    ],
                  ),
                ),
              ),
              // Character counter and status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(
                      text: '${_textController.text.length}/1000',
                      fontSize: 12,
                      color: _textController.text.length > 900
                          ? Colors.orange
                          : Colors.grey[600],
                    ),
                    if (viewModelState.isPosting)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          Gap(8),
                          TextView(
                            text: 'Posting...',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePost(CreateThoughtViewModel viewModel) async {
    final success = await viewModel.postThought(
      communityMetadata: widget.communityMetadata,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thought posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final currentState = ref.read(createThoughtViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentState.errorMessage ?? 'Failed to post thought'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

