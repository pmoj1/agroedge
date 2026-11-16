import 'package:flutter/material.dart';

class AppTransitions {
  AppTransitions._();

  /// Create a slide & fade route transition.
  /// Transition slides slightly from bottom to top and fades in.
  static PageRouteBuilder<T> slideUpFade<T>({
    required Widget child,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        final slideTween = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        );

        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: fadeTween.animate(curvedAnim),
          child: SlideTransition(
            position: slideTween.animate(curvedAnim),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
