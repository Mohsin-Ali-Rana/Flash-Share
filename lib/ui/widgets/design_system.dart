import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color backgroundStart = Color(0xFF0F2027);
  static const Color backgroundEnd = Color(0xFF203A43);
  static const Color accent = Color(0xFF00D2FF); // Neon Cyan
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;
}

ThemeData modernTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.backgroundStart,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: Colors.transparent,
    ),
  );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key, 
    required this.child, 
    this.opacity = 0.15,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity + 0.05),
                  Colors.white.withValues(alpha: opacity - 0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedMeshBackground extends StatefulWidget {
  final Widget child;
  const AnimatedMeshBackground({super.key, required this.child});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -100 + (_controller.value * 50),
              left: -50 + (_controller.value * 30),
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withValues(alpha: 0.2),
                  boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.2), blurRadius: 100)],
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: -100 + (_controller.value * 50),
              right: -50 + (_controller.value * 30),
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.2),
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 100)],
                ),
              ),
            );
          },
        ),
        SafeArea(child: widget.child),
      ],
    );
  }
}