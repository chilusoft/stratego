# Multiplayer Platform Plan

## Repositories

- **Client (this repo)**: Flutter game app (Reversi now, Chess/Checkers later) — `chilusoft/stratego`
- **Server**: `chilusoft/stratego-server` — Node.js/TypeScript game server

## Architecture

```
Flutter client
   │  ├─ WebSocket (real-time gameplay, matchmaking)
   │  ├─ REST (profiles, leaderboard, discovery/lobby)
   │  └─ Google Sign-In → auth token
   ▼
stratego-server (Node.js)
   ├─ Auth service (verifies Google ID tokens, issues session JWT)
   ├─ Matchmaking queue (by game mode + skill rating)
   ├─ Game rooms (WebSocket, authoritative state, clocks)
   ├─ Game engines (common interface: reversi, chess, checkers)
   ├─ Leaderboard (per-game Elo, match history)
   └─ Discovery/lobby (public rooms, invites)
   ▼
PostgreSQL + Redis (queues, active rooms)
```

## Server Repo Layout (`stratego-server`)

```
src/
  auth/          # Google ID-token verification, JWT sessions
  matchmaking/   # queueing, skill-based pairing
  rooms/         # room lifecycle, WebSocket gateway
  games/
    common/      # GameEngine interface: getMoves, applyMove, isTerminal
    reversi/     # port of logic from stratego lib/game/*
    chess/
    checkers/
  leaderboard/   # Elo, persistence, queries
  discovery/     # lobby listing, invites
  rating/
prisma/ or db/   # schema + migrations
test/
```

## Google Play Games Integration

- Google Sign-In on Android → server verifies ID token → session JWT.
- GPGS v2 plugin on client optional for achievements; matchmaking/leaderboards
  are served by our own server (not native GPGS services).

## Client Changes (this repo)

- `lib/net/`: ApiClient (REST), GameSocket (WebSocket), AuthService.
- New screens: mode select, matchmaking lobby, online game board, leaderboard.
- Reuse `lib/game/*` for local/AI; online mode renders server state.
- New deps: `google_sign_in`, `web_socket_channel`, `http`.

## Phases

| Phase | Deliverable |
|---|---|
| 1 | Server: skeleton (auth, REST leaderboard stub, WS echo), tests, Docker |
| 2 | Reversi engine server-side + online 1v1 rooms + clocks |
| 3 | Matchmaking queue + discovery/lobby |
| 4 | Leaderboard (Elo, match history, per-game rankings) |
| 5 | Chess + Checkers engines behind the common interface |
| 6 | Client integration: sign-in, online mode, lobby, leaderboard UI |
| 7 | Polish: reconnection, forfeit, rematch, CI/CD deploy |
