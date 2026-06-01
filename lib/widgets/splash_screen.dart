import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barColors = [
      Colors.black,
      Color(0xFFFDD835), // yellow
      Color(0xFFD90429), // red
      Color(0xFF0FA65A), // green
      Color(0xFF1E9CCC), // blue
    ];

    return Scaffold(
      body: Column(
        children: [
          // 5 colored bars at top
          Row(
            children: barColors.map((c) => Expanded(child: Container(height: 6, color: c))).toList(),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SALSO vertical logo
                  Text('S', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -1)),
                  Text('A', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -1)),
                  Text('L', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -1)),
                  Text('S', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -1)),
                  Text('O', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -1)),
                  const SizedBox(height: 32),
                  // Subtitle
                  Text(
                    'Workforce Management',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 2),
                  ),
                  const SizedBox(height: 40),
                  // Loading bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 160,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: _animCtrl.value,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFFD90429),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
