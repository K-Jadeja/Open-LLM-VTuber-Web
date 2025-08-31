// Phone call interface styles optimized for mobile devices

export const phoneCallStyles = {
  container: {
    width: '100vw',
    height: '100vh',
    bg: 'linear-gradient(135deg, gray.900 0%, gray.800 50%, gray.900 100%)',
    color: 'white',
    display: 'flex',
    flexDirection: 'column' as const,
    overflow: 'hidden',
    position: 'relative' as const,
  },

  statusBar: {
    position: 'absolute' as const,
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    py: 4,
    px: 4,
    bg: 'blackAlpha.300',
    backdropFilter: 'blur(10px)',
  },

  statusIndicator: {
    width: '8px',
    height: '8px',
    borderRadius: 'full',
    animation: 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
  },

  statusText: {
    fontSize: 'sm',
    fontWeight: 'medium',
    color: 'whiteAlpha.900',
  },

  characterContainer: {
    flex: 1,
    position: 'relative' as const,
    width: '100%',
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    mt: '60px', // Account for status bar
    mb: '120px', // Account for controls
  },

  controlsContainer: {
    position: 'absolute' as const,
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    p: 6,
    pb: { base: 8, '@supports(env(safe-area-inset-bottom))': 'calc(2rem + env(safe-area-inset-bottom))' },
    bg: 'linear-gradient(to top, blackAlpha.800 0%, blackAlpha.400 70%, transparent 100%)',
    backdropFilter: 'blur(10px)',
  },

  controlsRow: {
    gap: 8,
    align: 'center',
    justify: 'center',
    width: '100%',
    maxW: '320px',
    mx: 'auto',
  },

  controlButton: {
    size: 'lg',
    borderRadius: 'full',
    color: 'white',
    transition: 'all 0.2s',
    _active: {
      transform: 'scale(0.95)',
    },
  },

  muteButton: (micOn: boolean) => ({
    bg: micOn ? 'whiteAlpha.200' : 'red.500',
    _hover: {
      bg: micOn ? 'whiteAlpha.300' : 'red.600',
      transform: 'scale(1.05)',
    },
    border: micOn ? '2px solid' : 'none',
    borderColor: micOn ? 'green.400' : 'transparent',
  }),

  hangUpButton: {
    bg: 'red.500',
    size: 'xl',
    width: '80px',
    height: '80px',
    _hover: {
      bg: 'red.600',
      transform: 'scale(1.05)',
    },
    _active: {
      transform: 'scale(0.95)',
    },
    shadow: 'lg',
  },

  speakerButton: (speakerOn: boolean) => ({
    bg: speakerOn ? 'blue.500' : 'whiteAlpha.200',
    _hover: {
      bg: speakerOn ? 'blue.600' : 'whiteAlpha.300',
      transform: 'scale(1.05)',
    },
  }),
};

// CSS keyframes for animations (would be added to global styles)
export const phoneCallKeyframes = `
  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }
`;