import "package:flutter/material.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/core/constants/app_constants.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed("/main");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.pine,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.pine, AppColors.pineDeep],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(scale: _scale.value, child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.brassGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  size: 34,
                  color: AppColors.pineDeep,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppConstants.appNameUr,
                style: AppTypography.urdu(
                  size: 36,
                  weight: FontWeight.w700,
                  color: AppColors.brassSoft,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${AppConstants.appName} · ${AppConstants.appTagline}",
                style: AppTypography.display(
                  size: 13,
                  weight: FontWeight.w700,
                  color: const Color(0xFFCFE0DC),
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 180,
                child: MeasuringTapeMini(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeasuringTapeMini extends StatelessWidget {
  const MeasuringTapeMini({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brassSoft, AppColors.brass],
        ),
      ),
    );
  }
}
