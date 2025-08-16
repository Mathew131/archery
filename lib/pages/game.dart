import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';

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

class KnifeHitGame extends FlameGame with HasCollisionDetection, DragCallbacks, HasGameRef<KnifeHitGame> {
  late Target _target;
  late TextComponent _scoreText;
  late TextComponent _leftText;
  late TextComponent _levelText;

  final _levels = <Level>[
    const Level(knivesToThrow: 30, pinnedStart: 0, radius: 100, angularSpeed: 1.0),
    const Level(knivesToThrow: 5, pinnedStart: 3, radius: 100, angularSpeed: 1.4),
    const Level(knivesToThrow: 5, pinnedStart: 3, radius: 100, angularSpeed: 1.8),
    const Level(knivesToThrow: 9, pinnedStart: 4, radius: 100, angularSpeed: 2.2),
    const Level(knivesToThrow: 10, pinnedStart: 4, radius: 100, angularSpeed: 2.6),
  ];

  GameState state = GameState.playing;
  int levelIndex = 0;
  int score = 0;
  int knivesLeft = 0;
  bool knifeInFlight = false;
  double level_radius = 0;
  late Archer _archer;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sl<Data>().sizeGameScreen = size.clone();

    _archer = Archer(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 1.2));
    add(_archer);

    // HUD
    _scoreText = TextComponent(
      text: '0',
      anchor: Anchor.topLeft,
      position: Vector2(16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
    _levelText = TextComponent(
      text: 'L1',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
    _leftText = TextComponent(
      text: 'Knives: 0',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 22, color: Colors.black),
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

    level_radius = level.radius;
    _updateHud();
  }

  void _updateHud() {
    _scoreText.text = '$score';
    _leftText.text = 'Knives: $knivesLeft';
    _levelText.text = 'L${(levelIndex % _levels.length) + 1}';
  }

  @override
  void onDragStart(DragStartEvent event) {
    _archer.tensionAnimation();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    // if (state != GameState.playing) {
    //   if (state == GameState.gameOver) {
    //     levelIndex = 0;
    //     score = 0;
    //   } else if (state == GameState.levelCleared) {
    //     levelIndex++;
    //   }
    //   startLevel(levelIndex);
    //   return;
    // }

    if (knifeInFlight || knivesLeft <= 0) return;
    _throwKnife();

    _archer.playShootAnimation();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _archer.setFrame(0);
  }


  // @override
  // void onTapDown(TapDownInfo info) {
  //   super.onTapDown(info);
  //
  //   _archer.tensionAnimation();
  // }
  //
  // @override
  // void onTapUp(TapUpInfo info) {
  //   print('-----------------------------------');
  //   if (state != GameState.playing) {
  //     if (state == GameState.gameOver) {
  //       levelIndex = 0;
  //       score = 0;
  //     } else if (state == GameState.levelCleared) {
  //       levelIndex++;
  //     }
  //     startLevel(levelIndex);
  //     return;
  //   }
  //
  //   if (knifeInFlight || knivesLeft <= 0) return;
  //   _throwKnife();
  //
  //   _archer.playShootAnimation();
  // }

  void nextLevel() {
    state = GameState.levelCleared;

    for (int i = 0; i < _target.pinned_knifes.length; ++i) {
      gameRef.remove(_target.pinned_knifes[i]);
    }
    _target.pinned_knifes = [];
    _target.knifes_angles = [];

    startLevel(levelIndex);
  }

  void _throwKnife() {
    knifeInFlight = true;
    knivesLeft--;
    _updateHud();

    final k = Knife(
      startPos: Vector2(size.x / 2, size.y - 80),
      speed: 1000,
      onStuck: () {
        _target.addPinned(math.pi/2);
        score++;
        knifeInFlight = false;
        _updateHud();

        if (knivesLeft == 0) {

          levelIndex++;
          nextLevel();
        }
      },
      onFail: () {
        state = GameState.gameOver;
        knifeInFlight = false;

        levelIndex = 0;
        nextLevel();
      },
      radius: level_radius,
    );
    add(k);
  }
}

class Target extends PositionComponent with CollisionCallbacks, HasGameRef<KnifeHitGame> {
  final Vector2 center;
  final double radius;
  double angularSpeed; // рад/с
  final int startPinned;

  late final CircleComponent _disc;
  late final CircleHitbox _innerHitbox;
  final _rand = math.Random();

  List<PinnedKnife> pinned_knifes = [];
  List<double> knifes_angles = [];

  final random = math.Random();

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

    final svg = await Svg.load('wood3.svg');
    final art = SvgComponent(
      svg: svg,
      size: size,
      anchor: Anchor.center,
    )..position = size / 2;
    add(art);

    // add(CircleHitbox(radius: 5)
    //   ..paint.color = const Color(0x5500FF00)
    //   ..renderShape = true
    //   ..position = Vector2(2, 4),
    // );
    _innerHitbox = CircleHitbox.relative(
      1,
      parentSize: size,
      anchor: Anchor.center,
    )..position = size / 2
      // ..paint.color = const Color(0x5500BFFF)
      // ..renderShape = true
      ..collisionType = CollisionType.passive;

    add(_innerHitbox);

    for (int i = 0; i < startPinned; i++) {
      double theta = random.nextDouble() * 2 * math.pi;
      addPinned(theta);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += angularSpeed * dt;

    // add(CircleComponent(
    //   radius: 3,
    //   paint: Paint()..color = const Color(0xFFFF0000),
    //   anchor: Anchor.center,
    //   position: Vector2(position.x + radius, position.y + radius),
    // ));

    for (int i = 0; i < pinned_knifes.length; ++i) {
      knifes_angles[i] += angularSpeed * dt;

      final Vector2 pivotWorld = position;

      final offset = Vector2(
        radius * math.cos(knifes_angles[i]),
        radius * math.sin(knifes_angles[i]),
      );

      pinned_knifes[i].angle = math.atan2(offset.y, offset.x) - math.pi/2;
      // pinned_knifes[i].angle = math.atan2(offset.y, offset.x) - math.pi/2 - math.pi/4 - math.pi/30;
      pinned_knifes[i].position = pivotWorld + offset;
    }
  }

  void addPinned(double theta) {
    pinned_knifes.add(PinnedKnife()..priority = -1); // -1 !!!!!!!!!!
    knifes_angles.add(theta);
    gameRef.add(pinned_knifes.last);
  }


  void celebrate() {

    // чуть приподнять, увеличить и покрасить в белый
    // angularSpeed *= 1.6;
    // add(OpacityEffect.to(
    //   0.8,
    //   EffectController(duration: 0.15, reverseDuration: 0.15, repeatCount: 2),
    // ));
  }

  // void fallApart() {
  //   // отпускаем все воткнутые ножи падать вниз
  //   for (final p in children.whereType<PinnedKnife>()) {
  //     p.detachAndFall(this);
  //   }
  // }
}

class Knife extends PositionComponent with CollisionCallbacks {
  final void Function() onStuck;
  final VoidCallback onFail;
  final double speed;
  bool _dead = false;
  final double radius;

  Knife({
    required Vector2 startPos,
    required this.speed,
    required this.onStuck,
    required this.onFail,
    required this.radius,
  }) : super(
    position: startPos,
    size: Vector2(13, 80), // x/y = 0.165
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svg = await Svg.load('arrow1.svg');
    final art = SvgComponent(
      svg: svg,
      size: size,
      anchor: Anchor.center,
    )..position = size / 2;
    add(art);

    add(CircleHitbox(radius: 5)
      // ..paint.color = const Color(0x5500FF00)
      // ..renderShape = true
      ..position = Vector2(2, 4)
      ..collisionType = CollisionType.active,
    );
    // add(RectangleHitbox()..collisionType = CollisionType.active
    //   ..paint.color = const Color(0x5500FF00)
    //   ..renderShape = true
    // );

    // angle = -math.pi / 4;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dead) return;
    position.y -= speed * dt;
    // position.y при остановке разный
    // print(position.y);
    // if (position.y < radius) {
    //   _dead = true;
    //   removeFromParent();
    //   onFail();
    // }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (_dead) return;

    if (other is PinnedKnife) {
      _dead = true;
      removeFromParent();
      onFail();
      print('fail -------------------------------');
      return;
    }
    if (other is Target) {
      _dead = true;

      removeFromParent();
      onStuck();
    }
  }
}


class PinnedKnife extends PositionComponent with CollisionCallbacks {
  // final double theta;
  // final double inset;

  PinnedKnife(
  // required this.theta,
  // required this.inset,
  ) : super(
    size: Vector2(13, 80),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svg = await Svg.load('arrow1.svg');
    add(SvgComponent(
      svg: svg,
      size: size,
      anchor: Anchor.center,
      position: Vector2(5, size.y - 30),
    ));

    add(CircleHitbox(radius: 10)
      // ..paint.color = const Color(0x5500FF00)
      // ..renderShape = true
      ..position = Vector2(-4, 15 + 25),
    );
    // add(RectangleHitbox()..collisionType = CollisionType.passive..paint.color = const Color(0x5500FF00)..renderShape = true);

    // add(CircleComponent(
    //   radius: 3,
    //   paint: Paint()..color = Colors.blue,
    //   anchor: Anchor.center,
    //   // position: size/2,
    // ));
  }

  // @override
  // void update(double dt) {
  //   global_angle += angularSpeed * dt;
  //
  //   final Vector2 pivotWorld = position;
  //
  //   final offset = Vector2(
  //     radius * math.cos(global_angle),
  //     radius * math.sin(global_angle),
  //   );
  //
  //   position = pivotWorld + offset;
  //   print(position);
  // }
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



class Archer extends PositionComponent with CollisionCallbacks {
  Archer({required Vector2 position}) {
    this.position = position;
    size = Vector2(130.0, 130.0);
    anchor = Anchor.center;
  }

  late List<SvgComponent> frames;
  int currentFrame = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    angle = -math.pi/4;

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
    await Future.delayed(const Duration(milliseconds: 15));
    setFrame(2);
    await Future.delayed(const Duration(milliseconds: 15));
    setFrame(1);
  }

  void playShootAnimation() async {
    setFrame(2);
    await Future.delayed(const Duration(milliseconds: 15));
    setFrame(3);
    await Future.delayed(const Duration(milliseconds: 15));
    setFrame(0);
  }
}
