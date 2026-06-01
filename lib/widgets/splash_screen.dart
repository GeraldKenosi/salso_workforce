import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animCtrl.forward();
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const SizedBox.shrink();

    const barColors = [
      Colors.black,
      Color(0xFFFDD835),
      Color(0xFFD90429),
      Color(0xFF0FA65A),
      Color(0xFF1E9CCC),
    ];

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: barColors.map((c) => Expanded(child: Container(height: 6, color: c))).toList(),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon.png', width: 100, height: 100),
                  const SizedBox(height: 40),
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
