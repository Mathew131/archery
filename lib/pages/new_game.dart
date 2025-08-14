import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import 'package:flame_svg/flame_svg.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: AppBar(
            title: Text('Игра'),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
          ),
        ),
      ),
      body: GameWidget(game: KnifeHitGame()),
    );
  }
}

class Level {
  final int knivesToThrow;
  final int pinnedStart;
  final double radius;
  final double angularSpeed; // рад/с
  const Level({
    required this.knivesToThrow,
    required this.pinnedStart,
    required this.radius,
    required this.angularSpeed,
  });
}

enum GameState { playing, gameOver, levelCleared }

class KnifeHitGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Target _target;
  late TextComponent _scoreText;
  late TextComponent _leftText;
  late TextComponent _levelText;

  final _levels = <Level>[
    const Level(knivesToThrow: 6, pinnedStart: 0, radius: 120, angularSpeed: 1.0),
    const Level(knivesToThrow: 7, pinnedStart: 3, radius: 115, angularSpeed: 1.4),
    const Level(knivesToThrow: 8, pinnedStart: 3, radius: 110, angularSpeed: 1.8),
    const Level(knivesToThrow: 9, pinnedStart: 4, radius: 105, angularSpeed: 2.2),
    const Level(knivesToThrow: 10, pinnedStart: 4, radius: 100, angularSpeed: 2.6),
  ];

  GameState state = GameState.playing;
  int levelIndex = 0;
  int score = 0;
  int knivesLeft = 0;
  bool knifeInFlight = false;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // HUD
    _scoreText = TextComponent(
      text: '0',
      anchor: Anchor.topLeft,
      position: Vector2(16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 26, color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
    _levelText = TextComponent(
      text: 'L1',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 26, color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
    _leftText = TextComponent(
      text: 'Knives: 0',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 22, color: Colors.white60),
      ),
    );
    addAll([_scoreText, _levelText, _leftText]);

    startLevel(levelIndex);
  }

  void startLevel(int i) {
    state = GameState.playing;
    children.whereType<Knife>().forEach(remove);
    children.whereType<Target>().forEach(remove);

    final level = _levels[i % _levels.length];
    knivesLeft = level.knivesToThrow;
    knifeInFlight = false;

    _target = Target(
      center: Vector2(size.x / 2, size.y * 0.38),
      radius: level.radius,
      angularSpeed: level.angularSpeed,
      startPinned: level.pinnedStart,
    );
    add(_target);

    _updateHud();
  }

  void _updateHud() {
    _scoreText.text = '$score';
    _leftText.text = 'Knives: $knivesLeft';
    _levelText.text = 'L${(levelIndex % _levels.length) + 1}';
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (state != GameState.playing) {
      // быстрый рестарт/след.уровень тапом
      if (state == GameState.gameOver) {
        levelIndex = 0;
        score = 0;
      } else if (state == GameState.levelCleared) {
        levelIndex++;
      }
      startLevel(levelIndex);
      return;
    }

    if (knifeInFlight || knivesLeft <= 0) return;
    _throwKnife();
  }

  void _throwKnife() {
    knifeInFlight = true;
    knivesLeft--;
    _updateHud();

    final k = Knife(
      startPos: Vector2(size.x / 2, size.y - 80),
      speed: 300,
      onStuck: (theta) {
        // успешное попадание
        _target.addPinned(theta);
        score++;
        knifeInFlight = false;
        _updateHud();

        final remaining = knivesLeft;
        if (remaining == 0) {
          state = GameState.levelCleared;
          // лёгкая «анимация победы»: ускорим цель и дадим всплеск частиц
          _target.celebrate();
        }
      },
      onFail: () {
        state = GameState.gameOver;
        knifeInFlight = false;
        // простая «анимация проигрыша»: отпустим все ножи вниз
        // _target.fallApart();
      },
      targetRef: _target,
    );
    add(k);
  }
}

/// Крутящаяся цель (бревно) + зона попадания и уже воткнутые ножи.
class Target extends PositionComponent with CollisionCallbacks, HasGameRef<KnifeHitGame> {
  final Vector2 center;
  final double radius;
  double angularSpeed; // рад/с
  final int startPinned;

