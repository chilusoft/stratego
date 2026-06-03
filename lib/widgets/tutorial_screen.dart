import 'dart:math';
import 'package:flutter/material.dart';
import '../game/piece.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _page = PageController();
  int _current = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      _WelcomePage(),
      _SetupPage(),
      _OutflankPage(),
      _FlipPage(),
      _GameOverPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _page,
        onPageChanged: (i) => setState(() => _current = i),
        children: pages,
      ),
      bottomNavigationBar: _BottomNav(
        current: _current,
        count: pages.length,
        onPrev: _current > 0
            ? () => _page.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
            : null,
        onNext: _current < pages.length - 1
            ? () => _page.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
            : null,
        onDone: () => Navigator.pop(context),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current, count;
  final VoidCallback? onPrev, onNext, onDone;

  const _BottomNav({
    required this.current,
    required this.count,
    this.onPrev,
    this.onNext,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = current == count - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF16213e)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onPrev,
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
            child: const Text('Back'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == current
                      ? const Color(0xFFe94560)
                      : Colors.white24,
                ),
              );
            }),
          ),
          TextButton(
            onPressed: isLast ? onDone : onNext,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFe94560),
            ),
            child: Text(isLast ? 'Done' : 'Next'),
          ),
        ],
      ),
    );
  }
}

// ---- Helper ----

Widget _tutorialPiece(Piece piece, double size) {
  if (piece == Piece.empty) return const SizedBox.shrink();
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: piece == Piece.black
            ? [Colors.grey.shade700, Colors.black]
            : [Colors.white, Colors.grey.shade300],
      ),
      border: Border.all(color: Colors.black26, width: 1),
    ),
  );
}

double _cellSize(BuildContext context) {
  final w = MediaQuery.of(context).size.width - 64;
  return (w / 8).clamp(30.0, 42.0);
}

Widget _boardFrame(Widget board) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.brown.shade800, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: board,
  );
}

typedef _BoardData = List<List<Piece>>;

_BoardData _emptyBoard() {
  return List.generate(8, (_) => List.filled(8, Piece.empty));
}

// ---- Page 1: Welcome ----

class _WelcomePage extends StatefulWidget {
  const _WelcomePage();

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final s = 0.92 + 0.08 * _ctrl.value;
              return Transform.scale(
                scale: s,
                child: _tutorialPiece(Piece.black, 80),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Reversi',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Learn how to play this classic strategy game',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(180),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),
          Icon(Icons.swipe, color: Colors.white.withAlpha(100), size: 28),
          const SizedBox(height: 8),
          Text(
            'Swipe to continue',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Page 2: Setup ----

class _SetupPage extends StatefulWidget {
  const _SetupPage();

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<_SetupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _cellSize(context);
    final board = _emptyBoard();
    board[3][3] = Piece.white;
    board[3][4] = Piece.black;
    board[4][3] = Piece.black;
    board[4][4] = Piece.white;

    final animPositions = [
      Point(3, 3),
      Point(3, 4),
      Point(4, 3),
      Point(4, 4),
    ];

    Widget cell(int r, int c) {
      final idx = animPositions.indexOf(Point(r, c));
      final p = board[r][c];
      double opacity = 1;
      double scale = 1;

      if (idx >= 0) {
        final t = ((_ctrl.value - idx * 0.18) / 0.35).clamp(0.0, 1.0);
        opacity = t;
        scale = 0.01 + t * 0.99;
      }

      return Container(
        width: cs,
        height: cs,
        decoration: BoxDecoration(
          color: const Color(0xFF2D6B2D),
          border: Border.all(color: const Color(0xFF1B5E20), width: 0.5),
        ),
        child: p != Piece.empty
            ? Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: _tutorialPiece(p, cs * 0.75),
                ),
              )
            : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const Text(
            'The Setup',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _boardFrame(Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    8, (r) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(8, (c) => cell(r, c)),
                        )),
              )),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The game starts with 4 pieces in the center.\nBlack always moves first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---- Page 3: Outflanking ----

class _OutflankPage extends StatefulWidget {
  const _OutflankPage();

  @override
  _OutflankPageState createState() => _OutflankPageState();
}

class _OutflankPageState extends State<_OutflankPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _cellSize(context);
    final board = _emptyBoard();
    board[4][3] = Piece.white;
    board[4][4] = Piece.white;
    board[4][5] = Piece.black;

    final pathCells = [Point(4, 3), Point(4, 4)];

