import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiState {
  idle,
  listening,
  thinking,
  speaking,
  thinkingSpeaking,
}

extension AiStateExtension on AiState {
  String get displayName {
    switch (this) {
      case AiState.idle:
        return 'Idle';
      case AiState.listening:
        return 'Listening';
      case AiState.thinking:
        return 'Thinking';
      case AiState.speaking:
        return 'Speaking';
      case AiState.thinkingSpeaking:
        return 'Processing';
    }
  }

  bool get canInterrupt {
    switch (this) {
      case AiState.speaking:
      case AiState.thinkingSpeaking:
        return true;
      default:
        return false;
    }
  }

  bool get isProcessing {
    switch (this) {
      case AiState.thinking:
      case AiState.speaking:
      case AiState.thinkingSpeaking:
        return true;
      default:
        return false;
    }
  }
}

class AiStateNotifier extends StateNotifier<AiState> {
  AiStateNotifier() : super(AiState.idle);

  void setIdle() => state = AiState.idle;
  void setListening() => state = AiState.listening;
  void setThinking() => state = AiState.thinking;
  void setSpeaking() => state = AiState.speaking;
  void setThinkingSpeaking() => state = AiState.thinkingSpeaking;

  void interrupt() {
    if (state.canInterrupt) {
      state = AiState.idle;
    }
  }
}

final aiStateProvider = StateNotifierProvider<AiStateNotifier, AiState>(
  (ref) => AiStateNotifier(),
);