  late final CircleComponent _disc;
  late final CircleHitbox _innerHitbox; // внутренняя зона — чтоб нож втыкался
  final _rand = math.Random();

  Target({
    required this.center,
    required this.radius,
    required this.angularSpeed,
    required this.startPinned,
  }) {
    anchor = Anchor.center;
    position = center;
    size = Vector2.all(radius * 2);
  }

  late CircleComponent debugDot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // картинка бревна
    final svg = await Svg.load('wood3.svg');
    final art = SvgComponent(
      svg: svg,
      size: size,                 // размер = 2*radius, уже задан в конструкторе
      anchor: Anchor.center,
    )..position = size / 2;       // центр внутри Target
    add(art);

    // хитбокс, чтобы нож «втыкался»
    _innerHitbox = CircleHitbox.relative(
      0.82,
      parentSize: size,
    )..collisionType = CollisionType.passive;
    add(_innerHitbox);

    // стартовые воткнутые ножи
    for (int i = 0; i < startPinned; i++) {
      // final theta = _rand.nextDouble() * 2 * math.pi;
      // final theta = 0.0;
      addPinned(math.pi/2); // передается угол поворота, сейчас забьем на него
    }

    // debugDot = CircleComponent(
    //   radius: 3,
    //   paint: Paint()..color = Colors.green,
    //   anchor: Anchor.center,
    //   position: Vector2(2*radius, 2 * radius),
    // );
    //
    // gameRef.add(debugDot);
  }


  // double orbitAngle  = 0;

  double knife_angle = math.pi/2;

  @override
  void update(double dt) {
    super.update(dt);
    // angle = math.pi/2;
    // print(angle);
    angle += angularSpeed * dt; // вращение

    if (knife != null) {
      knife_angle += angularSpeed * dt;
    }

    add(CircleComponent(
      radius: 3, // маленький кружок
      paint: Paint()..color = const Color(0xFFFF0000), // красный
      anchor: Anchor.center, // центр маленького кружка будет в точке position
      position: Vector2(0, 0), // центр локальных координат компонента
    ));

    // double alpha = math.pi/4 + math.pi/2 + angle;
    //
    // double R = radius * math.sqrt(2);
    // double a = math.sqrt(math.pow(R, 2) + math.pow(radius, 2) - 2 * R * radius * math.cos(alpha));
    // double sin_betta = R * math.sin(alpha) / a;
    // double betta = math.asin(sin_betta);
    // Vector2 pos = Vector2(math.cos(math.pi/2 - betta) * a, math.sin(math.pi/2 - betta) * a);
    // print(pos);

    // debugDot.position = pos;
    // add(CircleComponent(
    //   radius: 3,
    //   paint: Paint()..color = Colors.blue,
    //   anchor: Anchor.center, // центр маленького кружка будет в точке position
    //   // position: Vector2(50, 50),
    //   position: pos, // центр локальных координат компонента
    // ));



    if (knife != null) {
      // orbitAngle += angularSpeed * dt;

      // центр орбиты — центр Target в мире
      final Vector2 pivotWorld = position;

      final offset = Vector2(
        radius * math.cos(knife_angle),
        radius * math.sin(knife_angle),
      );
      // print(angle);
      // knife!.angle = angle - math.pi/2; // угол поворота, пока забьем
      knife!.position = pivotWorld + offset;
    }

    // print(angle);
    // иногда случайно меняем направление, чтобы не скучно
    // if (_rand.nextDouble() < 0.002) {
    //   angularSpeed = -angularSpeed;
    // }
  }

  late PinnedKnife? knife = null;

  void addPinned(double theta) {
    knife = PinnedKnife(theta: theta, inset: 20);
    // add(knife);
    // knife!.position = Vector2(0, 0);
    gameRef.add(knife!);
    // knife.position = _localFromTheta(knife.theta, radius);

    // knife.angle = knife.theta;
  }

  Vector2 _localFromTheta(double theta, double dist) {
    final centerLocal = Vector2(radius, radius);
    final dir = Vector2(math.cos(theta), math.sin(theta));
    return centerLocal + dir * dist;
  }

  void celebrate() {
    // чуть ускорим на секундочку
    angularSpeed *= 1.6;
    add(OpacityEffect.to(
      0.8,
      EffectController(duration: 0.15, reverseDuration: 0.15, repeatCount: 2),
    ));
  }

  // void fallApart() {
  //   // отпускаем все воткнутые ножи падать вниз
  //   for (final p in children.whereType<PinnedKnife>()) {
  //     p.detachAndFall(this);
  //   }
  // }
}

