import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class AnimationUtils {
  // Basic animations that can be chained or used individually
  static List<Effect> fadeIn([Duration? duration]) => [
    FadeEffect(
      duration: duration ?? AppTheme.animDurationMedium,
      curve: Curves.easeOut,
    ),
  ];

  static List<Effect> slideInFromBottom([Duration? duration]) => [
    SlideEffect(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
      duration: duration ?? AppTheme.animDurationMedium,
      curve: Curves.easeOutCubic,
    ),
  ];

  static List<Effect> slideInFromLeft([Duration? duration]) => [
    SlideEffect(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
      duration: duration ?? AppTheme.animDurationMedium,
      curve: Curves.easeOutCubic,
    ),
  ];

  static List<Effect> slideInFromRight([Duration? duration]) => [
    SlideEffect(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
      duration: duration ?? AppTheme.animDurationMedium,
      curve: Curves.easeOutCubic,
    ),
  ];

  static List<Effect> scaleIn([Duration? duration]) => [
    ScaleEffect(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      duration: duration ?? AppTheme.animDurationMedium,
      curve: Curves.easeOutCubic,
    ),
  ];

  static List<Effect> pulseEffect([Duration? duration]) => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: (duration ?? AppTheme.animDurationMedium) ~/ 2,
      curve: Curves.easeOut,
    ),
    ScaleEffect(
      begin: const Offset(1.05, 1.05),
      end: const Offset(1, 1),
      duration: (duration ?? AppTheme.animDurationMedium) ~/ 2,
      curve: Curves.easeIn,
    ),
  ];

  static List<Effect> shimmer([Duration? duration]) => [
    ShimmerEffect(
      duration: duration ?? const Duration(seconds: 2),
      color: AppTheme.primaryColor.withOpacity(0.1),
      size: 2,
      delay: 500.ms,
    ),
  ];

  // Commonly used combinations
  static List<Effect> fadeInFromBottom([Duration? duration]) => [
    ...fadeIn(duration),
    ...slideInFromBottom(duration),
  ];

  static List<Effect> fadeInFromLeft([Duration? duration]) => [
    ...fadeIn(duration),
    ...slideInFromLeft(duration),
  ];

  static List<Effect> fadeInFromRight([Duration? duration]) => [
    ...fadeIn(duration),
    ...slideInFromRight(duration),
  ];

  static List<Effect> popIn([Duration? duration]) => [
    ...fadeIn(duration),
    ...scaleIn(duration),
  ];

  // Staggered animations for lists
  static List<Effect> staggeredFadeIn(int index, {Duration? staggerDuration}) {
    return [
      FadeEffect(
        begin: 0,
        end: 1,
        duration: AppTheme.animDurationMedium,
        curve: Curves.easeOutCubic,
        delay: (staggerDuration ?? 100.ms) * index,
      ),
    ];
  }

  static List<Effect> staggeredSlideIn(
    int index, {
    Duration? staggerDuration,
    Offset? begin,
  }) {
    return [
      FadeEffect(
        begin: 0,
        end: 1,
        duration: AppTheme.animDurationMedium,
        curve: Curves.easeOutCubic,
        delay: (staggerDuration ?? 100.ms) * index,
      ),
      SlideEffect(
        begin: begin ?? const Offset(0, 0.2),
        end: Offset.zero,
        duration: AppTheme.animDurationMedium,
        curve: Curves.easeOutCubic,
        delay: (staggerDuration ?? 100.ms) * index,
      ),
    ];
  }

  // Animation for button press
  static List<Effect> buttonTapEffect() => [
    ScaleEffect(
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
      duration: 100.ms,
      curve: Curves.easeInOut,
    ),
  ];

  static List<Effect> buttonReleaseEffect() => [
    ScaleEffect(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 200.ms,
      curve: Curves.easeOutCubic,
    ),
  ];
}
