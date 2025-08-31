const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());

// Serve Live2D models from the backend directory
app.use('/live2d-models', express.static(path.join(__dirname, 'backend', 'live2d-models')));

// Create WebSocket server on port 12393 (same as backend)
const wss = new WebSocket.Server({ port: 12393, path: '/client-ws' });

console.log('Mock backend started on ws://127.0.0.1:12393/client-ws');
console.log('HTTP server will serve Live2D models on http://127.0.0.1:12394/live2d-models/');

wss.on('connection', function connection(ws) {
  console.log('Frontend connected to mock backend');
  
  // Send initial model configuration when client connects
  setTimeout(() => {
    ws.send(JSON.stringify({
      type: 'set-model-and-conf',
      model_info: {
        model_name: 'Mao Pro',
        url: 'http://127.0.0.1:12394/live2d-models/mao_pro/runtime/mao_pro.model3.json',
        kScale: 0.5,
        initialXshift: 0,
        initialYshift: 0,
        idleMotionGroupName: 'idle',
        defaultEmotion: 0,
        emotionMap: {},
        pointerInteractive: true,
        scrollToResize: true,
        initialScale: 1.0
      },
      conf_name: 'default',
      conf_uid: 'demo-config-123'
    }));
  }, 1000);

  // Simulate periodic AI responses
  let messageCount = 0;
  const interval = setInterval(() => {
    messageCount++;
    
    // Send chat message
    ws.send(JSON.stringify({
      type: 'conversation',
      content: `This is mock message ${messageCount} from the VTuber backend`,
      role: 'ai',
      timestamp: new Date().toISOString(),
      name: 'Mock VTuber',
      avatar: ''
    }));

    // Occasionally send audio with lip sync data
    if (messageCount % 3 === 0) {
      ws.send(JSON.stringify({
        type: 'audio',
        audio: '', // Empty base64 audio for demo
        volumes: Array.from({length: 50}, () => Math.random() * 0.5 + 0.2), // Mock volume array for lip sync
        slice_length: 0.02,
        display_text: {
          text: `Speaking mock message ${messageCount}`,
          name: 'Mock VTuber',
          avatar: ''
        }
      }));
    }
  }, 5000);

  ws.on('message', function message(data) {
    const msg = JSON.parse(data.toString());
    console.log('Received from frontend:', msg);
    
    // Respond to different message types
    switch (msg.type) {
      case 'fetch-backgrounds':
        ws.send(JSON.stringify({
          type: 'backgrounds',
          files: [
            { name: 'Default', url: '' }
          ]
        }));
        break;
        
      case 'fetch-configs':
        ws.send(JSON.stringify({
          type: 'configs',
          configs: [
            { name: 'default', content: {} }
          ]
        }));
        break;
        
      case 'fetch-history-list':
        ws.send(JSON.stringify({
          type: 'history-list',
          histories: []
        }));
        break;
        
      case 'create-new-history':
        ws.send(JSON.stringify({
          type: 'history-created',
          success: true
        }));
        break;
    }
  });

  ws.on('close', function close() {
    console.log('Frontend disconnected');
    clearInterval(interval);
  });
});

// Express server for any HTTP endpoints (optional)
app.listen(12394, () => {
  console.log('Mock HTTP server running on http://127.0.0.1:12394');
});