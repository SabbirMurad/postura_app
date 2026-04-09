import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/e_learning_card.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/provider/e_learning.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/view/e_learning/quiz_screen.dart';

class ELearningScreen extends ConsumerStatefulWidget {
  const ELearningScreen({super.key});

  @override
  ConsumerState<ELearningScreen> createState() => _ELearningScreenState();
}

class _ELearningScreenState extends ConsumerState<ELearningScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eLearningNotifierProvider.notifier).checkNudges();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(eLearningNotifierProvider.notifier).checkNudges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final modules = ref.watch(
      eLearningNotifierProvider.select((s) => s.quizModules),
    );
    final certStatus = ref.watch(
      eLearningNotifierProvider.select((s) => s.certificateStatus),
    );
    final isCertLoading = ref.watch(
      eLearningNotifierProvider.select((s) => s.isCertificateLoading),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackButton(),
                    Spacer(),
                    Text(
                      loc.elearning,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20.h),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: modules.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final quizModule = modules[index];
                    return ELearningCard(
                      quizModule: quizModule,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(module: quizModule),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20.h),
                _buildCertificateCard(context, certStatus, isCertLoading),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(
    BuildContext context,
    CertificateStatus status,
    bool isLoading,
  ) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        decoration: _cardDecoration(AppColors.onBoardingSurface),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    switch (status.type) {
      case CertificateStatusType.valid:
        return _validCertCard(context, status.expiryDate);
      case CertificateStatusType.expired:
        return _expiredCertCard(context);
      case CertificateStatusType.pending:
        return _pendingCertCard(context);
    }
  }

  Widget _pendingCertCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: _cardDecoration(AppColors.onBoardingSurface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Assets.icons.auth.lock.svg(width: 24.w, fit: BoxFit.contain),
          SizedBox(height: 6.h),
          Text(
            'Certificate',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Text(
            'Complete all the modules to claim your certificate.',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _validCertCard(BuildContext context, DateTime? expiryDate) {
    final expiryText = expiryDate != null
        ? 'Valid until ${_formatDate(expiryDate)}'
        : 'Valid';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: _cardDecoration(const Color(0xFFF0FDF4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: const Color(0xFF16A34A),
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Certificate',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'VALID',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            expiryText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF16A34A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _expiredCertCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: _cardDecoration(const Color(0xFFFFF7ED)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF97316).withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFC2410C),
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Certificate',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'EXPIRED',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Your certificate has expired. Complete all modules again to renew it.',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFC2410C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(Color color) => BoxDecoration(
    borderRadius: BorderRadius.circular(18.r),
    color: color,
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF242424).withValues(alpha: 0.05),
        blurRadius: 12.w,
        offset: Offset(0, 4.h),
      ),
    ],
  );

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