class Knife extends PositionComponent with CollisionCallbacks {
  final void Function(double theta) onStuck;
  final VoidCallback onFail;
  final Target targetRef;
  final double speed;
  bool _dead = false;

  Knife({
    required Vector2 startPos,
    required this.speed,
    required this.onStuck,
    required this.onFail,
    required this.targetRef,
  }) : super(
    position: startPos,
    size: Vector2(80, 80),           // подгони под свой svg
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Визуал ножа
    final svg = await Svg.load('arrow0.svg');
    final art = SvgComponent(
      svg: svg,
      size: size,
      anchor: Anchor.center,
    )..position = size / 2;
    add(art);

    // Хитбокс (активный)
    add(RectangleHitbox()..collisionType = CollisionType.active);

    angle = -math.pi / 4; // «смотрит» вверх
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dead) return;
    position.y -= speed * dt;
    if (position.y + size.y < 0) {
      _dead = true;
      removeFromParent();
      onFail();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (_dead) return;

    if (other is PinnedKnife) {
      _dead = true;
      removeFromParent();
      onFail();
      return;
    }
    if (other is Target || other == targetRef) {
      _dead = true;
      final dx = position.x - targetRef.position.x;
      final dy = position.y - targetRef.position.y;
      // print('$dx $dy');
      final theta = math.atan2(dy, dx);
      removeFromParent();
      onStuck(targetRef.angle);
    }
  }
}


class PinnedKnife extends PositionComponent with CollisionCallbacks {
  final double theta;
  final double inset;

  PinnedKnife({
    required this.theta,
    required this.inset,
  }) : super(
    size: Vector2(80, 80),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svg = await Svg.load('arrow0.svg');
    add(SvgComponent(
      svg: svg,
      size: size,
      anchor: Anchor.center,
    ));
      // ..position = Vector2(-70, 160));
    // angle = 0;
    // angle = -math.pi + math.pi/4 + math.pi/2 + theta;
    // пассивный хитбокс, чтобы ловить столкновения с летящим ножом
    add(RectangleHitbox()..collisionType = CollisionType.passive);

    add(CircleComponent(
      radius: 3, // маленький кружок
      paint: Paint()..color = Colors.blue, // красный
      anchor: Anchor.center,
      position: size / 2, // центр локальных координат компонента
    ));
  }

  // void detachAndFall(Target parentTarget) {
  //   final worldPos = absolutePosition;
  //   final worldAngle = absoluteAngle;
  //   parent?.remove(this);
  //
  //   final free = PositionComponent(
  //     position: worldPos,
  //     size: size.clone(),
  //     anchor: Anchor.center,
  //     angle: worldAngle,
  //   );
  //
  //   // визуал упавшего ножа
  //   free.add(SvgComponent(
  //     svg: (children.firstWhere((c) => c is SvgComponent) as SvgComponent).svg,
  //     size: size.clone(),
  //     anchor: Anchor.center,
  //   )..position = size / 2);
  //
  //   // простая «физика» падения
  //   final gravity = 1200.0;
  //   double vy = 0;
  //   free.add(TimerComponent(
  //     period: 1 / 60,
  //     repeat: true,
  //     onTick: () {
  //       vy += gravity * (1 / 60);
  //       free.position.y += vy * (1 / 60);
  //       free.angle += 2.5 * (1 / 60);
  //       if (free.position.y > parentTarget.gameRef.size.y + 200) {
  //         free.removeFromParent();
  //       }
  //     },
  //   ));
  //
  //   parentTarget.gameRef.add(free);
  // }
}

