/// Server endpoints. Override at build time with --dart-define,
/// e.g. --dart-define=WS_URL=ws://localhost:8080/ws
const String kWsUrl = String.fromEnvironment(
  'WS_URL',
  defaultValue: 'wss://chilusoft.dev/ws',
);

const String kHttpBase = String.fromEnvironment(
  'HTTP_BASE',
  defaultValue: 'https://chilusoft.dev',
);
