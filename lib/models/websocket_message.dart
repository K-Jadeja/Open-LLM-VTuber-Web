import 'dart:convert';

class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage({
    required this.type,
    required this.data,
  });

  factory WebSocketMessage.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return WebSocketMessage(
      type: json['type'] ?? '',
      data: json,
    );
  }

  factory WebSocketMessage.fromMap(Map<String, dynamic> map) {
    return WebSocketMessage(
      type: map['type'] ?? '',
      data: map,
    );
  }

  String toJson() {
    return jsonEncode(data);
  }

  // Convenience getters for common message types
  String? get audio => data['audio'];
  List<double>? get volumes => (data['volumes'] as List?)?.cast<double>();
  int? get sliceLength => data['slice_length'];
  String? get text => data['text'];
  String? get content => data['content'];
  Map<String, dynamic>? get modelInfo => data['model_info'];
  List<dynamic>? get messages => data['messages'];
  String? get historyUid => data['history_uid'];
  bool? get success => data['success'];
  List<dynamic>? get histories => data['histories'];
  List<dynamic>? get configs => data['configs'];
  String? get message => data['message'];
  List<String>? get members => (data['members'] as List?)?.cast<String>();
  bool? get isOwner => data['is_owner'];
  String? get clientUid => data['client_uid'];
  bool? get forwarded => data['forwarded'];
  Map<String, dynamic>? get displayText => data['display_text'];
  String? get live2dModel => data['live2d_model'];
  String? get toolId => data['tool_id'];
  String? get toolName => data['tool_name'];
  String? get status => data['status'];
  String? get timestamp => data['timestamp'];
  Map<String, dynamic>? get actions => data['actions'];
}

class ChatMessage {
  final String id;
  final String content;
  final String role; // 'human' or 'ai'
  final DateTime timestamp;
  final String? name;
  final String? avatar;
  final String? type; // 'text' or 'tool_call_status'
  final String? toolId;
  final String? toolName;
  final String? status; // 'running', 'completed', 'error'

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.name,
    this.avatar,
    this.type,
    this.toolId,
    this.toolName,
    this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      role: json['role'] ?? 'human',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      name: json['name'],
      avatar: json['avatar'],
      type: json['type'],
      toolId: json['tool_id'],
      toolName: json['tool_name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (type != null) 'type': type,
      if (toolId != null) 'tool_id': toolId,
      if (toolName != null) 'tool_name': toolName,
      if (status != null) 'status': status,
    };
  }

  bool get isFromAI => role == 'ai';
  bool get isFromHuman => role == 'human';
  bool get isToolCall => type == 'tool_call_status';
}

class ModelInfo {
  final String url;
  final String name;
  final Map<String, dynamic>? config;

  ModelInfo({
    required this.url,
    required this.name,
    this.config,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      config: json['config'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name,
      if (config != null) 'config': config,
    };
  }
}