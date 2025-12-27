import 'package:flutter/material.dart';

// Run with:
// flutter run -d chrome -t lib/generate_icons.dart
// Then take a screenshot and save to assets/icons/
void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Icon Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const IconGenerator(),
    );
  }
}

class IconGenerator extends StatelessWidget {
  const IconGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Icon Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Take a screenshot of each icon below and save to assets/icons/',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text('app_icon.png (1024x1024)'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: HeartIcon(
                        showBackground: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    const Text('icon_foreground.png (1024x1024)'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: HeartIcon(
                        showBackground: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeartIcon extends StatelessWidget {
  final bool showBackground;
  
  const HeartIcon({
    super.key,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: showBackground ? const Color(0xFF0a2351) : Colors.transparent,
        border: showBackground ? null : Border.all(color: Colors.grey),
      ),
      child: CustomPaint(
        painter: HeartPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    // Heart parameters
    final center = Offset(width / 2, height / 2);
    final heartSize = width * 0.75;
    
    // Create heart path for modern flat design
    final Path heartPath = Path();
    
    // Create the heart shape with cleaner lines
    // Top left curve
    heartPath.moveTo(center.dx, center.dy - heartSize * 0.05);
    heartPath.cubicTo(
      center.dx - heartSize * 0.25, center.dy - heartSize * 0.15,
      center.dx - heartSize * 0.38, center.dy - heartSize * 0.03,
      center.dx - heartSize * 0.35, center.dy + heartSize * 0.05,
    );
    
    // Bottom left curve
    heartPath.cubicTo(
      center.dx - heartSize * 0.3, center.dy + heartSize * 0.25,
      center.dx - heartSize * 0.1, center.dy + heartSize * 0.3,
      center.dx, center.dy + heartSize * 0.4,
    );
    
    // Bottom right curve
    heartPath.cubicTo(
      center.dx + heartSize * 0.1, center.dy + heartSize * 0.3,
      center.dx + heartSize * 0.3, center.dy + heartSize * 0.25,
      center.dx + heartSize * 0.35, center.dy + heartSize * 0.05,
    );
    
    // Top right curve
    heartPath.cubicTo(
      center.dx + heartSize * 0.38, center.dy - heartSize * 0.03,
      center.dx + heartSize * 0.25, center.dy - heartSize * 0.15,
      center.dx, center.dy - heartSize * 0.05,
    );
    
    // Close the path
    heartPath.close();
    
    // Draw the heart with modern pink/red color
    final Paint heartPaint = Paint()
      ..color = const Color(0xFFff3b5c)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(heartPath, heartPaint);
    
    // Add subtle shadow for depth
    final Path shadowPath = Path();
    
    // Create shadow path
    shadowPath.addPath(heartPath, Offset(0, heartSize * 0.02));
    shadowPath.close();
    
    // Draw the shadow with semi-transparent black
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Add light reflection at the top for modern look
    final Path reflectionPath = Path();
    
    // Create the reflection shape
    reflectionPath.moveTo(center.dx - heartSize * 0.25, center.dy - heartSize * 0.05);
    reflectionPath.cubicTo(
      center.dx - heartSize * 0.25, center.dy - heartSize * 0.08,
      center.dx - heartSize * 0.1, center.dy - heartSize * 0.1,
      center.dx, center.dy - heartSize * 0.03,
    );
    reflectionPath.cubicTo(
      center.dx + heartSize * 0.1, center.dy - heartSize * 0.1,
      center.dx + heartSize * 0.25, center.dy - heartSize * 0.08,
      center.dx + heartSize * 0.25, center.dy - heartSize * 0.05,
    );
    reflectionPath.lineTo(center.dx + heartSize * 0.2, center.dy + heartSize * 0.1);
    reflectionPath.cubicTo(
      center.dx + heartSize * 0.1, center.dy + heartSize * 0.05,
      center.dx - heartSize * 0.1, center.dy + heartSize * 0.05,
      center.dx - heartSize * 0.2, center.dy + heartSize * 0.1,
    );
    reflectionPath.close();
    
    // Draw the reflection with semi-transparent white
    final Paint reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(reflectionPath, reflectionPaint);
    
    // Add small circle for modern aesthetic
    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx + heartSize * 0.2, center.dy - heartSize * 0.1),
      heartSize * 0.05,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 