import 'dart:typed_data';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioPlayer? _audioPlayer;
  static final List<AudioTask> _audioQueue = [];
  static bool _isPlaying = false;

  static Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    _setupAudioPlayerListeners();
  }

  static void _setupAudioPlayerListeners() {
    _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        _isPlaying = false;
        _processNextAudioTask();
      }
    });
  }

  // Add audio task to queue
  static void addAudioTask({
    required String base64Audio,
    List<double>? volumes,
    int? sliceLength,
    Function()? onStart,
    Function()? onComplete,
  }) {
    final task = AudioTask(
      base64Audio: base64Audio,
      volumes: volumes,
      sliceLength: sliceLength,
      onStart: onStart,
      onComplete: onComplete,
    );

    _audioQueue.add(task);
    
    if (!_isPlaying) {
      _processNextAudioTask();
    }
  }

  static void _processNextAudioTask() {
    if (_audioQueue.isEmpty || _isPlaying) return;

    final task = _audioQueue.removeAt(0);
    _playAudioTask(task);
  }

  static Future<void> _playAudioTask(AudioTask task) async {
    if (_audioPlayer == null) return;

    try {
      _isPlaying = true;
      task.onStart?.call();

      // Convert base64 to audio bytes
      final audioBytes = base64Decode(task.base64Audio);
      
      // Create a temporary file or use a BytesSource
      // For now, we'll use a simple approach
      await _audioPlayer!.play(BytesSource(audioBytes));
      
      // Note: In a real implementation, you might want to handle lip sync
      // using the volumes array and sliceLength for animation timing
      
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
      _isPlaying = false;
      task.onComplete?.call();
      _processNextAudioTask();
    }
  }

  // Stop current audio and clear queue
  static Future<void> stopAndClearQueue() async {
    await _audioPlayer?.stop();
    _audioQueue.clear();
    _isPlaying = false;
  }

  // Interrupt current audio
  static Future<void> interrupt() async {
    await stopAndClearQueue();
  }

  // Check if audio is currently playing
  static bool get isPlaying => _isPlaying;

  // Check if there are tasks in queue
  static bool get hasQueuedTasks => _audioQueue.isNotEmpty;

  static void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _audioQueue.clear();
  }
}

class AudioTask {
  final String base64Audio;
  final List<double>? volumes;
  final int? sliceLength;
  final Function()? onStart;
  final Function()? onComplete;

  AudioTask({
    required this.base64Audio,
    this.volumes,
    this.sliceLength,
    this.onStart,
    this.onComplete,
  });
}

// Voice Activity Detection Service
class VadService {
  static bool _isInitialized = false;
  static bool _isMicOn = false;
  static Function(Uint8List)? _onAudioData;
  static Function()? _onSpeechStart;
  static Function()? _onSpeechEnd;

  static Future<void> initialize({
    required Function(Uint8List) onAudioData,
    Function()? onSpeechStart,
    Function()? onSpeechEnd,
  }) async {
    if (_isInitialized) return;

    _onAudioData = onAudioData;
    _onSpeechStart = onSpeechStart;
    _onSpeechEnd = onSpeechEnd;

    // TODO: Implement actual VAD initialization
    // This would involve setting up audio recording and VAD processing
    
    _isInitialized = true;
  }

  static Future<void> startMicrophone() async {
    if (!_isInitialized) return;
    
    _isMicOn = true;
    // TODO: Start audio recording and VAD processing
  }

  static Future<void> stopMicrophone() async {
    _isMicOn = false;
    // TODO: Stop audio recording
  }

  static bool get isMicOn => _isMicOn;
  static bool get isInitialized => _isInitialized;

  static void dispose() {
    _isInitialized = false;
    _isMicOn = false;
    _onAudioData = null;
    _onSpeechStart = null;
    _onSpeechEnd = null;
  }
}