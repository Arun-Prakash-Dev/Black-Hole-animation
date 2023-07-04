// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double cardSize = 150;
  late final holeSizeTween = Tween<double>(begin: 0, end: cardSize * 2);

  late final holeAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  double get holeSize => holeSizeTween.evaluate(holeAnimationController);

  late final cardOffsetAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  late final cardOffsetTween = Tween<double>(
    begin: 0,
    end: cardSize * 3,
  ).chain(CurveTween(curve: Curves.easeInBack));

  late final cardRotationTween = Tween<double>(
    begin: 0,
    end: 0.5,
  ).chain(CurveTween(curve: Curves.easeInBack));

  late final cardElevationTween = Tween<double>(begin: 0, end: 50);

  double get cardoffset =>
      cardOffsetTween.evaluate(cardOffsetAnimationController);
  double get cardRotation =>
      cardRotationTween.evaluate(cardOffsetAnimationController);
  double get cardElevation =>
      cardElevationTween.evaluate(cardOffsetAnimationController);

  @override
  void initState() {
    holeAnimationController.addListener(() => setState(() {}));
    cardOffsetAnimationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    holeAnimationController.dispose();
    cardOffsetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Tween'),
      // ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            onPressed: () async {
              holeAnimationController.forward();
              await cardOffsetAnimationController.forward();
              Future.delayed(const Duration(milliseconds: 300),
                  () => holeAnimationController.reverse());
            },
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              holeAnimationController.forward();
              cardOffsetAnimationController.reverse();
              Future.delayed(const Duration(milliseconds: 300),
                  () => holeAnimationController.reverse());
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
      body: Container(
        color: Colors.black87,
        child: CustomPaint(
          painter: BackgroundPainter(),
          child: Center(
            child: SizedBox(
                height: cardSize * 1.25,
                child: ClipPath(
                  clipper: BlackHoleClipper(),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        width: holeSize,
                        child: Image.asset(
                          "images/hole.jpg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, cardoffset),
                            child: Transform.rotate(
                              angle: cardRotation,
                              child: AnimationCard(
                                elevation: cardElevation,
                                size: cardSize,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

class BlackHoleClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height / 2);
    path.arcTo(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height),
      0,
      pi,
      true,
    );
    path.lineTo(0, -1000);
    // path.lineTo(size.width, -1000);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    List<Offset> points = [];

    int ratio = 25;
    double width = size.width;
    double height = size.height;

    for (double i = width / ratio;
        i <= width * (ratio - 1) / ratio;
        i = i + width / ratio) {
      for (double j = height / ratio;
          j <= height * (ratio - 1) / ratio;
          j = j + height / ratio) {
        points.add(Offset(i, j));
      }
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    Key? key,
    required this.elevation,
    required this.size,
  }) : super(key: key);

  final double size, elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white70),
          child: const Center(
              child: Text(
            "Hello Guys",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
