import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/selection_chip.dart';
import 'package:posture_detector_app/constants/colors.dart';

enum _HeightUnit { cm, ftIn }

/// Height input — cm by default, with an optional ft/in toggle. Always
/// reports the canonical value in centimeters via [onChanged] (or `null`
/// while the field is empty/invalid).
class HeightInputField extends StatefulWidget {
  final double? initialHeightCm;
  final ValueChanged<double?> onChanged;

  const HeightInputField({
    super.key,
    this.initialHeightCm,
    required this.onChanged,
  });

  @override
  State<HeightInputField> createState() => _HeightInputFieldState();
}

class _HeightInputFieldState extends State<HeightInputField> {
  _HeightUnit _unit = _HeightUnit.cm;
  late final TextEditingController _cmController;
  late final TextEditingController _ftController;
  late final TextEditingController _inController;

  @override
  void initState() {
    super.initState();
    final cm = widget.initialHeightCm;
    _cmController = TextEditingController(
      text: (cm != null && cm > 0) ? cm.round().toString() : '',
    );

    String ftText = '';
    String inText = '';
    if (cm != null && cm > 0) {
      final totalInches = cm / 2.54;
      final ft = (totalInches / 12).floor();
      final inch = (totalInches - ft * 12).round();
      ftText = '$ft';
      inText = '$inch';
    }
    _ftController = TextEditingController(text: ftText);
    _inController = TextEditingController(text: inText);
  }

  @override
  void dispose() {
    _cmController.dispose();
    _ftController.dispose();
    _inController.dispose();
    super.dispose();
  }

  void _emit() {
    if (_unit == _HeightUnit.cm) {
      widget.onChanged(double.tryParse(_cmController.text.trim()));
      return;
    }
    final ftText = _ftController.text.trim();
    final inText = _inController.text.trim();
    if (ftText.isEmpty && inText.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final ft = double.tryParse(ftText) ?? 0;
    final inch = double.tryParse(inText) ?? 0;
    widget.onChanged((ft * 12 + inch) * 2.54);
  }

  void _setUnit(_HeightUnit unit) {
    if (_unit == unit) return;
    setState(() => _unit = unit);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Height',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _setUnit(_HeightUnit.cm),
                  child: SelectionChip(
                    title: 'cm',
                    selected: _unit == _HeightUnit.cm,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _setUnit(_HeightUnit.ftIn),
                  child: SelectionChip(
                    title: 'ft/in',
                    selected: _unit == _HeightUnit.ftIn,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_unit == _HeightUnit.cm)
          CustomTextField(
            controller: _cmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
            ],
            hintText: 'Height in cm (e.g. 175)',
            onChanged: (_) => _emit(),
          )
        else
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _ftController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: 'ft',
                  onChanged: (_) => _emit(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _inController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: 'in',
                  onChanged: (_) => _emit(),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
