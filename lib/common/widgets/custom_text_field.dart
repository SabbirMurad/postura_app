import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isObscureText;
  final String? obscure;
  final Color? filColor;
  final Widget? prefixIcon;

  // final String? labelText;
  final String? hintText;
  final double? contentPaddingHorizontal;
  final double? contentPaddingVertical;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool isPassword;
  final bool? isEmail;
  final bool? filled;
  final bool? readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool? showLimit;
  final VoidCallback? onTap;

  // final bool isRequired;

  const CustomTextField({
    super.key,
    this.contentPaddingHorizontal,
    this.contentPaddingVertical,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.isEmail,
    this.onFieldSubmitted,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    this.filled = false,
    this.readOnly = false,
    this.obscure = '*',
    this.onChanged,
    this.filColor,
    // this.labelText,
    this.isPassword = false,
    this.onTap,
    this.showLimit,
    // this.isRequired = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (widget.labelText != null)
        //   _buildLabel(widget.labelText!, required: widget.isRequired),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscuringCharacter: widget.obscure!,
          minLines: widget.minLines,
          maxLines: widget.maxLines ?? 1,
          validator: widget.validator,
          buildCounter: widget.showLimit == true
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) {
                  return Text(
                    'text limit $currentLength/$maxLength',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.secondaryText,
                    ),
                  );
                }
              : null,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          obscureText: widget.isPassword ? obscureText : false,
          readOnly: widget.readOnly ?? false,
          onTap: widget.onTap,
          style: TextStyle(
            color: Color(0xFF545454),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: widget.filled,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.contentPaddingHorizontal ?? 15.w,
              vertical: widget.contentPaddingVertical ?? 15.w,
            ),
            fillColor: AppColors.onBoardingSurface,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.prefixIcon,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.border, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.border,  width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Color(0xFF8A8A8A),  width: 1.2),
            ),
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: toggle,
                    child: _suffixIcon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : widget.suffixIcon,
            prefixIconConstraints: BoxConstraints(
              minHeight: 24.w,
              minWidth: 24.w,
            ),
            // labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  _suffixIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.all(14.h),
      child: Icon(icon, size: 20.sp),
    );
  }

  // Widget _buildLabel(String text, {bool required = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12.0),
  //     child: Row(
  //       children: [
  //         Text(
  //           text,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             fontWeight: FontWeight.w500,
  //             color: AppColors.text,
  //           ),
  //         ),
  //         if (required)
  //           Text('*', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
  //       ],
  //     ),
  //   );
  // }
}
