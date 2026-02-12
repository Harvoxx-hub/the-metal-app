import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/data/repositories/report/report_repository_providers.dart';
import 'package:metal/domain/entities/report_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';

/// Report User Dialog
/// Shows a dialog to report a user
class ReportUserDialog extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;

  const ReportUserDialog({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  final _reasonController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _selectedReason = 'Inappropriate behavior';

  final List<String> _reasons = [
    'Inappropriate behavior',
    'Harassment',
    'Spam',
    'Fake profile',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const TextView(
        text: 'Report User',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.userName != null)
                TextView(
                  text: 'Report ${widget.userName}',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              const Gap(16),
              const TextView(
                text: 'Reason',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Gap(8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _reasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedReason = value!);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(16),
              const TextView(
                text: 'Additional Information (Optional)',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Gap(8),
              TextFormField(
                controller: _additionalInfoController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Provide more details...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PlainButton(
          buttonText: 'Submit Report',
          loading: _isSubmitting,
          width: 120,
          height: 40,
          onPressed: _isSubmitting ? null : _handleSubmit,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final report = UserReportDto(
        userId: widget.userId,
        reason: _selectedReason,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );

      final result = await repository.reportUser(report: report);

      if (mounted) {
        if (result.isSuccess) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Report submitted successfully');
        } else {
          setState(() => _isSubmitting = false);
          Fluttertoast.showToast(msg: result.errorMessage ?? 'Failed to submit report');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }
}

/// Report Content Dialog
/// Shows a dialog to report content (thought, comment, message)
class ReportContentDialog extends ConsumerStatefulWidget {
  final ReportContentType contentType;
  final String contentId;
  final String? contentPreview;

  const ReportContentDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentPreview,
  });

  @override
  ConsumerState<ReportContentDialog> createState() =>
      _ReportContentDialogState();
}

class _ReportContentDialogState extends ConsumerState<ReportContentDialog> {
  final _additionalInfoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _selectedReason = 'Inappropriate content';

  final List<String> _reasons = [
    'Inappropriate content',
    'Hate speech',
    'Violence',
    'Spam',
    'Misinformation',
    'Other',
  ];

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextView(
        text: 'Report ${_getContentTypeName()}',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.contentPreview != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextView(
                    text: widget.contentPreview!,
                    fontSize: 12,
                    color: Colors.grey[700],
                    maxLines: 3,
                  ),
                ),
                const Gap(16),
              ],
              const TextView(
                text: 'Reason',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Gap(8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _reasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedReason = value!);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(16),
              const TextView(
                text: 'Additional Information (Optional)',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Gap(8),
              TextFormField(
                controller: _additionalInfoController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Provide more details...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PlainButton(
          buttonText: 'Submit Report',
          loading: _isSubmitting,
          width: 120,
          height: 40,
          onPressed: _isSubmitting ? null : _handleSubmit,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final report = ContentReportDto(
        contentType: widget.contentType,
        contentId: widget.contentId,
        reason: _selectedReason,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );

      final result = await repository.reportContent(report: report);

      if (mounted) {
        if (result.isSuccess) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Report submitted successfully');
        } else {
          setState(() => _isSubmitting = false);
          Fluttertoast.showToast(msg: result.errorMessage ?? 'Failed to submit report');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }

  String _getContentTypeName() {
    switch (widget.contentType) {
      case ReportContentType.thought:
        return 'Thought';
      case ReportContentType.comment:
        return 'Comment';
      case ReportContentType.message:
        return 'Message';
    }
  }
}

/// Helper function to show report user dialog
Future<void> showReportUserDialog(
  BuildContext context, {
  required String userId,
  String? userName,
}) {
  return showDialog(
    context: context,
    builder: (context) => ReportUserDialog(
      userId: userId,
      userName: userName,
    ),
  );
}

/// Helper function to show report content dialog
Future<void> showReportContentDialog(
  BuildContext context, {
  required ReportContentType contentType,
  required String contentId,
  String? contentPreview,
}) {
  return showDialog(
    context: context,
    builder: (context) => ReportContentDialog(
      contentType: contentType,
      contentId: contentId,
      contentPreview: contentPreview,
    ),
  );
}
