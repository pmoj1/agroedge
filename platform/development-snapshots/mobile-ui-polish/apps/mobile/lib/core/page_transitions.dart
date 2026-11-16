import 'package:flutter/material.dart';

/// Material 3 "fade through" push transition: the incoming screen fades
/// and scales in slightly while the outgoing one fades out. Cheap on
/// low-end devices -- opacity and a small scale only, no new dependency.
PageRoute<T> fadeThroughRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final scale = Tween<double>(begin: 0.98, end: 1).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
