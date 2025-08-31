import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../core/app_theme.dart';
import '../core/providers/ai_state_provider.dart';

class VTuberAvatar extends ConsumerStatefulWidget {
  const VTuberAvatar({super.key});

  @override
  ConsumerState<VTuberAvatar> createState() => _VTuberAvatarState();
}

class _VTuberAvatarState extends ConsumerState<VTuberAvatar>
    with TickerProviderStateMixin {
  
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late AnimationController _lipSyncController;
  
  @override
  void initState() {
    super.initState();
    
    // Breathing animation
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // Blinking animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Lip sync animation
    _lipSyncController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _startRandomBlinking();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _lipSyncController.dispose();
    super.dispose();
  }

  void _startRandomBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + (DateTime.now().millisecond % 3000)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _startRandomBlinking();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiStateProvider);
    
    return Center(
      child: Container(
        width: 400,
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main avatar
            _buildAvatarBody(aiState),
            
            // Eyes
            _buildEyes(aiState),
            
            // Mouth (for lip sync)
            _buildMouth(aiState),
            
            // State-specific effects
            _buildStateEffects(aiState),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBody(AiState state) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_breathingController.value * 0.02),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  _getAvatarColorForState(state).withOpacity(0.8),
                  _getAvatarColorForState(state).withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Avatar illustration placeholder
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColorForState(state).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.face,
                    size: 120,
                    color: _getAvatarColorForState(state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEyes(AiState state) {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _blinkController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left eye
              Container(
                width: 20,
                height: 20 - (_blinkController.value * 18),
                decoration: BoxDecoration(
                  color: _getEyeColorForState(state),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 40),
              // Right eye
              Container(
                width: 20,
                height: 20 - (_blinkController.value * 18),
                decoration: BoxDecoration(
                  color: _getEyeColorForState(state),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMouth(AiState state) {
    return Positioned(
      top: 200,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _lipSyncController,
        builder: (context, child) {
          return Container(
            width: 30 + (_lipSyncController.value * 10),
            height: 15 + (_lipSyncController.value * 5),
            decoration: BoxDecoration(
              color: state == AiState.speaking ? AppColors.speakingStatus : Colors.grey[600],
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateEffects(AiState state) {
    switch (state) {
      case AiState.listening:
        return _buildListeningEffect();
      case AiState.thinking:
        return _buildThinkingEffect();
      case AiState.speaking:
        return _buildSpeakingEffect();
      case AiState.thinkingSpeaking:
        return _buildThinkingSpeakingEffect();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildListeningEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.speakingStatus,
            width: 3,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: AppColors.speakingStatus),
    );
  }

  Widget _buildThinkingEffect() {
    return Positioned(
      top: 50,
      right: 30,
      child: Container(
        width: 60,
        height: 40,
        child: Column(
          children: [
            ...List.generate(3, (index) => 
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.thinkingStatus,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scale(
                  delay: Duration(milliseconds: index * 200),
                  duration: 600.ms,
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakingEffect() {
    // Trigger lip sync animation when speaking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_lipSyncController.isAnimating) {
        _lipSyncController.repeat(reverse: true);
      }
    });
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.speakingStatus,
            width: 2,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .fadeIn(duration: 500.ms)
          .then()
          .fadeOut(duration: 500.ms),
    );
  }

  Widget _buildThinkingSpeakingEffect() {
    return Stack(
      children: [
        _buildThinkingEffect(),
        _buildSpeakingEffect(),
      ],
    );
  }

  Color _getAvatarColorForState(AiState state) {
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

  Color _getEyeColorForState(AiState state) {
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