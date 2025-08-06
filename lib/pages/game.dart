import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Игра')),
      body: GameWidget(game: ArcheryGame()),
    );
  }
}

class AimGuide extends PositionComponent {
  Vector2 start;
  Vector2 end;
  final double maxLen;
  final double step;
  final double radius;

  AimGuide({
    required this.start,
    required this.end,
    this.maxLen = 300,
    this.step   = 20,
    this.radius = 3,
  }) {
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.black54;
    final dir = end - start;
    if (dir.length == 0) return;
    final unit = dir.normalized();

    for (double d = 10; d < maxLen; d += step) {
      final p = start + unit * d;
      canvas.drawCircle(Offset(p.x, p.y), radius, paint);
    }
  }
}



class ArcheryGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  AimGuide? _guide;

  @override
  bool onDragStart(DragStartEvent event) {
    _guide = AimGuide(
      start: _archer.position.clone(),
      end:   event.canvasPosition,
    );
    add(_guide!);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    _guide?.end = event.canvasEndPosition;
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (_guide != null) {
      add(Arrow(start: _archer.position, target: _guide!.end));
      _guide!.removeFromParent();
      _guide = null;
    }
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    _guide?.removeFromParent();
    _guide = null;
    return true;
  }


  @override
  Color backgroundColor() => Colors.white;

  late final Archer _archer;
  final _rnd = Random();
  late final Timer _appleTimer;
  int score = 0;
  int cnt_apples = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    @override
    Color backgroundColor() => Colors.white;

    final startPos = Vector2(size.x / 2 + 25, size.y - 60);
    _archer = Archer(position: startPos);
    add(_archer);

    _appleTimer = Timer(1, onTick: _spawnApple, repeat: true);
  }

  void _spawnApple() {
    if (cnt_apples <= 9) {
      final pos = Vector2(
        _rnd.nextDouble() * (size.x - 80) + 40,
        _rnd.nextDouble() * (size.y / 2) + 40,
      );
      add(Apple(position: pos));
      cnt_apples++;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _appleTimer.update(dt);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    add(Arrow(start: _archer.position, target: event.canvasPosition));
    return true;
  }

  void onAppleHit(Apple apple) {
    score++;
    apple.removeFromParent();
    cnt_apples--;
  }
}

class Archer extends PositionComponent with CollisionCallbacks {
  Archer({required Vector2 position}) {
    this.position = position;
    size = Vector2(50, 50);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final svgData = await Svg.load('bow-and-arrow.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center));
    angle = -pi / 4;
    add(RectangleHitbox());
  }
}

class Apple extends PositionComponent with CollisionCallbacks {
  Apple({required Vector2 position}) {
    this.position = position;
    size = Vector2.all(30);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final svgData = await Svg.load('apple-svgrepo-com.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center));
    add(CircleHitbox(radius: 8));
  }
}

class Arrow extends PositionComponent with HasGameRef<ArcheryGame>, CollisionCallbacks {
  final Vector2 _direction;
  static const double _speed = 300;

  Arrow({required Vector2 start, required Vector2 target})
      : _direction = (target - start).normalized() {
    position = start.clone();
    size = Vector2(160, 40);
    anchor = Anchor.centerLeft;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    angle = atan2(_direction.y, _direction.x) + pi / 4;
    final svgData = await Svg.load('arrow-archery.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center));
    add(RectangleHitbox(size: Vector2(160, 40)));
  }


  @override
  void update(double dt) {
    super.update(dt);
    position += _direction * _speed * dt;
    final gameSize = gameRef.size;
    if (position.x.abs() > gameSize.x + 50 || position.y.abs() > gameSize.y + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Apple) {
      gameRef.onAppleHit(other);
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
