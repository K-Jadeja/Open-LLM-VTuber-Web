import { Box, Flex, Text, IconButton, VStack } from "@chakra-ui/react";
import { useState, useEffect } from "react";
import { FiPhoneOff, FiMic, FiMicOff, FiVolume2, FiVolumeX } from "react-icons/fi";
import { Live2D } from "@/components/canvas/live2d";
import { useAiState } from "@/context/ai-state-context";
import { useVAD } from "@/context/vad-context";
import { useWebSocket } from "@/context/websocket-context";
import { phoneCallStyles } from "./phone-call-styles";

interface PhoneCallAppProps {
  onHangUp?: () => void;
}

export function PhoneCallApp({ onHangUp }: PhoneCallAppProps): JSX.Element {
  const { aiState } = useAiState();
  const { micOn, startMic, stopMic } = useVAD();
  const { wsState } = useWebSocket();
  const [speakerOn, setSpeakerOn] = useState(true);

  // Auto-start microphone when component mounts
  useEffect(() => {
    if (wsState === 'OPEN' && !micOn) {
      startMic();
    }
  }, [wsState, micOn, startMic]);

  const handleMicToggle = () => {
    if (micOn) {
      stopMic();
    } else {
      startMic();
    }
  };

  const handleSpeakerToggle = () => {
    setSpeakerOn(!speakerOn);
    // Note: In a real implementation, this would control audio output
  };

  const handleHangUp = () => {
    stopMic();
    onHangUp?.();
  };

  const getStatusText = () => {
    if (wsState !== 'OPEN') return 'Connecting...';
    
    switch (aiState) {
      case 'idle':
        return 'Ready to talk';
      case 'listening':
        return 'Listening...';
      case 'thinking-speaking':
        return 'Speaking...';
      default:
        return 'Connected';
    }
  };

  const getStatusColor = () => {
    if (wsState !== 'OPEN') return 'yellow.400';
    
    switch (aiState) {
      case 'listening':
        return 'green.400';
      case 'thinking-speaking':
        return 'blue.400';
      default:
        return 'gray.400';
    }
  };

  return (
    <Box {...phoneCallStyles.container}>
      {/* Status Bar */}
      <Box {...phoneCallStyles.statusBar}>
        <Flex align="center" justify="center" gap={2}>
          <Box
            {...phoneCallStyles.statusIndicator}
            bg={getStatusColor()}
          />
          <Text {...phoneCallStyles.statusText}>
            {getStatusText()}
          </Text>
        </Flex>
      </Box>

      {/* VTuber Character Display */}
      <Box {...phoneCallStyles.characterContainer}>
        <Live2D showSidebar={false} />
      </Box>

      {/* Call Controls */}
      <VStack {...phoneCallStyles.controlsContainer}>
        <Flex {...phoneCallStyles.controlsRow}>
          {/* Mute Button */}
          <IconButton
            {...phoneCallStyles.controlButton}
            {...phoneCallStyles.muteButton(micOn)}
            onClick={handleMicToggle}
            aria-label={micOn ? "Mute microphone" : "Unmute microphone"}
          >
            {micOn ? <FiMic size={24} /> : <FiMicOff size={24} />}
          </IconButton>

          {/* Hang Up Button */}
          <IconButton
            {...phoneCallStyles.controlButton}
            {...phoneCallStyles.hangUpButton}
            onClick={handleHangUp}
            aria-label="Hang up call"
          >
            <FiPhoneOff size={28} />
          </IconButton>

          {/* Speaker Button */}
          <IconButton
            {...phoneCallStyles.controlButton}
            {...phoneCallStyles.speakerButton(speakerOn)}
            onClick={handleSpeakerToggle}
            aria-label={speakerOn ? "Turn off speaker" : "Turn on speaker"}
          >
            {speakerOn ? <FiVolume2 size={24} /> : <FiVolumeX size={24} />}
          </IconButton>
        </Flex>
      </VStack>
    </Box>
  );
}