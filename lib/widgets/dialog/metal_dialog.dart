import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

/// Metal Design System Dialog Widget
/// Follows the app's design guide with consistent styling
class MetalDialog extends StatelessWidget {
  /// Optional icon/image widget displayed at the top
  final Widget? icon;

  /// Dialog title (optional)
  final String? title;

  /// Dialog content widget
  final Widget content;

  /// Primary button text
  final String? primaryButtonText;

  /// Primary button callback
  final VoidCallback? onPrimaryPressed;

  /// Secondary button text
  final String? secondaryButtonText;

  /// Secondary button callback
  final VoidCallback? onSecondaryPressed;

  /// Whether dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  /// Custom padding (default: 24)
  final EdgeInsets? padding;

  /// Whether content is scrollable
  final bool isScrollable;

  /// Maximum height (default: 70% of screen)
  final double? maxHeight;

  /// Show close button in top right
  final bool showCloseButton;

  /// Close button callback
  final VoidCallback? onClose;

  /// Primary button color (default: metalPinkColour)
  final Color? primaryButtonColor;

  /// Primary button text color (default: metalWhite)
  final Color? primaryButtonTextColor;

  /// Secondary button color (default: transparent)
  final Color? secondaryButtonColor;

  /// Secondary button text color (default: metalBlack)
  final Color? secondaryButtonTextColor;

  /// Border radius (default: 20)
  final double borderRadius;

  /// Whether primary button is full width (default: true)
  final bool primaryButtonFullWidth;

  /// Text alignment for title and content (default: center)
  final TextAlign textAlign;

  const MetalDialog({
    super.key,
    this.icon,
    this.title,
    required this.content,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.barrierDismissible = true,
    this.padding,
    this.isScrollable = false,
    this.maxHeight,
    this.showCloseButton = false,
    this.onClose,
    this.primaryButtonColor,
    this.primaryButtonTextColor,
    this.secondaryButtonColor,
    this.secondaryButtonTextColor,
    this.borderRadius = 20,
    this.primaryButtonFullWidth = true,
    this.textAlign = TextAlign.center,
  });

  /// Show MetalDialog as a dialog
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? icon,
    String? title,
    required Widget content,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    EdgeInsets? padding,
    bool isScrollable = false,
    double? maxHeight,
    bool showCloseButton = false,
    VoidCallback? onClose,
    Color? primaryButtonColor,
    Color? primaryButtonTextColor,
    Color? secondaryButtonColor,
    Color? secondaryButtonTextColor,
    double borderRadius = 20,
    bool primaryButtonFullWidth = true,
    TextAlign textAlign = TextAlign.center,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => MetalDialog(
        icon: icon,
        title: title,
        content: content,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        barrierDismissible: barrierDismissible,
        padding: padding,
        isScrollable: isScrollable,
        maxHeight: maxHeight,
        showCloseButton: showCloseButton,
        onClose: onClose,
        primaryButtonColor: primaryButtonColor,
        primaryButtonTextColor: primaryButtonTextColor,
        secondaryButtonColor: secondaryButtonColor,
        secondaryButtonTextColor: secondaryButtonTextColor,
        borderRadius: borderRadius,
        primaryButtonFullWidth: primaryButtonFullWidth,
        textAlign: textAlign,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  if (icon != null) ...[
                    icon!,
                    const Gap(20),
                  ],
                  // Title
                  if (title != null) ...[
                    TextView(
                      text: title!,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.metalBlack,
                      textAlign: textAlign,
                    ),
                    const Gap(20),
                  ],
                  // Content
                  if (isScrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        child: content,
                      ),
                    )
                  else
                    content,
                  // Buttons
                  if (primaryButtonText != null ||
                      secondaryButtonText != null) ...[
                    const Gap(24),
                    _buildButtons(context),
                  ],
                ],
              ),
            ),
            // Close button
            if (showCloseButton)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  color: AppColors.metalBlack,
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final hasPrimary = primaryButtonText != null && onPrimaryPressed != null;
    final hasSecondary =
        secondaryButtonText != null && onSecondaryPressed != null;

    if (!hasPrimary && !hasSecondary) {
      return const SizedBox.shrink();
    }

    if (primaryButtonFullWidth && hasPrimary) {
      return Column(
        children: [
          BaseButton(
            onPressed: onPrimaryPressed,
            buttonText: primaryButtonText!,
            width: double.infinity,
            color: primaryButtonColor ?? AppColors.metalPinkColour,
            textColor: primaryButtonTextColor ?? AppColors.metalWhite,
            radius: borderRadius,
          ),
          if (hasSecondary) ...[
            const Gap(12),
            TextButton(
              onPressed: onSecondaryPressed,
              style: TextButton.styleFrom(
                foregroundColor:
                    secondaryButtonTextColor ?? AppColors.metalBlack,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: TextView(
                text: secondaryButtonText!,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: secondaryButtonTextColor ?? AppColors.metalBlack,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasSecondary) ...[
          TextButton(
            onPressed: onSecondaryPressed,
            style: TextButton.styleFrom(
              foregroundColor: secondaryButtonTextColor ?? AppColors.metalBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: TextView(
              text: secondaryButtonText!,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryButtonTextColor ?? AppColors.metalBlack,
            ),
          ),
          const Gap(8),
        ],
        if (hasPrimary)
          BaseButton(
            onPressed: onPrimaryPressed,
            buttonText: primaryButtonText!,
            width: null,
            color: primaryButtonColor ?? AppColors.metalPinkColour,
            textColor: primaryButtonTextColor ?? AppColors.metalWhite,
            radius: borderRadius,
          ),
      ],
    );
  }
}
