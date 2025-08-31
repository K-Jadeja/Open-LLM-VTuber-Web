# Phone Calling Interface - Backend Integration Guide

## Overview

The phone calling interface is designed to work seamlessly with the Open-LLM-VTuber backend server. This document explains how the integration works and how to test it.

## Backend Integration

### WebSocket Communication

The phone calling interface integrates with the backend through the same WebSocket infrastructure used by the main application:

1. **Connection**: WebSocket connects to the backend server (default: `ws://127.0.0.1:12393/client-ws`)
2. **Live2D Model Loading**: The backend sends model information via WebSocket message type `set-model-and-conf`
3. **Audio Streaming**: The backend streams TTS audio via WebSocket message type `audio`
4. **Voice Activity Detection**: Microphone controls integrate with the existing VAD system

### Key Integration Points

#### 1. Live2D Character Display
```tsx
// PhoneCallApp.tsx line 90
<Live2D showSidebar={false} />
```
The phone interface reuses the existing Live2D component which:
- Connects to the backend WebSocket
- Loads models from URLs provided by the backend
- Handles lip sync with audio volume data
- Manages expressions and animations

#### 2. WebSocket State Management
```tsx
// PhoneCallApp.tsx lines 15-17
const { aiState } = useAiState();
const { micOn, startMic, stopMic } = useVAD();
const { wsState } = useWebSocket();
```
The phone interface uses existing context providers:
- `AiStateContext`: Tracks AI conversation state (idle, listening, speaking)
- `VADContext`: Manages Voice Activity Detection and microphone
- `WebSocketContext`: Handles backend connection

#### 3. Auto-Microphone Management
```tsx
// PhoneCallApp.tsx lines 21-25
useEffect(() => {
  if (wsState === 'OPEN' && !micOn) {
    startMic();
  }
}, [wsState, micOn, startMic]);
```
Automatically starts microphone when connected to backend.

## Backend Setup

### 1. Clone and Setup Backend
```bash
git clone https://github.com/Open-LLM-VTuber/Open-LLM-VTuber.git
cd Open-LLM-VTuber
# Follow the installation instructions in their README
```

### 2. Configure Backend
Edit the backend configuration to include Live2D models and TTS settings.

### 3. Start Backend Server
```bash
# In the backend directory
python main.py  # or whatever the backend startup command is
```
The backend will start on `http://127.0.0.1:12393` by default.

### 4. Start Frontend
```bash
# In this directory
npm run dev:web
```
The frontend will start on `http://localhost:3000`

## Testing the Integration

### 1. Connection Test
1. Start the backend server
2. Start the frontend (`npm run dev:web`)
3. Open browser to `http://localhost:3000`
4. Click the Mode Menu (layers icon) in the sidebar
5. Select "Phone Call" from the dropdown
6. Check the status bar at the top - it should show "Connected" with a green indicator

### 2. VTuber Character Test
1. In phone mode, you should see the Live2D character in the center area
2. The character model is loaded from the backend
3. If no character appears, check:
   - Backend server is running
   - WebSocket connection is established
   - Backend has Live2D models configured

### 3. Voice Interaction Test
1. Ensure microphone permissions are granted
2. The mute button should be active (red when muted, normal when unmuted)
3. Speak into the microphone - the AI state should change to "Listening..."
4. The backend should process speech and respond with audio
5. The character should perform lip sync animations during TTS playback

### 4. Backend Communication Flow
```
Phone Interface → WebSocket → Backend Server
                             ↓
                      Process Speech (ASR)
                             ↓
                      Generate Response (LLM)
                             ↓
                      Synthesize Audio (TTS)
                             ↓
WebSocket ← Audio + Volumes ← Backend Server
    ↓
Live2D Character (Lip Sync + Animation)
```

## Status Indicators

The phone interface displays real-time status:

- **🟡 Connecting...**: Establishing connection to backend
- **🔴 Ready to talk**: Connected but idle
- **🟢 Listening...**: Microphone active, detecting speech
- **🔵 Speaking...**: AI is generating or playing response

## Backend Message Types Handled

The phone interface handles all standard backend WebSocket messages:

- `set-model-and-conf`: Load Live2D model and configuration
- `audio`: TTS audio with volume data for lip sync
- `control`: Microphone control commands
- `full-text`: Subtitle text display
- `conversation-chain-start/end`: AI state management

## Mobile Considerations

When accessing the phone interface on mobile devices:

1. **HTTPS Required**: Microphone access requires HTTPS (except on localhost)
2. **Touch Gestures**: Large touch-friendly buttons for call controls
3. **Full Screen**: Optimized for mobile viewport sizes
4. **Responsive Design**: Adapts to different screen sizes

## Troubleshooting

### Common Issues

1. **No Character Display**
   - Check backend server is running
   - Verify WebSocket connection (check browser console)
   - Ensure backend has Live2D models configured

2. **No Audio**
   - Check microphone permissions
   - Verify backend TTS is configured
   - Check browser audio settings

3. **Connection Failed**
   - Verify backend server address in WebSocket settings
   - Check firewall/network settings
   - Try refreshing the page

### Debug Information

Check browser console for WebSocket messages and connection status:
```javascript
// Check WebSocket state
console.log(wsState);

// Check AI state
console.log(aiState);

// Check microphone state
console.log(micOn);
```

## Architecture Benefits

The phone calling interface maintains the same robust architecture as the main application:

- **Reusable Components**: Uses existing Live2D, WebSocket, and context systems
- **Consistent State Management**: Same AI state and microphone management
- **Backend Agnostic**: Works with any Open-LLM-VTuber backend configuration
- **Feature Complete**: Supports all backend features (TTS, ASR, expressions, etc.)

## Future Enhancements

Potential improvements for phone mode:

1. **Video Calling**: Camera integration for visual perception
2. **Speaker Toggle**: Actual audio output control
3. **Call History**: Recent conversation access
4. **Quick Actions**: Preset conversation starters
5. **Mobile Optimizations**: Better mobile UX features