import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/providers/ai_state_provider.dart';
import '../services/audio_service.dart';

// Provider for subtitle text
final subtitleProvider = StateProvider<String?>((ref) => null);

class SubtitleOverlay extends ConsumerWidget {
  const SubtitleOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleText = ref.watch(subtitleProvider);
    final aiState = ref.watch(aiStateProvider);

    if (subtitleText == null || subtitleText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSubtitleColorForState(aiState),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSubtitleColorForState(aiState).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        subtitleText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color: _getSubtitleColorForState(aiState),
              blurRadius: 4,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ).animate()
        .slideY(begin: 0.5, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 200.ms);
  }

  Color _getSubtitleColorForState(AiState state) {
    switch (state) {
      case AiState.listening:
        return AppColors.speakingStatus;
      case AiState.thinking:
        return AppColors.thinkingStatus;
      case AiState.speaking:
        return AppColors.speakingStatus;
      case AiState.thinkingSpeaking:
        return AppColors.thinkingStatus;
      default:
        return AppTheme.primaryColor;
    }
  }
}