# Backend Integration Guide

This guide explains how to run both the frontend and backend components of Open-LLM-VTuber together.

## Quick Setup

### 1. Frontend Setup

```bash
# Install frontend dependencies
npm install

# Start the web development server
npm run dev:web
```

The frontend will be available at `http://localhost:3000`

### 2. Backend Setup

The repository now includes the Open-LLM-VTuber backend as a git submodule in the `backend/` directory.

#### Option A: Using the Mock Backend (for testing)

For quick testing of the phone interface integration:

```bash
# Install additional dependencies for mock backend
npm install ws cors express

# Start the mock backend
node mock-backend.js
```

#### Option B: Using the Full Python Backend

```bash
cd backend

# Install Python dependencies (excluding macOS-specific packages on Linux)
pip3 install -r requirements.txt

# Start the backend server
python3 run_server.py
```

## Testing the Phone Interface

1. Open the frontend at `http://localhost:3000`
2. Click the "Mode Menu" button (gear icon in top toolbar)
3. Select "Phone Call" from the dropdown
4. The interface should show "Connected" when the backend is running
5. You should see call controls (mute, hang up, speaker)

## WebSocket Connection

The frontend connects to the backend via WebSocket at:
- **URL**: `ws://127.0.0.1:12393/client-ws`
- **Protocol**: WebSocket with JSON message format

### Connection States

The phone interface displays different status messages based on the WebSocket connection state:

- **"Connecting..."** - When attempting to connect to the backend
- **"Connected"** - When successfully connected to the backend
- **"Ready to talk"** - When connection is stable and AI is idle
- **"Listening..."** - When the AI is processing voice input
- **"Speaking..."** - When the AI is generating audio response

## Architecture

The integration reuses the existing WebSocket infrastructure:

- **WebSocketContext**: Manages connection state and provides real-time updates
- **WebSocketService**: Handles the actual WebSocket connection and message routing
- **PhoneCallApp**: The phone interface component that displays connection status

## Message Types

The backend sends various message types that the frontend handles:

- `set-model-and-conf`: Loads the Live2D model
- `audio`: Streams TTS audio with lip sync data
- `conversation`: Chat messages for display
- `control`: Microphone and system control messages

## Troubleshooting

### Connection Issues

1. **"Connecting..." shows indefinitely**
   - Check if the backend server is running on port 12393
   - Verify WebSocket endpoint is accessible at `ws://127.0.0.1:12393/client-ws`

2. **Mock backend for testing**
   - The included `mock-backend.js` simulates the Python backend for testing
   - It sends sample model configuration and periodic messages
   - Useful for frontend development without full backend setup

3. **Network errors**
   - Ensure no firewall is blocking port 12393
   - Check browser console for WebSocket connection errors

### Backend Dependencies

- Python 3.8+ required
- Some packages may not install on non-macOS systems (pyobjc)
- Use the filtered requirements file for Linux/Windows systems

## Development

The phone interface integrates seamlessly with the existing Live2D system:

- Uses the same Live2D canvas component
- Shares audio processing and lip sync functionality
- Maintains state consistency with the main interface

The WebSocket connection state is now properly managed and provides real-time feedback to users about the backend connectivity status.