import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

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
      home: const GameScreen(),
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
  static const double gameSpeed = 0.015; // Speed of obstacles moving left
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

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
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
    if (!isPlaying || isGameOver) return;

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
        obstacles[i][0] -= gameSpeed;
      }

      // 4. Remove off-screen obstacles
      if (obstacles.isNotEmpty && obstacles[0][0] < -1.5) {
        obstacles.removeAt(0);
        score++;
      }

      // 5. Spawn new obstacles
      timeSinceLastObstacle += gameSpeed;
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
    // Player is 50x50. On a typical screen (width 400), 50px is ~0.25 in alignment width (range 2.0)
    // Height is similar.
    
    // Let's define hitboxes relative to center points
    double playerWidthHalf = 0.12; // Half width in alignment units
    double playerHeightHalf = 0.12; // Half height in alignment units
    
    for (var obstacle in obstacles) {
      double obsX = obstacle[0];
      double obsY = groundLevel; // Spikes sit on ground
      
      // Obstacle hitbox (Spike)
      // Spike is triangular, but we'll use a smaller rect for forgiveness
      double obsWidthHalf = 0.1;
      double obsHeightHalf = 0.1;

      // Calculate centers
      // Player center is (playerX, playerY - playerHeightHalf) because player sits ON ground at playerY
      // Wait, Alignment(0,0) is center of widget.
      // If I align(playerX, playerY), the center of the 50x50 box is at playerX, playerY.
      // So if playerY = groundLevel, the center of the box is at groundLevel.
      // This means half the box is below ground!
      // I should adjust the visual alignment so the bottom of the box is at playerY.
      
      // Actually, let's keep it simple:
      // playerY is the vertical center of the player.
      // groundLevel is the vertical center of the ground line? No, groundLevel is a Y coordinate.
      // If I want player to stand ON ground, and playerY is the center, then ground is at playerY + height/2.
      
      // Let's assume playerY tracks the CENTER of the player.
      // Ground is at `groundLevel + playerHeightHalf`.
      // But in my code: `if (playerY > groundLevel) playerY = groundLevel;`
      // This implies playerY stops at groundLevel.
      // So visually, the player sinks halfway into the floor if I don't offset it.
      // I will handle this in the build method with a transform or margin, OR just accept it for the logic.
      
      // Let's check overlap of two rectangles defined by centers (playerX, playerY) and (obsX, obsY)
      
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
    // Adjust visual position so player sits ON TOP of the logical Y position if Y represents the ground contact point?
    // No, let's stick to: playerY is the center of the player.
    // Ground is drawn at groundLevel + offset.
    
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
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
                  colors: [
                    Colors.blueGrey[800]!,
                    Colors.blueGrey[900]!,
                  ],
                ),
              ),
            ),
            
            // Ground
            // We draw the ground slightly below the player's lowest point
            // Player center is at groundLevel. Player height is ~50px.
            // So ground should be at groundLevel + (50px in alignment units).
            // 50px is approx 0.15 height units.
            Align(
              alignment: Alignment(0, groundLevel + 0.15), 
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height, // Fill rest of screen
                color: Colors.black,
              ),
            ),
            Align(
              alignment: Alignment(0, groundLevel + 0.15),
              child: Container(
                width: double.infinity,
                height: 4,
                color: Colors.white,
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
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
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
                child: Container(
                  width: 50,
                  height: 50,
                  child: CustomPaint(
                    painter: SpikePainter(),
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
                        isGameOver ? 'GAME OVER' : 'GEOMETRY\nDASH',
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
                      Container(
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
                          isGameOver ? 'TAP TO RESTART' : 'TAP TO START',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw a triangle
    path.moveTo(0, size.height); // Bottom left
    path.lineTo(size.width / 2, 0); // Top center
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
