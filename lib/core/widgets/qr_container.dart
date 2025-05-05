import 'package:flutter/material.dart';

class QrContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double size;
  final bool showGlareEffect;
  final VoidCallback? onTap;

  const QrContainer({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.size = 250,
    this.showGlareEffect = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // QR code content
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
            ),

            // Glare effect (subtle shiny overlay)
            if (showGlareEffect)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.025),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0.0, 0.3, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // Subtle border
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.15),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
