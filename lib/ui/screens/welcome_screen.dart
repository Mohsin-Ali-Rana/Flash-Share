import 'package:flash_share/ui/screens/home_screen.dart';
import 'package:flash_share/ui/widgets/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const HomeScreen(),
        transitionsBuilder: (c, a1, a2, child) => FadeTransition(opacity: a1, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedMeshBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // HERO ICON
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 60, spreadRadius: 10)
                    ],
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2),
                  ),
                  child: const Icon(PhosphorIcons.lightning, size: 80, color: Colors.white),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),

                const SizedBox(height: 50),

                Text(
                  "FLASH SHARE",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 15),

                Text(
                  "Hyper-Speed File Transfer.\nNo Internet Required.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 16,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                const Spacer(),

                // PROFESSIONAL START BUTTON
                GestureDetector(
                  onTap: () => _goToHome(context),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "GET STARTED", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                        ),
                        SizedBox(width: 15),
                        Icon(PhosphorIcons.arrowRight, color: Colors.white),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 1, end: 0),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}