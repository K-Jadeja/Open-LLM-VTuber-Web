import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/providers/websocket_provider.dart';
import '../core/providers/ai_state_provider.dart';
import '../widgets/vtuber_avatar.dart';
import '../widgets/chat_interface.dart';
import '../widgets/control_panel.dart';
import '../widgets/connection_status.dart';
import '../widgets/subtitle_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _backgroundController;
  bool _showChat = false;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Initialize WebSocket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(webSocketProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(webSocketProvider);
    final aiState = ref.watch(aiStateProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with connection status and controls
                  _buildTopBar(connectionState),
                  
                  // Main VTuber area
                  Expanded(
                    child: Row(
                      children: [
                        // Chat panel (collapsible)
                        if (_showChat)
                          Expanded(
                            flex: 1,
                            child: const ChatInterface()
                                .animate()
                                .slideX(
                                  begin: -1,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          ),
                        
                        // VTuber avatar area
                        Expanded(
                          flex: _showChat ? 2 : 3,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Avatar
                              const VTuberAvatar(),
                              
                              // Subtitle overlay
                              const Positioned(
                                bottom: 100,
                                left: 20,
                                right: 20,
                                child: SubtitleOverlay(),
                              ),
                              
                              // AI state indicator
                              Positioned(
                                top: 20,
                                right: 20,
                                child: _buildAiStateIndicator(aiState),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom control panel
                  const ControlPanel(),
                ],
              ),
            ),
            
            // Settings overlay
            if (_showSettings)
              _buildSettingsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.05),
                AppTheme.accentColor.withOpacity(0.1),
              ],
              stops: [
                0.0,
                _backgroundController.value,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(WebSocketConnectionState connectionState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // App logo/title
          Text(
            'Open LLM VTuber',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.5),
          
          const Spacer(),
          
          // Connection status
          ConnectionStatus(state: connectionState)
              .animate()
              .fadeIn(delay: 200.ms),
          
          const SizedBox(width: 16),
          
          // Chat toggle
          IconButton(
            onPressed: () => setState(() => _showChat = !_showChat),
            icon: Icon(
              _showChat ? Icons.chat : Icons.chat_outlined,
              color: Colors.white,
            ),
            tooltip: 'Toggle Chat',
          ).animate().scale(delay: 400.ms),
          
          // Settings button
          IconButton(
            onPressed: () => setState(() => _showSettings = !_showSettings),
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: 'Settings',
          ).animate().scale(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildAiStateIndicator(AiState state) {
    Color color;
    IconData icon;
    
    switch (state) {
      case AiState.idle:
        color = AppColors.onlineStatus;
        icon = Icons.circle;
        break;
      case AiState.listening:
        color = AppColors.speakingStatus;
        icon = Icons.mic;
        break;
      case AiState.thinking:
        color = AppColors.thinkingStatus;
        icon = Icons.psychology;
        break;
      case AiState.speaking:
        color = AppColors.speakingStatus;
        icon = Icons.record_voice_over;
        break;
      case AiState.thinkingSpeaking:
        color = AppColors.thinkingStatus;
        icon = Icons.smart_toy;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            state.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms);
  }

  Widget _buildSettingsOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _showSettings = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text('Settings panel coming soon...'),
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}