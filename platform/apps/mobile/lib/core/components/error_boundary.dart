import 'package:flutter/material.dart';
import '../theme.dart';

/// ErrorBoundary intercepts builder and build-time layout exceptions,
/// logging them and displaying a safe fallback UI instead of crashing
/// the entire render tree.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({required this.child, super.key});

  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0E1A14) : AppColors.cream100,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Application Recovery',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'An unexpected translation or layout error occurred. The screen has been safely recovered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reload Screen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasError) {
              setState(() {
                _hasError = true;
              });
            }
          });
          return const SizedBox.shrink();
        };
        return widget.child;
      },
    );
  }
}
