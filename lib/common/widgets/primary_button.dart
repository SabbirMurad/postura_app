import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:posture_detector_app/constants/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final bool loading;
  final String text;
  final Color? textColor;
  final void Function()? onTap;
  final bool shadow;
  final bool disabled;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final Widget? tailing;
  final EdgeInsetsGeometry? margin;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? prefixIconSize;

  const PrimaryButton({
    super.key,
    this.loading = false,
    this.disabled = false,
    required this.text,
    this.height,
    this.width,
    this.leading,
    this.tailing,
    this.borderRadius,
    this.onTap,
    this.shadow = true,
    this.backgroundColor,
    this.textStyle,
    this.margin,
    this.textColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixIconSize,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.loading) return;
        widget.onTap?.call();
      },
      child: Container(
        margin: widget.margin,
        width: widget.width ?? double.infinity,
        height: widget.height ?? 56.h,
        decoration: BoxDecoration(
          color: widget.disabled ? Color(0xffF9F4FF) : widget.backgroundColor,
          gradient: widget.disabled
              ? null
              : widget.backgroundColor == null
              ? LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xff842AC8), Color(0xffB95DFF)],
                )
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(14.r),
        ),
        child: Center(
          child: widget.loading
              ? SizedBox(
                  height: 24.w,
                  child: SpinKitWave(color: AppColors.surface, size: 24.w),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.leading != null)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: widget.leading!,
                      ),
                    if (widget.prefixIcon != null)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(
                          widget.prefixIcon,
                          color: widget.prefixIconColor ?? AppColors.surface,
                          size: widget.prefixIconSize ?? 20.sp,
                        ),
                      ),
                    Text(
                      widget.text,
                      style:
                          widget.textStyle ??
                          TextStyle(
                            color: widget.textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.tailing != null)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: widget.tailing!,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
