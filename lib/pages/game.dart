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
  int cntDot;
  double step;
  double radius;

  AimGuide({
    required this.start,
    required this.end,
    this.cntDot = 15,
    this.step = 20,
    this.radius = 3,
  }) {
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.black54;
    final dir = end - start;

    double _speed_x = dir.x * 3.5;
    double _speed_y = -dir.y * 3.5;

    if (dir.length == 0) return;
    Vector2 p = start.clone();
    final unit = dir.normalized();

    for (int i = 0; i < cntDot; ++i) {
      canvas.drawCircle(Offset(p.x, p.y), radius, paint);
      p.x += unit.x * step;
      p.y = start.y - (_speed_y/_speed_x) * (p.x - start.x) + (400/(2 * pow(_speed_x, 2))) * pow(p.x - start.x, 2);
    }
  }
}

class ArcheryGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  AimGuide? _guide;
  late Archer _archer;
  Random _rnd = Random();
  late Timer _targetTimer;
  int score = 0;
  int cnt_targets = 0;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _archer = Archer(position: Vector2(200, 500));
    add(_archer);

    _targetTimer = Timer(1, onTick: _spawnTarget, repeat: true);

    add(Wall(position: Vector2(100, 300), size: Vector2(100, 10)));
  }

  void _spawnTarget() {
    if (cnt_targets <= 9) {
      final pos = Vector2(
        _rnd.nextDouble() * (size.x - 80) + 40,
        _rnd.nextDouble() * (size.y / 2) + 40,
      );
      add(Target(position: pos));
      cnt_targets++;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _targetTimer.update(dt);
  }

  void onTargetHit(Target Target) {
    score++;
    Target.removeFromParent();
    cnt_targets--;
  }

  // управление guide

  @override
  bool onDragStart(DragStartEvent event) {
    Vector2 real_touch = event.canvasPosition;
    Vector2 dir = real_touch - _archer.position;
    dir.x *= -1;
    dir.y *= -1;
    Vector2 img_touch = _archer.position + dir;

    _guide = AimGuide(
      start: _archer.position.clone(),
      end: img_touch.clone(),
    );

    add(_guide!);

    _archer.tensionAnimation();
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    Vector2 real_touch = event.canvasEndPosition;
    Vector2 dir = real_touch - _archer.position;
    dir.x *= -1;
    dir.y *= -1;
    _archer.angle = atan2(dir.y, dir.x) + pi/4;
    Vector2 img_touch = _archer.position + dir;

    _guide?.end = img_touch.clone();
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (_guide != null) {
      _archer.playShootAnimation();
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
}

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.grey,
  }) : super(
    position: position,
    size: size,
    paint: Paint()..color = color,
    anchor: Anchor.topLeft,
  ) {
    add(RectangleHitbox());
  }
}

class Archer extends PositionComponent with CollisionCallbacks {


  Archer({required Vector2 position}) {
    this.position = position;
    size = Vector2(80.0, 80.0);
    anchor = Anchor.center;
  }


  late List<SvgComponent> frames;
  int currentFrame = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final framePaths = [
      'bow_0.svg',
      'bow_1.svg',
      'bow_2.svg',
      'bow_3.svg',
    ];

    frames = [];

    for (final path in framePaths) {
      final svg = await Svg.load(path);
      final component = SvgComponent(svg: svg, size: size)
        ..anchor = Anchor.center
        ..position = size / 2
        ..opacity = 0.0;

      frames.add(component);
      add(component);
    }

    frames[0].opacity = 1.0;
  }

  void setFrame(int index) {
    if (index < 0 || index >= frames.length) return;
    frames[currentFrame].opacity = 0.0;
    currentFrame = index;
    frames[currentFrame].opacity = 1.0;
  }

  void tensionAnimation() async {
    setFrame(3);
    await Future.delayed(const Duration(milliseconds: 50));
    setFrame(2);
    await Future.delayed(const Duration(milliseconds: 50));
    setFrame(1);
  }

  void playShootAnimation() async {
    setFrame(2);
    await Future.delayed(const Duration(milliseconds: 50));
    setFrame(3);
    await Future.delayed(const Duration(milliseconds: 50));
    setFrame(0);
  }
}

class Target extends PositionComponent with CollisionCallbacks {

  Target({required Vector2 position}) {
    this.position = position;
    size = Vector2.all(45);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final svgData = await Svg.load('balloon.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center));
    add(CircleHitbox(radius: 8));
  }
}

class Arrow extends PositionComponent with HasGameReference<ArcheryGame>, CollisionCallbacks {
  Vector2 _direction;

  Arrow({required Vector2 start, required Vector2 target})
      : _direction = target - start {
    position = start.clone();

    size = Vector2(45, 45);
    anchor = Anchor.center;
    _speed_x = _direction.x * 3.5;
    _speed_y = -_direction.y * 3.5;
  }


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svgData = await Svg.load('arrow0.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center, position: size / 2,));
    add(CircleHitbox(radius: 15));
  }

  late double _speed_x;
  late double _speed_y;

  @override
  void update(double dt) {
    super.update(dt);
    _speed_y -= dt * 400;

    angle = -atan2(_speed_y, _speed_x) + pi / 4;

    position.x += _speed_x * dt;
    position.y -= _speed_y * dt;

    final w = game.size.x, h = game.size.y;


    if (position.x < 0 || position.x > w - 0) {
      removeFromParent();
    }

    if (position.y < 0 || position.y > h - 0) {
      removeFromParent();
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Target) {
      game.onTargetHit(other);
      // removeFromParent();
    } else if (other is Wall) {
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
