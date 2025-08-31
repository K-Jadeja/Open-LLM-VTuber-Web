# Open LLM VTuber

A state-of-the-art Flutter VTuber application with Live2D integration and AI backend communication.

## Features

- 🎭 **Animated VTuber Avatar**: Beautiful character animations with real-time expressions and lip sync
- 🎤 **Voice Activity Detection**: Real-time speech detection and audio processing
- 💬 **Interactive Chat Interface**: Modern chat UI with message history and real-time communication
- 🌐 **WebSocket Integration**: Seamless backend communication for AI responses
- 🎨 **Modern UI Design**: State-of-the-art interface with smooth animations and glassmorphism effects
- 🌍 **Multi-language Support**: Internationalization support for multiple languages
- ⚙️ **Customizable Settings**: Adjustable VAD settings, audio configuration, and preferences
- 🔄 **Cross-platform**: Runs on mobile, desktop, and web platforms

## Architecture

This Flutter application features a modern architecture with:

- **State Management**: Riverpod for reactive state management
- **Real-time Communication**: WebSocket-based backend integration
- **Audio Processing**: Advanced audio streaming and voice activity detection
- **Modular Design**: Clean separation of concerns with providers, services, and widgets
- **Animation System**: Custom character animation system with state-based visual feedback

## Reference Implementation

The original Electron + React implementation has been moved to the `reference/` folder for comparison and reference.

## Project Setup

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Platform-specific requirements:
  - **Android**: Android SDK, Android Studio
  - **iOS**: Xcode, CocoaPods
  - **Desktop**: Platform-specific toolchain
  - **Web**: Chrome/Edge for development

### Install Dependencies

```bash
flutter pub get
```

### Development

```bash
# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome

# Run on desktop
flutter run -d windows  # or macos, linux
```

### Build

```bash
# Android APK
flutter build apk

# iOS (requires macOS)
flutter build ios

# Web
flutter build web

# Desktop
flutter build windows  # or macos, linux
```

## Backend Integration

This application communicates with a WebSocket-based backend server. Configure the connection settings in the app's settings panel:

- **WebSocket URL**: `ws://localhost:8000/client-ws` (default)
- **Base URL**: `http://localhost:8000` (default)

## Project Structure

```
lib/
├── core/
│   ├── providers/          # Riverpod state providers
│   └── app_theme.dart      # Application theme and styling
├── models/                 # Data models and message schemas
├── screens/               # Main application screens
├── services/              # Backend services (WebSocket, Audio, Storage)
├── widgets/               # Reusable UI components
└── main.dart              # Application entry point

reference/                 # Original Electron + React implementation
├── src/                   # Source code from original app
├── docs/                  # Documentation
└── resources/             # Assets and resources
```

## Key Components

### VTuber Avatar System
- Animated character with breathing, blinking, and lip sync
- State-based visual feedback (idle, listening, thinking, speaking)
- Customizable expressions and animations

### Chat Interface
- Modern messaging UI with bubble design
- Real-time message updates
- Support for both human and AI messages
- Tool call status display

### Audio System
- Real-time audio streaming from backend
- Voice Activity Detection (VAD)
- Audio queue management with lip sync support
- Configurable VAD sensitivity settings

### WebSocket Communication
- Robust connection management with auto-reconnect
- Message type handling for audio, text, and control signals
- Real-time status indicators

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
