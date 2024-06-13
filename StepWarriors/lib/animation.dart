import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpriteAnimationDemo(),
    );
  }
}

class SpriteAnimationDemo extends StatefulWidget {
  @override
  _SpriteAnimationDemoState createState() => _SpriteAnimationDemoState();
}

class _SpriteAnimationDemoState extends State<SpriteAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // アニメーションの速度を設定
    );
    _animation = IntTween(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sprite Animation Demo'),
      ),
      body: Center(
        child: Image.asset(
          'images/sprite_${_animation.value}.png', // 画像のパスを変更
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}