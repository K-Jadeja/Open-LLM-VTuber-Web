import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../models/websocket_message.dart';
import '../../services/storage_service.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketNotifier extends StateNotifier<WebSocketConnectionState> {
  WebSocketNotifier() : super(WebSocketConnectionState.disconnected);

  WebSocketChannel? _channel;
  String? _wsUrl;
  String? _baseUrl;
  
  // Callbacks for message handling
  void Function(WebSocketMessage)? onMessage;
  void Function(String)? onError;

  String? get wsUrl => _wsUrl;
  String? get baseUrl => _baseUrl;
  bool get isConnected => state == WebSocketConnectionState.connected;

  Future<void> initialize() async {
    _wsUrl = await StorageService.getWsUrl();
    _baseUrl = await StorageService.getBaseUrl();
    
    if (_wsUrl != null) {
      await connect(_wsUrl!);
    }
  }

  Future<void> connect(String url) async {
    try {
      state = WebSocketConnectionState.connecting;
      _wsUrl = url;
      
      // Save URL to storage
      await StorageService.setWsUrl(url);
      
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen to messages
      _channel!.stream.listen(
        (data) {
          try {
            final message = WebSocketMessage.fromJson(data);
            onMessage?.call(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
            onError?.call('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          state = WebSocketConnectionState.error;
          onError?.call(error.toString());
          _attemptReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          if (state != WebSocketConnectionState.disconnected) {
            state = WebSocketConnectionState.disconnected;
            _attemptReconnect();
          }
        },
      );
      
      state = WebSocketConnectionState.connected;
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      state = WebSocketConnectionState.error;
      onError?.call('Connection failed: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && state == WebSocketConnectionState.connected) {
      _channel!.sink.add(WebSocketMessage.fromMap(message).toJson());
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }

  Future<void> disconnect() async {
    state = WebSocketConnectionState.disconnected;
    await _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  Future<void> _attemptReconnect() async {
    if (_wsUrl == null) return;
    
    await Future.delayed(const Duration(seconds: 3));
    
    if (state != WebSocketConnectionState.disconnected) {
      state = WebSocketConnectionState.reconnecting;
      await connect(_wsUrl!);
    }
  }

  Future<void> updateBaseUrl(String url) async {
    _baseUrl = url;
    await StorageService.setBaseUrl(url);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketConnectionState>(
  (ref) => WebSocketNotifier(),
);