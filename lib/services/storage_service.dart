import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static const String _wsUrlKey = 'websocket_url';
  static const String _baseUrlKey = 'base_url';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _themeKey = 'theme_mode';
  static const String _vadSettingsKey = 'vad_settings';
  static const String _audioSettingsKey = 'audio_settings';
  
  // Default values
  static const String defaultWsUrl = 'ws://localhost:8000/client-ws';
  static const String defaultBaseUrl = 'http://localhost:8000';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // WebSocket URL
  static Future<String?> getWsUrl() async {
    return _prefs.getString(_wsUrlKey) ?? defaultWsUrl;
  }

  static Future<void> setWsUrl(String url) async {
    await _prefs.setString(_wsUrlKey, url);
  }

  // Base URL
  static Future<String?> getBaseUrl() async {
    return _prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_baseUrlKey, url);
  }

  // Language
  static Future<String?> getSelectedLanguage() async {
    return _prefs.getString(_selectedLanguageKey);
  }

  static Future<void> setSelectedLanguage(String language) async {
    await _prefs.setString(_selectedLanguageKey, language);
  }

  // Theme
  static Future<String?> getThemeMode() async {
    return _prefs.getString(_themeKey);
  }

  static Future<void> setThemeMode(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  // VAD Settings
  static Future<Map<String, dynamic>?> getVadSettings() async {
    final String? settings = _prefs.getString(_vadSettingsKey);
    if (settings == null) return null;
    // In a real app, you'd parse JSON here
    return {}; // Placeholder
  }

  static Future<void> setVadSettings(Map<String, dynamic> settings) async {
    // In a real app, you'd serialize to JSON here
    await _prefs.setString(_vadSettingsKey, settings.toString());
  }

  // Audio Settings
  static Future<Map<String, dynamic>?> getAudioSettings() async {
    final String? settings = _prefs.getString(_audioSettingsKey);
    if (settings == null) return null;
    // In a real app, you'd parse JSON here
    return {}; // Placeholder
  }

  static Future<void> setAudioSettings(Map<String, dynamic> settings) async {
    // In a real app, you'd serialize to JSON here
    await _prefs.setString(_audioSettingsKey, settings.toString());
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}