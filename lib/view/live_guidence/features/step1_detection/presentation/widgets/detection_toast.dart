import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class DetectionToast extends StatefulWidget {
  const DetectionToast({super.key, required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  State<DetectionToast> createState() => _DetectionToastState();
}

class _DetectionToastState extends State<DetectionToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.confirmGreen,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.confirmGreen.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 7.w),
              Text(
                widget.message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToastManager extends StatefulWidget {
  const ToastManager({super.key});
  @override
  State<ToastManager> createState() => ToastManagerState();
}

class ToastManagerState extends State<ToastManager> {
  final List<_ToastData> _queue = [];
  _ToastData? _current;
  bool _showing = false;

  void showToast(String message, IconData icon) {
    _queue.add(_ToastData(message, icon));
    if (!_showing) _showNext();
  }

  void _showNext() {
    if (_queue.isEmpty) {
      setState(() {
        _current = null;
        _showing = false;
      });
      return;
    }
    _showing = true;
    setState(() => _current = _queue.removeAt(0));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _showNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();
    return DetectionToast(
      key: ValueKey(_current!.message + DateTime.now().toString()),
      message: _current!.message,
      icon: _current!.icon,
    );
  }
}

class _ToastData {
  _ToastData(this.message, this.icon);
  final String message;
  final IconData icon;
}
