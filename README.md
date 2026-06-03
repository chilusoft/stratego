# stratego

A **Reversi (Othello)** game built with Flutter. Play against an AI opponent or with two players on the same device. Features a minimax AI with alpha-beta pruning, a clean dark-themed UI, and a tutorial for new players.

**Play in your browser:** [chilusoft.github.io/stratego](https://chilusoft.github.io/stratego/)

## Features

- **vs AI**: Play as Black against a minimax AI with alpha-beta pruning (4 difficulty levels)
- **Two-player**: Hot-seat mode — two players share the device and take turns
- **Timed mode**: Chess-clock timer (3/5/10 min per player) with timeout
- **Tutorial**: Animated multi-page tutorial explaining rules with visual demos
- **Pass**: When you have no valid moves, use the Pass button
- **Move hints**: Valid cells are highlighted in green

## How to Play

- **Objective**: Have the most pieces of your color when the game ends
- **Setup**: 4 pieces start in the center (2 black, 2 white, diagonally)
- **Black moves first**. Place a piece on an empty cell that outflanks opponent pieces
- **Outflanking**: Your new piece must form a straight line (horizontal, vertical, or diagonal) with another of your pieces, with opponent pieces in between
- **Flipping**: All outflanked opponent pieces are flipped to your color
- **Passing**: If you have no valid moves, you pass and your opponent goes again
- **Game Over**: Ends when neither player can move. Most pieces wins

## Building for Android on `linux-arm64` (an experiment)

This APK was built on a **linux-arm64 (aarch64) host** — an architecture that Flutter does not officially support for Android builds. Below is how it was achieved.

### The problem

Flutter's Android build pipeline requires several **x86_64 binary tools** that have no `linux-arm64` variants in Flutter's SDK cache:

| Tool | Purpose | Host arch |
|------|---------|-----------|
| `gen_snapshot` | AOT compiles Dart to native code | x86_64 only |
| `aapt2` | Android Asset Packaging Tool | x86_64 only |

On `linux-arm64`, Flutter looks for these under `.../engine/android-*-release/linux-arm64/` but the SDK only ships `linux-x64` versions. This causes the build to fail immediately with `ProcessException: Failed to find "gen_snapshot"`.

### The solution (qemu-user-static)

1. **Install qemu-user-static** — enables running x86_64 binaries on arm64 via emulation.
2. **Create wrapper scripts** for each missing binary:
   - `gen_snapshot` wrappers in every `android-*-release/linux-arm64/` directory that delegate to the `linux-x64` binary via `qemu-x86_64-static`.
   - `aapt2` wrappers in the Android SDK's `build-tools/` directories (rename original `aapt2` → `aapt2.x86_64`, replace with a script that calls `qemu-x86_64-static`).
3. **Override AGP's aapt2 path** in `gradle.properties`:
   ```
   android.aapt2FromMavenOverride=/opt/android-sdk/build-tools/36.0.0/aapt2
   ```
   Without this, AGP extracts its own aapt2 from Maven (also x86_64) and the wrapper doesn't apply.

### Results

| Build type | Size | Status |
|------------|------|--------|
| `flutter build apk --debug` | ~1.4 GB (all archs) | ✅ Works natively (no AOT) |
| `flutter build apk --release --target-platform android-arm64` | **169.5 MB** | ✅ Works with qemu |

### Why this is technically difficult

- **No official Flutter SDK support**: The Flutter team does not publish `linux-arm64` Android engine artifacts. The precache command downloads `linux-x64` artifacts only.
- **AOT compilation under emulation**: `gen_snapshot` is CPU-intensive and must cross-compile Dart to native ARM64 code while itself running under x86_64 emulation. On slow hardware this can take 10+ minutes.
- **Multiple non-obvious failure points**: Even after fixing `gen_snapshot`, `aapt2` (from AGP Maven cache), the Kotlin daemon, and Gradle's immutable workspace caching can all fail in opaque ways on arm64.
- **Gradle cache poisoning**: The Gradle transform cache for aapt2 is marked immutable; if it's extracted as an x86_64 binary and run on arm64 without qemu, the cache entry gets corrupted and must be manually purged.

### Play Online

Play in your browser at **[chilusoft.github.io/stratego](https://chilusoft.github.io/stratego/)** — no installation required.

### Installing the APK

Download from [GitHub Releases](https://github.com/chilusoft/stratego/releases) and install:

```bash
adb install app-release.apk
```
