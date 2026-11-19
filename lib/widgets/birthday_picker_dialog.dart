import 'package:flutter/material.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

/// Custom birthday picker dialog matching app design.
/// No external date picker package — day/month/year dropdowns with 18+ validation.
Future<DateTime?> showBirthdayPickerDialog(
  BuildContext context, {
  String title = 'Select date of birth',
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  DateTime? initialDate,
  int minimumAge = 18,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => _BirthdayPickerDialog(
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialDate: initialDate,
      minimumAge: minimumAge,
    ),
  );
}

class _BirthdayPickerDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final DateTime? initialDate;
  final int minimumAge;

  const _BirthdayPickerDialog({
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    this.initialDate,
    this.minimumAge = 18,
  });

  @override
  State<_BirthdayPickerDialog> createState() => _BirthdayPickerDialogState();
}

class _BirthdayPickerDialogState extends State<_BirthdayPickerDialog> {
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late int _day;
  late int _month; // 1-based
  late int _year;

  DateTime get _now => DateTime.now();
  int get _maxYear => _now.year - widget.minimumAge;
  int get _minYear => _now.year - 120;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate;
    if (initial != null && _isValidBirthDate(initial)) {
      _day = initial.day;
      _month = initial.month;
      _year = initial.year;
    } else {
      // Default: 25 years ago, first of month
      _year = _maxYear - 7;
      _month = 1;
      _day = 1;
      _clampDay();
    }
  }

  bool _isValidBirthDate(DateTime d) {
    if (d.year > _maxYear || d.year < _minYear) return false;
    if (d.month < 1 || d.month > 12) return false;
    final maxD = _daysInMonth(_month, _year);
    return d.day >= 1 && d.day <= maxD;
  }

  int _daysInMonth(int month, int year) {
    if (month == 2) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const days = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  void _clampDay() {
    final maxD = _daysInMonth(_month, _year);
    if (_day > maxD) _day = maxD;
  }

  DateTime get _selectedDate => DateTime(_year, _month, _day);

  int get _age {
    final today = _now;
    int age = today.year - _year;
    if (today.month < _month || (today.month == _month && today.day < _day)) {
      age--;
    }
    return age;
  }

  bool get _isAtLeastMinimumAge => _age >= widget.minimumAge;

  @override
  Widget build(BuildContext context) {
    final maxDay = _daysInMonth(_month, _year);
    final days = List.generate(maxDay, (i) => i + 1);
    final months = List.generate(12, (i) => i + 1);
    final years = List.generate(_maxYear - _minYear + 1, (i) => _maxYear - i);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.metalBlack.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: TextView(
                text: widget.title,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.metalBlack,
              ),
            ),
            const SizedBox(height: 8),
            // Day / Month / Year row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _DropdownSegment<int>(
                      value: _day,
                      items: days,
                      label: 'Day',
                      itemBuilder: (d) => d.toString().padLeft(2, '0'),
                      onChanged: (v) => setState(() {
                        _day = v!;
                        _clampDay();
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _DropdownSegment<int>(
                      value: _month,
                      items: months,
                      label: 'Month',
                      itemBuilder: (m) => _monthNames[m - 1],
                      onChanged: (v) => setState(() {
                        _month = v!;
                        _clampDay();
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownSegment<int>(
                      value: _year,
                      items: years,
                      label: 'Year',
                      itemBuilder: (y) => y.toString(),
                      onChanged: (v) => setState(() {
                        _year = v!;
                        _clampDay();
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Age hint or error
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _isAtLeastMinimumAge
                    ? "You'll be $_age years old"
                    : 'You must be at least ${widget.minimumAge} years old',
                style: TextStyle(
                  fontSize: 14,
                  color: _isAtLeastMinimumAge
                      ? AppColors.metalPinkColour
                      : AppColors.metalRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.metalBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: TextView(
                        text: widget.cancelLabel,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BaseButton(
                      buttonText: widget.confirmLabel,
                      enabled: _isAtLeastMinimumAge,
                      onPressed: () => Navigator.of(context).pop(_selectedDate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownSegment<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String label;
  final String Function(T) itemBuilder;
  final ValueChanged<T?> onChanged;

  const _DropdownSegment({
    required this.value,
    required this.items,
    required this.label,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: TextView(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.metalPinkColour.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.metalPinkColour,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: TextView(
                    text: itemBuilder(item),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalBlack,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
