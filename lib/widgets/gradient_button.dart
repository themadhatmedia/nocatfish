import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.gradient,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.isLoading = false,
    this.icon,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = widget.enabled && widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isButtonEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isButtonEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isButtonEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isButtonEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        decoration: BoxDecoration(
          gradient: isButtonEnabled
              ? widget.gradient
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed || !isButtonEnabled
              ? []
              : [
                  BoxShadow(
                    color: widget.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ).animate(target: _isPressed ? 1 : 0).scaleXY(end: 0.95),
    );
  }
}
