import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// AI Chat: stubbed. services/integrations has no working Gemini/Claude
/// endpoint yet (just its CLAUDE.md placeholder, no adapter code) --
/// per the build brief, this screen shows a clear "coming soon" state
/// rather than faking a response. Messages must never reach an AI
/// vendor directly from this client (root CLAUDE.md: server-side only).
class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiChatTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_top, size: 48, color: AppColors.ink500),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.aiChatComingSoonTitle,
                  style: const TextStyle(fontSize: AppFontSizes.title, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.aiChatComingSoonBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: AppFontSizes.body, color: AppColors.ink500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
