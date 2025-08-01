import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final int index;
  final bool animate;
  final double? elevation;
  final Gradient? gradient;
  final Border? border;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    this.index = 0,
    this.animate = true,
    this.elevation,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: color ?? AppTheme.cardBackground,
        borderRadius: borderRadius ?? AppTheme.borderRadiusMedium,
        boxShadow: boxShadow ?? AppTheme.cardShadow,
        gradient: gradient,
        border: border,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? AppTheme.borderRadiusMedium,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppTheme.borderRadiusMedium,
          splashColor: AppTheme.primaryColor.withOpacity(0.1),
          highlightColor: AppTheme.primaryColor.withOpacity(0.05),
          child: card,
        ),
      );
    }

    if (!animate) {
      return card;
    }

    return card
        .animate()
        .fade(
          begin: 0,
          end: 1,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          delay: 80.ms * index,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          delay: 80.ms * index,
        );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final int index;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    required this.gradient,
    this.borderRadius,
    this.padding,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      borderRadius: borderRadius,
      padding: padding,
      index: index,
      boxShadow: AppTheme.cardShadowLarge,
      gradient: gradient,
      child: child,
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int index;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      index: index,
      padding: const EdgeInsets.all(16),
      boxShadow: AppTheme.cardShadow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: 2.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      index: index,
      border: Border.all(color: color.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32)
              .animate(onPlay: (controller) => controller.loop(count: 3))
              .shimmer(
                duration: 1.5.seconds,
                color: color.withOpacity(0.3),
                size: 1.5,
                delay: (0.5.seconds * index) + 1.seconds,
              ),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.labelLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeRange;
  final bool isActive;
  final VoidCallback? onTap;
  final int index;

  const SessionCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeRange,
    this.isActive = false,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isActive
        ? AppTheme.successColor
        : AppTheme.textMedium;

    return AnimatedCard(
      onTap: onTap,
      index: index,
      padding: EdgeInsets.zero,
      child:
          ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Icon(
                    isActive ? Icons.play_circle_fill : Icons.event_note,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                title: Text(title, style: AppTheme.labelLarge),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(timeRange, style: AppTheme.bodySmall),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadiusFull,
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Completed',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textLight,
                  size: 16,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .then(delay: 2.seconds)
              .shimmer(
                duration: 1.5.seconds,
                color: isActive
                    ? AppTheme.successColor.withOpacity(0.1)
                    : Colors.transparent,
                size: 1.0,
                delay: 0.5.seconds,
                curve: Curves.easeInOut,
              ),
    );
  }
}