    Widget cell(int r, int c) {
      final isValid = r == 4 && c == 2;
      final isPath = pathCells.contains(Point(r, c));
      Color bg;
      if (isValid) {
        bg = const Color(0xFF448844);
      } else if (isPath) {
        final t = ((_ctrl.value - 0.3) / 0.5).clamp(0.0, 1.0);
        bg = Color.lerp(
          const Color(0xFF2D6B2D),
          const Color(0xFFCC9933),
          t)!;
      } else {
        bg = const Color(0xFF2D6B2D);
      }

      return Container(
        width: cs,
        height: cs,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: const Color(0xFF1B5E20), width: 0.5),
        ),
        child: board[r][c] != Piece.empty
            ? Center(child: _tutorialPiece(board[r][c], cs * 0.75))
            : isValid
                ? Center(
                    child: Container(
                      width: cs * 0.25,
                      height: cs * 0.25,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                    ),
                  )
                : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Outflanking',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _boardFrame(Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    8, (r) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(8, (c) => cell(r, c)),
                        )),
              )),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap a green cell to place your piece.\nIt must outflank opponent pieces —\nyour new piece + an existing piece\nsurround opponent pieces in a straight line.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---- Page 4: Flipping (animated) ----

class _FlipPage extends StatefulWidget {
  const _FlipPage();

  @override
  _FlipPageState createState() => _FlipPageState();
}

class _FlipPageState extends State<_FlipPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _replay() {
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _cellSize(context);
    final board = _emptyBoard();
    board[4][3] = Piece.white;
    board[4][4] = Piece.white;
    board[4][5] = Piece.black;

    final newPiece = Point(4, 2);
    final flipOrder = [Point(4, 3), Point(4, 4)];

    Widget cell(int r, int c, double p) {
      final pos = Point(r, c);

      Piece piece = board[r][c];
      double opacity = 1;
      double scaleX = 1;

      if (pos == newPiece && p > 0.2) {
        final t = ((p - 0.2) / 0.2).clamp(0.0, 1.0);
        piece = Piece.black;
        opacity = t;
        scaleX = 0.01 + t * 0.99;
      } else if (flipOrder.contains(pos)) {
        final idx = flipOrder.indexOf(pos);
        final start = 0.5 + idx * 0.15;
        if (p > start) {
          final t = ((p - start) / 0.2).clamp(0.0, 1.0);
          scaleX = (cos(t * pi)).abs().clamp(0.01, 1.0);
          piece = t < 0.5 ? Piece.white : Piece.black;
        }
        // else: piece stays as board[r][c] (white)
      }

      final isValid = pos == newPiece && p <= 0.2;
      final isPhase2 = pos == newPiece && p > 0.2 && p <= 0.4;

      Color bg;
      if (isValid) {
        bg = const Color(0xFF448844);
      } else if (isPhase2 || flipOrder.contains(pos)) {
        bg = const Color(0xFF2D6B2D);
      } else {
        bg = const Color(0xFF2D6B2D);
      }

      return Container(
        width: cs,
        height: cs,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: const Color(0xFF1B5E20), width: 0.5),
        ),
        child: piece != Piece.empty
            ? Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scaleX: scaleX,
                  child: _tutorialPiece(piece, cs * 0.75),
                ),
              )
            : isValid
                ? Center(
                    child: Container(
                      width: cs * 0.25,
                      height: cs * 0.25,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                    ),
                  )
                : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Flipping',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final p = _ctrl.value;
                  return _boardFrame(Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        8, (r) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  List.generate(8, (c) => cell(r, c, p)),
                            )),
                  ));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All outflanked opponent pieces\nflip to your color!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _replay,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('Replay'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFe94560),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Page 5: Game Over ----

class _GameOverPage extends StatelessWidget {
  const _GameOverPage();

  @override
  Widget build(BuildContext context) {
    final cs = _cellSize(context);
    final board = _emptyBoard();
    board[3][3] = Piece.black;
    board[3][4] = Piece.black;
    board[4][3] = Piece.black;
    board[4][4] = Piece.black;
    board[3][5] = Piece.white;
    board[4][5] = Piece.white;
    board[5][3] = Piece.black;
    board[5][4] = Piece.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _boardFrame(Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    8, (r) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(8, (c) {
                            return Container(
                              width: cs,
                              height: cs,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D6B2D),
                                border: Border.all(
                                  color: const Color(0xFF1B5E20),
                                  width: 0.5,
                                ),
                              ),
                              child: board[r][c] != Piece.empty
                                  ? Center(
                                      child: _tutorialPiece(
                                          board[r][c], cs * 0.75),
                                    )
                                  : null,
                            );
                          }),
                        )),
              )),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'If you can\'t move, you pass.\nThe game ends when neither player\ncan move. Most pieces wins!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re ready to play!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(150),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
