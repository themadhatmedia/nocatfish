import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final List<Color>? gradient;
  final Border? border;
  final bool showImage;
  final String? imageURL;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.gradient,
    this.border,
    this.showImage = false,
    this.imageURL = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: showImage && imageURL!.isNotEmpty
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                    width: 1.5,
                  ),
              image: DecorationImage(
                image: NetworkImage(imageURL!),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                    width: 1.5,
                  ),
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient!,
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.1 : opacity),
                        Colors.white.withOpacity(isDark ? 0.05 : opacity * 0.5),
                      ],
                    ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
