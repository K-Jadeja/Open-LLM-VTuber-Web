import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/providers/websocket_provider.dart';
import '../core/app_theme.dart';

class ConnectionStatus extends ConsumerWidget {
  final WebSocketConnectionState state;

  const ConnectionStatus({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) {
            if (state == WebSocketConnectionState.connecting ||
                state == WebSocketConnectionState.reconnecting) {
              controller.repeat();
            }
          }).scale(duration: 1000.ms),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (state) {
      case WebSocketConnectionState.connected:
        return AppColors.onlineStatus;
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.reconnecting:
        return AppColors.thinkingStatus;
      case WebSocketConnectionState.disconnected:
      case WebSocketConnectionState.error:
        return AppColors.offlineStatus;
    }
  }

  String _getStatusText() {
    switch (state) {
      case WebSocketConnectionState.connected:
        return 'Connected';
      case WebSocketConnectionState.connecting:
        return 'Connecting...';
      case WebSocketConnectionState.reconnecting:
        return 'Reconnecting...';
      case WebSocketConnectionState.disconnected:
        return 'Disconnected';
      case WebSocketConnectionState.error:
        return 'Error';
    }
  }
}