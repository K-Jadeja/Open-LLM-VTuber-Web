import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/providers/ai_state_provider.dart';
import '../core/providers/websocket_provider.dart';
import '../services/audio_service.dart';

// Provider for microphone state
final microphoneProvider = StateProvider<bool>((ref) => false);

// Provider for VAD settings
final vadSettingsProvider = StateProvider<VadSettings>((ref) => VadSettings());

class VadSettings {
  final double positiveSpeechThreshold;
  final double negativeSpeechThreshold;
  final int redemptionFrames;
  final bool autoStartMic;
  final bool autoStopMic;

  VadSettings({
    this.positiveSpeechThreshold = 0.5,
    this.negativeSpeechThreshold = 0.35,
    this.redemptionFrames = 35,
    this.autoStartMic = false,
    this.autoStopMic = true,
  });

  VadSettings copyWith({
    double? positiveSpeechThreshold,
    double? negativeSpeechThreshold,
    int? redemptionFrames,
    bool? autoStartMic,
    bool? autoStopMic,
  }) {
    return VadSettings(
      positiveSpeechThreshold: positiveSpeechThreshold ?? this.positiveSpeechThreshold,
      negativeSpeechThreshold: negativeSpeechThreshold ?? this.negativeSpeechThreshold,
      redemptionFrames: redemptionFrames ?? this.redemptionFrames,
      autoStartMic: autoStartMic ?? this.autoStartMic,
      autoStopMic: autoStopMic ?? this.autoStopMic,
    );
  }
}

class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiStateProvider);
    final micOn = ref.watch(microphoneProvider);
    final connectionState = ref.watch(webSocketProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: micOn ? Icons.mic : Icons.mic_off,
            label: micOn ? 'Mic On' : 'Mic Off',
            color: micOn ? AppColors.onlineStatus : AppColors.offlineStatus,
            onTap: () => _toggleMicrophone(ref),
            isActive: micOn,
          ),

          // Interrupt button
          _buildControlButton(
            icon: Icons.stop_circle,
            label: 'Interrupt',
            color: AppColors.offlineStatus,
            onTap: aiState.canInterrupt ? () => _interrupt(ref) : null,
            isActive: aiState.canInterrupt,
          ),

          // Send text button
          _buildControlButton(
            icon: Icons.chat_bubble,
            label: 'Send Text',
            color: AppTheme.primaryColor,
            onTap: connectionState == WebSocketConnectionState.connected
                ? () => _showTextInput(context, ref)
                : null,
            isActive: connectionState == WebSocketConnectionState.connected,
          ),

          // Settings button
          _buildControlButton(
            icon: Icons.tune,
            label: 'VAD Settings',
            color: AppTheme.secondaryColor,
            onTap: () => _showVadSettings(context, ref),
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate(target: isActive ? 1 : 0)
        .scale(duration: 200.ms)
        .shimmer(duration: 1500.ms, color: color.withOpacity(0.3));
  }

  void _toggleMicrophone(WidgetRef ref) {
    final currentState = ref.read(microphoneProvider);
    
    if (currentState) {
      VadService.stopMicrophone();
      ref.read(microphoneProvider.notifier).state = false;
    } else {
      VadService.startMicrophone();
      ref.read(microphoneProvider.notifier).state = true;
    }
  }

  void _interrupt(WidgetRef ref) {
    // Stop audio playback
    AudioService.interrupt();
    
    // Set AI state to idle
    ref.read(aiStateProvider.notifier).interrupt();
    
    // Send interrupt signal to backend
    ref.read(webSocketProvider.notifier).sendMessage({
      'type': 'interrupt-signal',
    });
  }

  void _showTextInput(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _TextInputDialog(ref: ref),
    );
  }

  void _showVadSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _VadSettingsDialog(ref: ref),
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  final WidgetRef ref;

  const _TextInputDialog({required this.ref});

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Text Message',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      widget.ref.read(webSocketProvider.notifier).sendMessage({
                        'type': 'text-input',
                        'text': _controller.text.trim(),
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VadSettingsDialog extends StatefulWidget {
  final WidgetRef ref;

  const _VadSettingsDialog({required this.ref});

  @override
  State<_VadSettingsDialog> createState() => _VadSettingsDialogState();
}

class _VadSettingsDialogState extends State<_VadSettingsDialog> {
  late VadSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.ref.read(vadSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VAD Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            _buildSliderSetting(
              'Positive Speech Threshold',
              _settings.positiveSpeechThreshold,
              0.0,
              1.0,
              (value) => _settings = _settings.copyWith(positiveSpeechThreshold: value),
            ),
            
            _buildSliderSetting(
              'Negative Speech Threshold',
              _settings.negativeSpeechThreshold,
              0.0,
              1.0,
              (value) => _settings = _settings.copyWith(negativeSpeechThreshold: value),
            ),
            
            _buildSliderSetting(
              'Redemption Frames',
              _settings.redemptionFrames.toDouble(),
              1.0,
              100.0,
              (value) => _settings = _settings.copyWith(redemptionFrames: value.round()),
            ),
            
            SwitchListTile(
              title: const Text('Auto Start Mic'),
              value: _settings.autoStartMic,
              onChanged: (value) => setState(() {
                _settings = _settings.copyWith(autoStartMic: value);
              }),
            ),
            
            SwitchListTile(
              title: const Text('Auto Stop Mic'),
              value: _settings.autoStopMic,
              onChanged: (value) => setState(() {
                _settings = _settings.copyWith(autoStopMic: value);
              }),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.ref.read(vadSettingsProvider.notifier).state = _settings;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          label: value.toStringAsFixed(2),
          onChanged: (newValue) {
            setState(() {
              onChanged(newValue);
            });
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}