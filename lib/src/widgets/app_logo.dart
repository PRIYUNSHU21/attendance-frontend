import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? iconColor;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon - Modern Attendance Symbol
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor ?? AppTheme.primaryColor,
                iconColor?.withOpacity(0.8) ?? AppTheme.primaryLight,
                iconColor?.withOpacity(0.6) ?? AppTheme.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.3),
                blurRadius: size * 0.15,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size * 0.25),
                  child: CustomPaint(
                    painter: LogoPatternPainter(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              // Main icon content
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle
                    Container(
                      width: size * 0.7,
                      height: size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: size * 0.02,
                        ),
                      ),
                    ),
                    // Check mark icon
                    Icon(
                      Icons.check_circle,
                      size: size * 0.5,
                      color: Colors.white,
                    ),
                    // Clock icon overlay
                    Positioned(
                      bottom: size * 0.15,
                      right: size * 0.15,
                      child: Container(
                        width: size * 0.25,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: size * 0.01,
                          ),
                        ),
                        child: Icon(
                          Icons.access_time,
                          size: size * 0.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // App Name Text
        if (showText) ...[
          SizedBox(height: size * 0.2),
          Text(
            'ATTENDIFY',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppTheme.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            'Smart • Reliable • Efficient',
            style: TextStyle(
              fontSize: size * 0.1,
              color: (textColor ?? AppTheme.textSecondary).withOpacity(0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPatternPainter extends CustomPainter {
  final Color color;

  LogoPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid pattern
    final spacing = size.width / 8;
    for (int i = 1; i < 8; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * spacing, 0),
        Offset(i * spacing, size.height),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * spacing),
        Offset(size.width, i * spacing),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Compact version for app bars and small spaces
class CompactAppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const CompactAppLogo({super.key, this.size = 40, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.check_circle,
                  size: size * 0.6,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: size * 0.05,
                right: size * 0.05,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time,
                    size: size * 0.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.3),
          Text(
            'ATTENDIFY',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
