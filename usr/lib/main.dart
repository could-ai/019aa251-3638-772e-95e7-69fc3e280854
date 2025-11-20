import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

// Data structure for a level
class Level {
  final String name;
  final double gameSpeed;
  final List<Color> backgroundColors;
  final Color groundColor;
  final Color playerColor;
  final Color spikeColor;

  const Level({
    required this.name,
    required this.gameSpeed,
    required this.backgroundColors,
    required this.groundColor,
    required this.playerColor,
    required this.spikeColor,
  });
}

// List of predefined levels
final List<Level> levels = [
  const Level(
    name: 'Level 1: First Steps',
    gameSpeed: 0.015,
    backgroundColors: [Color(0xFF00395B), Color(0xFF002B4A)],
    groundColor: Color(0xFF001C30),
    playerColor: Colors.greenAccent,
    spikeColor: Colors.redAccent,
  ),
  const Level(
    name: 'Level 2: Speedy Spikes',
    gameSpeed: 0.020,
    backgroundColors: [Color(0xFF4A003A), Color(0xFF3A002C)],
    groundColor: Color(0xFF2A001E),
    playerColor: Colors.yellow,
    spikeColor: Colors.cyanAccent,
  ),
  const Level(
    name: 'Level 3: The Gauntlet',
    gameSpeed: 0.025,
    backgroundColors: [Color(0xFF5A1D00), Color(0xFF4A1000)],
    groundColor: Color(0xFF3A0A00),
    playerColor: Colors.orange,
    spikeColor: Colors.white,
  ),
];


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geometry Dash Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/levels': (context) => const LevelSelectionScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[800]!,
              Colors.blueGrey[900]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'GEOMETRY\nDASH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      blurRadius: 15.0,
                      color: Colors.black,
                      offset: Offset(4.0, 4.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Play Button with Pulse Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/levels');
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 80,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SELECT LEVEL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[800]!,
              Colors.blueGrey[900]!,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: level.backgroundColors.first.withOpacity(0.8),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: level.playerColor, width: 2),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                title: Text(
                  level.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  'Speed: ${(level.gameSpeed * 1000).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Icon(Icons.play_circle_fill, color: level.playerColor, size: 30),
                onTap: () {
                  Navigator.pushNamed(context, '/game', arguments: level);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Game Physics Constants
  static const double gravity = 0.0025; // Gravity pulling down
  static const double jumpStrength = -0.065; // Jump force (negative goes up)
  static const double groundLevel = 0.7; // Y position of the ground (Alignment)

  // Player State
  double playerY = groundLevel;
  double playerVelocity = 0.0;
  double playerX = -0.7; // Fixed horizontal position

  // Game State
  bool isPlaying = false;
  bool isGameOver = false;
  int score = 0;
  late Ticker _ticker;
  
  // Obstacles
  // Each obstacle is a list [x_position, type] where type 0=spike
  List<List<double>> obstacles = [];
  double timeSinceLastObstacle = 0;

  // Level data
  late Level currentLevel;
  bool _levelInitialized = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_levelInitialized) {
      final level = ModalRoute.of(context)!.settings.arguments as Level?;
      if (level != null) {
        currentLevel = level;
      } else {
        // Fallback to a default level if no arguments are passed
        currentLevel = levels[0];
      }
      _levelInitialized = true;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      playerY = groundLevel;
      playerVelocity = 0.0;
      obstacles.clear();
      score = 0;
      isPlaying = true;
      isGameOver = false;
      timeSinceLastObstacle = 0;
    });
    _ticker.start();
  }

  void _jump() {
    if (!isPlaying) {
      if (isGameOver) {
        _startGame();
      } else {
        _startGame();
        // Initial jump
        setState(() {
          playerVelocity = jumpStrength;
        });
      }
    } else {
      // Only jump if on ground
      if (playerY >= groundLevel - 0.05) {
        setState(() {
          playerVelocity = jumpStrength;
        });
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (!isPlaying || isGameOver || !_levelInitialized) return;

    setState(() {
      // 1. Apply Gravity
      playerVelocity += gravity;
      playerY += playerVelocity;

      // 2. Ground Collision
      if (playerY > groundLevel) {
        playerY = groundLevel;
        playerVelocity = 0.0;
      }

      // 3. Move Obstacles
      for (int i = 0; i < obstacles.length; i++) {
        obstacles[i][0] -= currentLevel.gameSpeed;
      }

      // 4. Remove off-screen obstacles
      if (obstacles.isNotEmpty && obstacles[0][0] < -1.5) {
        obstacles.removeAt(0);
        score++;
      }

      // 5. Spawn new obstacles
      timeSinceLastObstacle += currentLevel.gameSpeed;
      // Spawn logic: random gap between 1.0 and 2.5 seconds worth of distance
      if (timeSinceLastObstacle > 0.8 + Random().nextDouble() * 1.2) { 
        obstacles.add([1.5, 0]); // Spawn at right edge
        timeSinceLastObstacle = 0;
      }

      // 6. Collision Detection
      _checkCollision();
    });
  }

  void _checkCollision() {
    // Player hitbox approximation in Alignment units
    double playerWidthHalf = 0.12; // Half width in alignment units
    double playerHeightHalf = 0.12; // Half height in alignment units
    
    for (var obstacle in obstacles) {
      double obsX = obstacle[0];
      double obsY = groundLevel; // Spikes sit on ground
      
      // Obstacle hitbox (Spike)
      double obsWidthHalf = 0.1;
      double obsHeightHalf = 0.1;

      double dx = (playerX - obsX).abs();
      double dy = (playerY - obsY).abs();
      
      if (dx < (playerWidthHalf + obsWidthHalf) * 0.8 && // 0.8 for slightly forgiving width
          dy < (playerHeightHalf + obsHeightHalf) * 0.8) { // 0.8 for forgiving height
        _gameOver();
      }
    }
  }

  void _gameOver() {
    _ticker.stop();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure level is initialized before building
    if (!_levelInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: currentLevel.backgroundColors.last,
      body: GestureDetector(
        onTapDown: (_) => _jump(), // Use onTapDown for instant response
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: currentLevel.backgroundColors,
                ),
              ),
            ),
            
            // Ground
            Align(
              alignment: Alignment(0, groundLevel + 0.15), 
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height, // Fill rest of screen
                color: currentLevel.groundColor,
              ),
            ),
            Align(
              alignment: Alignment(0, groundLevel + 0.15),
              child: Container(
                width: double.infinity,
                height: 4,
                color: currentLevel.playerColor.withOpacity(0.5),
              ),
            ),

            // Player
            Align(
              alignment: Alignment(playerX, playerY),
              child: Transform.rotate(
                angle: playerVelocity * 5, // Rotate while jumping
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentLevel.playerColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: currentLevel.playerColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Obstacles
            ...obstacles.map((obs) {
              return Align(
                alignment: Alignment(obs[0], groundLevel),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CustomPaint(
                    painter: SpikePainter(color: currentLevel.spikeColor),
                  ),
                ),
              );
            }).toList(),

            // Score
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Start / Game Over Screen
            if (!isPlaying)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isGameOver ? 'GAME OVER' : 'READY?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isGameOver ? Colors.redAccent : Colors.greenAccent,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _startGame,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Text(
                            isGameOver ? 'RESTART' : 'START',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Menu Button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text(
                            'MENU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SpikePainter extends CustomPainter {
  final Color color;

  SpikePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw a triangle
    path.moveTo(0, size.height); // Bottom left
    path.lineTo(size.width / 2, 0); // Top center
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
    
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
