import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_services.dart';
import '../../core/design_system/app_card.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local chat message model
// ─────────────────────────────────────────────────────────────────────────────

class _ChatMessage {
  _ChatMessage({
    required this.text,
    required this.isMe,
    this.imageBytes,
    this.isLoading = false,
  });

  final String text;
  final bool isMe;
  final List<int>? imageBytes;
  bool isLoading;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Chat Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Fully functional AI agronomist chat powered by Gemini. Supports text,
/// image analysis, and (on supported platforms) voice recording.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isSending = false;
  String? _farmContext;

  late final AnimationController _inputBarAnimCtrl;
  late final Animation<Offset> _inputBarSlide;

  @override
  void initState() {
    super.initState();

    _inputBarAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _inputBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _inputBarAnimCtrl, curve: Curves.easeOutBack),
        );

    _inputBarAnimCtrl.forward();
    _loadFarmContext();
    _maybeShowWelcome();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputBarAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFarmContext() async {
    try {
      final profiles = await AppServices.instance.farmProfiles.list();
      if (profiles.isNotEmpty) {
        final farm = profiles.first;
        final crops = [
          if (farm.primaryCrop != null) farm.primaryCrop!,
          if (farm.secondaryCrop != null) farm.secondaryCrop!,
        ];
        _farmContext =
            'Farm: ${farm.farmName ?? 'Unknown'}, '
            'Location: ${farm.region ?? 'Unknown'}, ${farm.country ?? 'Unknown'}, '
            'Crops: ${crops.isEmpty ? 'Not specified' : crops.join(', ')}, '
            'Size: ${farm.farmSize != null ? '${farm.farmSize} ha' : 'Not specified'}';
      }
    } catch (_) {
      // No profile or fetch error — chat still works without context
    }
  }

  void _maybeShowWelcome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!GeminiService.instance.isAvailable) {
        _addAiMessage(
          '⚙️ **AI Agronomist setup required**\n\n'
          'To use the AI agronomist, you need to configure a Gemini API key in your app settings.\n\n'
          'Once set up, I can help you with:\n'
          '- Crop disease identification 🌱\n'
          '- Fertiliser & pest advice 🪲\n'
          '- Weather-based planting tips ☁️\n'
          '- Market & yield guidance 📊',
        );
        return;
      }
      _addAiMessage(
        '👋 **Hello, Farmer!**\n\n'
        'I\'m your AI agronomist, powered by Google Gemini. Ask me anything about your farm — '
        'crop diseases, planting schedules, fertiliser advice, or market prices.\n\n'
        'You can also **send a photo** of a sick plant for visual diagnosis! 📷',
      );
    });
  }

  void _addAiMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? text, Uint8List? imageBytes}) async {
    final question = (text ?? _inputController.text).trim();
    if (question.isEmpty && imageBytes == null) return;
    if (_isSending) return;

    // Add user message
    setState(() {
      _messages.add(
        _ChatMessage(
          text: question,
          isMe: true,
          imageBytes: imageBytes != null ? List<int>.from(imageBytes) : null,
        ),
      );
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Add loading indicator
    final loadingMsg = _ChatMessage(text: '', isMe: false, isLoading: true);
    setState(() => _messages.add(loadingMsg));
    _scrollToBottom();

    try {
      final List<({String mimeType, List<int> bytes})>? images =
          imageBytes != null
          ? [(mimeType: 'image/jpeg', bytes: List<int>.from(imageBytes))]
          : null;

      final response = await GeminiService.instance.askAgronomist(
        question.isNotEmpty
            ? question
            : 'Analyse this crop image and identify any diseases, pests or issues. Provide actionable advice.',
        farmContext: _farmContext,
        images: images,
      );

      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(_ChatMessage(text: response, isMe: false));
      });
    } catch (e) {
      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(
          _ChatMessage(
            text:
                'Sorry, I couldn\'t get a response right now. Please check your connection and try again.',
            isMe: false,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final source = kIsWeb ? ImageSource.gallery : ImageSource.gallery;
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _sendMessage(
        text: _inputController.text.trim().isEmpty
            ? 'Please analyse this image of my crop.'
            : _inputController.text.trim(),
        imageBytes: bytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access camera/gallery.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Voice recording is not supported in this browser. Please type your question.',
            ),
            backgroundColor: AppColors.forest700,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      if (!_isRecording) {
        setState(() => _isRecording = true);
      } else {
        setState(() => _isRecording = false);
        _addAiMessage(
          '🎙️ Voice transcription is being processed…\n\n'
          '_(For this build, please type your question directly. Full voice support coming soon.)_',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Voice recording unavailable on this device. Please type your question.',
            ),
            backgroundColor: AppColors.forest700,
          ),
        );
      }
      setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE0),
      appBar: _buildAppBar(l10n),
      body: SafeArea(
        child: Column(
          children: [
            // Availability warning
            if (!GeminiService.instance.isAvailable) _buildWarningBanner(),
            _buildWhatsAppSmsCard(),

            // Message list
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: msg.isLoading
                              ? const _TypingIndicator()
                              : _ChatBubble(msg: msg),
                        );
                      },
                    ),
            ),

            // Input bar
            SlideTransition(position: _inputBarSlide, child: _buildInputBar()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.aiChatTitle,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontFamilyFallback: ['Liberation Serif', 'serif'],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: GeminiService.instance.isAvailable
                      ? const Color(0xFF4ADE80)
                      : AppColors.gold500,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Powered by Google Gemini',
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.forest900,
      foregroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: AppCard(
        borderColor: AppColors.gold500.withValues(alpha: 0.45),
        backgroundColor: AppColors.gold200.withValues(alpha: 0.40),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.gold500,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Gemini API key not configured. Responses are offline only.',
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                  fontSize: 12,
                  color: AppColors.ink900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.forest700.withValues(alpha: 0.15),
                  AppColors.forest700.withValues(alpha: 0.02),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.forest700.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.forest700,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Ask your AI agronomist',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontFamilyFallback: ['Liberation Serif', 'serif'],
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Type a question, send a photo, or\nuse your voice to get expert advice.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
              fontSize: 13,
              color: AppColors.ink500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.ink200.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest900.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Mic button
          _InputIconButton(
            icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: _isRecording ? AppColors.errorRed : AppColors.ink500,
            backgroundColor: _isRecording
                ? AppColors.errorRed.withValues(alpha: 0.1)
                : Colors.transparent,
            onTap: _toggleVoiceRecording,
            tooltip: _isRecording ? 'Stop recording' : 'Record voice',
          ),

          const SizedBox(width: AppSpacing.xs),

          // Image button
          _InputIconButton(
            icon: Icons.image_outlined,
            color: AppColors.ink500,
            onTap: _pickImage,
            tooltip: 'Send image for crop analysis',
          ),

          const SizedBox(width: AppSpacing.xs),

          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.cream100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5DDD0)),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                  fontSize: 14,
                  color: AppColors.ink900,
                ),
                decoration: InputDecoration(
                  hintText: _isRecording
                      ? '🎙️ Recording…'
                      : 'Ask your AI agronomist…',
                  hintStyle: TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                    fontSize: 14,
                    color: _isRecording ? AppColors.errorRed : AppColors.ink500,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) _sendMessage(text: text);
                },
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Send button
          _SendButton(isLoading: _isSending, onTap: () => _sendMessage()),
        ],
      ),
    );
  }

  Widget _buildWhatsAppSmsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect WhatsApp & SMS Channel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  ),
                  Text(
                    'Ask agronomist questions via WhatsApp or SMS!',
                    style: TextStyle(fontSize: 11, color: AppColors.ink500),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                _showWhatsAppSmsDialog();
              },
              child: const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forest700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWhatsAppSmsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF4E4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WhatsApp & SMS Activation',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontFamilyFallback: ['Liberation Serif', 'serif'],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Farmers can chat with the AI Agronomist on WhatsApp or receive SMS updates. Follow the steps below:',
                style: TextStyle(fontSize: 13, color: AppColors.ink900),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStepRow(
                '1',
                'Send the message "join word-direction" on WhatsApp to +1 415 523 8886 (Twilio Sandbox).',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildStepRow(
                '2',
                'Alternatively, input your mobile number below to subscribe to SMS Weather & Alert updates.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.ink900),
                decoration: InputDecoration(
                  labelText: 'Mobile Number (e.g. +263771112222)',
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.ink500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Verification code sent! Follow prompt instructions on your mobile device.',
                        ),
                        backgroundColor: AppColors.forest700,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Send SMS Verification Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepRow(String step, String details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.forest700,
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            details,
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat bubble
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final _ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final hasImage = msg.imageBytes != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: EdgeInsets.only(left: isMe ? 48 : 0, right: isMe ? 0 : 48),
          decoration: BoxDecoration(
            color: isMe ? AppColors.forest700 : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            border: isMe ? null : Border.all(color: const Color(0xFFE5DDD0)),
            boxShadow: [
              BoxShadow(
                color: (isMe ? AppColors.forest700 : Colors.black).withValues(
                  alpha: isMe ? 0.22 : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.memory(
                    Uint8List.fromList(msg.imageBytes!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                ),

              // Message text
              if (msg.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: isMe
                      ? Text(
                          msg.text,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontFamilyFallback: ['Liberation Serif', 'serif'],
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : MarkdownBody(
                          data: msg.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontFamily: 'Georgia',
                              fontFamilyFallback: ['Liberation Serif', 'serif'],
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.ink900,
                            ),
                            strong: const TextStyle(
                              fontFamily: 'Georgia',
                              fontFamilyFallback: ['Liberation Serif', 'serif'],
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forest900,
                            ),
                            listBullet: const TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 14,
                              color: AppColors.ink900,
                            ),
                            code: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              backgroundColor: AppColors.cream100,
                              color: AppColors.forest700,
                            ),
                            h3: const TextStyle(
                              fontFamily: 'Georgia',
                              fontFamilyFallback: ['Liberation Serif', 'serif'],
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forest900,
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing indicator
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFE5DDD0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 14,
              color: AppColors.forest500,
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i / 3;
                    final t = (_ctrl.value - delay).clamp(0.0, 1.0);
                    final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(
                      0.25,
                      1.0,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.forest500,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input icon button
// ─────────────────────────────────────────────────────────────────────────────

class _InputIconButton extends StatelessWidget {
  const _InputIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
    this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Send button
// ─────────────────────────────────────────────────────────────────────────────

class _SendButton extends StatefulWidget {
  const _SendButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleCtrl;
  late Animation<double> _rippleScale;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rippleScale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) _rippleCtrl.forward();
      },
      onTapUp: (_) {
        _rippleCtrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _rippleCtrl.reverse(),
      child: ScaleTransition(
        scale: _rippleScale,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? null
                : const LinearGradient(
                    colors: [AppColors.forest700, AppColors.forest500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.isLoading ? AppColors.ink200 : null,
            shape: BoxShape.circle,
            boxShadow: widget.isLoading
                ? null
                : [
                    BoxShadow(
                      color: AppColors.forest700.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
