import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/websocket_message.dart';

// Provider for Live2D model configuration
final live2dConfigProvider = StateNotifierProvider<Live2dConfigNotifier, Live2dConfig>(
  (ref) => Live2dConfigNotifier(),
);

class Live2dConfig {
  final ModelInfo? modelInfo;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? expressions;
  final Map<String, dynamic>? motions;

  Live2dConfig({
    this.modelInfo,
    this.isLoading = false,
    this.error,
    this.expressions,
    this.motions,
  });

  Live2dConfig copyWith({
    ModelInfo? modelInfo,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? expressions,
    Map<String, dynamic>? motions,
  }) {
    return Live2dConfig(
      modelInfo: modelInfo ?? this.modelInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      expressions: expressions ?? this.expressions,
      motions: motions ?? this.motions,
    );
  }
}

class Live2dConfigNotifier extends StateNotifier<Live2dConfig> {
  Live2dConfigNotifier() : super(Live2dConfig());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setModelInfo(ModelInfo modelInfo) {
    state = state.copyWith(
      modelInfo: modelInfo,
      isLoading: false,
      error: null,
    );
  }

  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }

  void setExpressions(Map<String, dynamic> expressions) {
    state = state.copyWith(expressions: expressions);
  }

  void setMotions(Map<String, dynamic> motions) {
    state = state.copyWith(motions: motions);
  }

  void clearModel() {
    state = Live2dConfig();
  }
}