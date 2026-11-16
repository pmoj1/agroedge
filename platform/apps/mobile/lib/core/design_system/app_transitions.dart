import 'package:flutter/material.dart';

class AppTransitions {
  AppTransitions._();

  /// Creates a slide up and fade route transition.
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
          begin: const Offset(0.0, 0.06),
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
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

  /// Creates a standard slide from right to left transition.
  static PageRouteBuilder<T> slideHorizontal<T>({
    required Widget child,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        );

        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: slideTween.animate(curvedAnim),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
