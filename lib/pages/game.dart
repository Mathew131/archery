import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:archery/data/levels.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;




import 'dart:math';

class Dist {
  final Random rng;
  Dist([int? seed]) : rng = (seed == null ? Random() : Random(seed));

  // U(a, b)
  double uniform(double a, double b) => a + (b - a) * rng.nextDouble();

  // Бернулли(p): 0/1
  int bernoulli(double p) => rng.nextDouble() < p ? 1 : 0;

  // Экспоненциальное Exp(λ)
  double exponential(double lambda) => -log(1 - rng.nextDouble()) / lambda;

  // Нормальное N(μ, σ) — Box–Muller (с кэшем)
  double? _spare;
  double normal(double mean, double std) {
    if (_spare != null) {
      final z = _spare!;
      _spare = null;
      return mean + std * z;
    }
    double u1, u2, s;
    do {
      u1 = rng.nextDouble();
      u2 = rng.nextDouble();
      s = max(u1, 1e-12); // избегаем log(0)
    } while (u1 <= 1e-12);
    final r = sqrt(-2.0 * log(s));
    final z0 = r * cos(2 * pi * u2);
    final z1 = r * sin(2 * pi * u2);
    _spare = z1;
    return mean + std * z0;
  }

  // Пуассон Poisson(λ) — метод Кнута (подходит для λ ≲ 10–15)
  int poisson(double lambda) {
    final L = exp(-lambda);
    int k = 0;
    double p = 1.0;
    do {
      k++;
      p *= rng.nextDouble();
    } while (p > L);
    return k - 1;
  }

  // Категориальное распределение по весам
  int categorical(List<double> weights) {
    final sum = weights.reduce((a, b) => a + b);
    final r = rng.nextDouble() * sum;
    double acc = 0;
    for (int i = 0; i < weights.length; i++) {
      acc += weights[i];
      if (r <= acc) return i;
    }
    return weights.length - 1; // на всякий случай
  }

  // Треугольное Tri(a, c, b)
  double triangular(double a, double c, double b) {
    final u = rng.nextDouble();
    final f = (c - a) / (b - a);
    if (u < f) return a + sqrt(u * (b - a) * (c - a));
    return b - sqrt((1 - u) * (b - a) * (b - c));
  }
}





final game = ArcheryGame();

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

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
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            left: 30,
            bottom: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: game.cnt_arrows,
              builder: (_, cnt_arrows, __) {
                return flutter_svg.SvgPicture.asset(
                  'assets/quiver_${cnt_arrows >= 5 ? 5 : cnt_arrows}_arrows.svg',
                  width: 65,
                  height: 65,
                );
              },
            ),
          ),
          Positioned(
            left: 61,
            bottom: 85,
            child: ValueListenableBuilder<int>(
              valueListenable: game.cnt_arrows,
              builder: (_, cnt_arrows, __) {
                const style = TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                );
                final text = '$cnt_arrows';

                final tp = TextPainter(
                  text: TextSpan(text: text, style: style),
                  textDirection: TextDirection.ltr,
                )..layout();

                return Transform.translate(
                  offset: Offset(-tp.width / 2, 0),
                  child: Text(text, style: style),
                );
              },
            ),
          ),
        ],
      )
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

    if (_speed_x.abs() < 1e-6) {
      _speed_x = 1e-6;
      // чтобы не было деления на ноль
    }

    for (int i = 0; i < cntDot; ++i) {
      canvas.drawCircle(Offset(p.x, p.y), radius, paint);
      p.x += unit.x * step;
      p.y = start.y - (_speed_y/_speed_x) * (p.x - start.x) + (450/(2 * pow(_speed_x, 2))) * pow(p.x - start.x, 2);
    }
  }
}

class ArcheryGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  AimGuide? _guide;
  late Archer _archer;
  int score = 0;
  int cnt_targets = 0;
  final ValueNotifier<int> cnt_arrows = ValueNotifier<int>(20);
  late final TextComponent _scoreText;

  @override
  Color backgroundColor() => Colors.white;


  int _currentLevel = 0;

  void loadLevel(int i) {
    _currentLevel = i;

    for (final w in children.whereType<Wall>().toList()) {
      w.removeFromParent();
    }
    for (final t in children.whereType<Target>().toList()) {
      t.removeFromParent();
    }

    for (final a in children.whereType<Arrow>().toList()) {
      a.removeFromParent();
    }

    final lvl = kLevels[i];

    for (final w in lvl.walls) {
      add(Wall(position: w.pos, size: w.size, type: w.type, angle: w.angle));
    }

    for (final t in lvl.targets) {
      add(Target(t.position_, t.type_, t.velocity_, t.circleRadius_, t.angularSpeed_, t.angle_, t.period_triangle_, t.left_, t.right_, t.bottom_, t.top_));
      cnt_targets++;
    }
  }

  void nextLevel() {
    loadLevel((_currentLevel + 1) % kLevels.length);
  }


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sl<Data>().sizeGameScreen = size.clone();

    _archer = Archer(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 1.35));
    add(_archer);


    _scoreText = TextComponent(
      text: '0',
      anchor: Anchor.center,
      position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 3),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.black26),
      ),
    );

    camera.viewport.add(_scoreText);

    loadLevel(0);

    // final _imageComponent = SpriteComponent()
    //   ..sprite = await Sprite.load('grass.png')
    //   ..size = Vector2(sl<Data>().sizeGameScreen.x, sl<Data>().sizeGameScreen.x * 0.045)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(
    //     sl<Data>().sizeGameScreen.x/2,
    //     sl<Data>().sizeGameScreen.y - 12,
    //   );
    //
    // add(_imageComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void onTargetHit(Target Target) {
    score++;
    _scoreText.text = '$score';

    Target.removeFromParent();
    cnt_targets--;
    cnt_arrows.value++;
    if (cnt_targets == 0) {
      nextLevel();
    }
  }

  // управление guide

  @override
  bool onDragStart(DragStartEvent event) {
    Vector2 real_touch = event.canvasPosition;
    Vector2 dir = real_touch - _archer.position;
    dir.x *= -1;
    dir.y *= -1;
    Vector2 img_touch = _archer.position + dir;

    if (cnt_arrows.value < 1) return true;

    _guide = AimGuide(
      start: _archer.position.clone(),
      end: img_touch.clone(),
    );

    add(_guide!);

    _archer.tensionAnimation();
    // nextLevel();
    // print('${_currentLevel}');
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    Vector2 real_touch = event.canvasEndPosition;
    Vector2 dir = real_touch - _archer.position;
    dir.x *= -1;
    dir.y *= -1;

    print('[${real_touch.x / sl<Data>().sizeGameScreen.x}, ${real_touch.y / sl<Data>().sizeGameScreen.y}]');

    _archer.angle = atan2(dir.y, dir.x) + pi/4;
    Vector2 img_touch = _archer.position + dir;

    if (cnt_arrows.value < 1) return true;

    _guide?.end = img_touch.clone();

    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (_guide != null && cnt_arrows.value >= 1) {
      _archer.playShootAnimation();
      add(Arrow(start: _archer.position, target: _guide!.end));
      cnt_arrows.value--;

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

// class Wall extends RectangleComponent with CollisionCallbacks {
//   Wall({
//     required Vector2 position,
//     required Vector2 size,
//     Color color = const Color(0xFFed6709),
//   }) : super(
//     position: position,
//     size: size,
//     paint: Paint()..color = color,
//     anchor: Anchor.topLeft,
//   ) {
//     add(RectangleHitbox());
//   }
// }

// class Wall extends RectangleComponent with CollisionCallbacks {
//   Wall({
//     required Vector2 position,
//     required Vector2 size,
//   }) : super(
//     position: position,
//     size: size,
//     paint: Paint()..color = const Color(0x00000000), // прозрачная заливка
//     anchor: Anchor.topLeft,
//   ) {
//     add(RectangleHitbox());
//   }
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     final sprite = await Sprite.load('wood.png');
//
//     add(
//       SpriteComponent(
//         sprite: sprite,
//         size: size,                 // растянуть под стену
//         anchor: Anchor.topLeft,
//         position: Vector2.zero(),   // т.к. якорь topLeft у родителя
//         priority: 1,                // выше родителя
//       ),
//     );
//   }
// }

class Wall extends SpriteComponent with CollisionCallbacks {
  String type = 'right';
  Wall({
    required Vector2 position,
    required Vector2 size,
    required String type,
    required double angle,
  }) : type = type, super(
    position: position,
    size: size,
    anchor: Anchor.topLeft,
  ) {
    this.angle = angle;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('wood_${type}.png'); // width / height = 2.5
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
  Vector2 velocity;
  int type;
  double angle; // текущий угол в радианах
  double circleRadius; // радиус окружности
  late Vector2 circleCenter; // центр вращения
  double angularSpeed; // радиан/сек, угловая скорость
  double period_triangle;
  double t = 0;
  double left;
  double right;
  double top;
  double bottom;
  Vector2? start_position;


  Target(Vector2 position, this.type, this.velocity, this.circleRadius, this.angularSpeed, this.angle, this.period_triangle,
      this.left, this.right, this.bottom, this.top) {

    this.position = position;
    start_position = position.clone();
    circleCenter = position.clone();

    size = Vector2.all(45);
    anchor = Anchor.center;
  }

  // late SvgComponent _alive;
  // SpriteComponent? _popped;
  // CircleHitbox? _hitbox;
  // bool _isHit = false;
  //
  // @override
  // Future<void> onLoad() async {
  //   await super.onLoad();
  //
  //   _alive = SvgComponent(
  //     svg: await Svg.load('balloon.svg'),
  //     size: size,
  //     anchor: Anchor.center,
  //     position: size / 2,          // <<< важно
  //   );
  //   add(_alive);
  //
  //   _popped = SpriteComponent(
  //     sprite: await Sprite.load('boom.png'),
  //     size: size,
  //     anchor: Anchor.center,
  //     position: size / 2,          // <<< важно
  //   )..priority = 1;               // чтобы точно было поверх
  //
  //   _hitbox = CircleHitbox(radius: 16)..position = Vector2(-16, -22);
  //   add(_hitbox!);
  // }
  //
  // void onHit() {
  //   if (_isHit) return;
  //   _isHit = true;
  //
  //   add(_popped!);                                // показать PNG
  //   _alive.removeFromParent();                    // убрать SVG (удалится в конце тика)
  //   _hitbox?.collisionType = CollisionType.inactive;
  //   // при желании: velocity = Vector2.zero(); angularSpeed = 0;
  // }


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('duck_hunt_assets_1.png');
    add(
      SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      ),
    );
    // final svgData = await Svg.load('balloon.svg');
    // add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center));
    add(CircleHitbox(radius: 16)
    // ..paint.color = const Color(0x5500FF00)
    // ..renderShape = true
      ..position = Vector2(-16, -22),
    );

    rx = d.normal(0, 1);
    ry = d.normal(0, 1);


  }

  // int ind = 0;
  bool flag = true;

  final rng = Random();
  final d = Dist();

  int cur_takt = 0;
  int max_takt = 20;
  var rx;
  var ry;

  @override
  void update(double dt) async {
    super.update(dt);

    cur_takt++;
    if (cur_takt == max_takt) {
      rx = d.normal(0, 1);
      ry = d.normal(1, 0.5);
      cur_takt = 0;
    }

    // final sgn = rng.nextBool() ? 1 : -1;
    // final c = d.normal(0, 5);
    // print(c);

    position.x += velocity.x * dt * rx;
    position.y += velocity.y * dt * ry;

    if (position.x < 45 || position.x > sl<Data>().sizeGameScreen.x) {
      position = start_position!;
    }

    if (position.y < 45 || position.y > sl<Data>().sizeGameScreen.y) {
      position = start_position!;
    }
    // final jsonString = await rootBundle.loadString('assets/trajectories.json');
    // final data = jsonDecode(jsonString);;
    //
    // List<double> point = (data["1"]["1"]["points"][ind] as List).map((e) => (e as num).toDouble()).toList();
    //
    // position.x = point[0] * sl<Data>().sizeGameScreen.x;
    // position.y = point[1] * sl<Data>().sizeGameScreen.y;
    // ind++;
    // if (ind >= data["1"]["1"]["points"].length) ind = 0;
    // print('$ind $point');
    //
    // print(position);

    // print('x=${point[0]}, y=${point[1]}');
    // for (var p in points) {
    //   print('x=${p[0]}, y=${p[1]}');
    // }
    // if (type == 0) {
    //   position.y += velocity.y * dt;
    //
    //   if (position.y < bottom + 45 || position.y > top) {
    //     velocity.y = -velocity.y;
    //   }
    // } else if (type == 1) {
    //   position.x += velocity.x * dt;
    //   if (position.x < left + 45 || position.x > right) {
    //     velocity.x = -velocity.x;
    //   }
    //   // print('position.x: ${position.x}, velocity.x: ${velocity.x}');
    // } else if (type == 2) {
    //   position.x += velocity.x * dt;
    //   position.y += velocity.y * dt;
    //
    //   if (position.y < 45 || position.y > sl<Data>().sizeGameScreen.y - 250) {
    //     velocity.x = -velocity.x;
    //     velocity.y = -velocity.y;
    //   }
    //
    //   if (position.x < left + 45 || position.x > right) {
    //     velocity.x = -velocity.x;
    //     velocity.y = -velocity.y;
    //   }
    //   // if (position.x < 45 || position.x > sl<Data>().sizeGameScreen.x) {
    //   //   velocity.x = -velocity.x;
    //   //   velocity.y = -velocity.y;
    //   // }
    // } else if (type == 3) {
    //   angle += angularSpeed * dt;
    //
    //   position = Vector2(
    //     circleCenter.x + circleRadius * cos(angle),
    //     circleCenter.y + circleRadius * sin(angle),
    //   );
    // } else if (type == 4) {
    //   position.x += velocity.x * dt;
    //   position.y += velocity.y * dt;
    //
    //   t++;
    //   if (t == period_triangle) {
    //     velocity.y = -velocity.y;
    //     t = 0;
    //   }
    //
    //   // вверх не вылезаем
    //
    //   if (position.x > sl<Data>().sizeGameScreen.x) {
    //     position.x -= sl<Data>().sizeGameScreen.x - 45;
    //   }
    //   if (position.x < 45) {
    //     position.x += sl<Data>().sizeGameScreen.x - 45;
    //   }
    // }
  }
}

class Arrow extends PositionComponent with HasGameReference<ArcheryGame>, CollisionCallbacks {
  Vector2 _direction;

  Arrow({required Vector2 start, required Vector2 target})
      : _direction = target - start {
    position = start.clone();

    size = Vector2(45, 45);
    anchor = Anchor.center;
    _speed_x = min(_direction.x * 5, 650);
    _speed_y = min(-_direction.y * 5, 650);
  }


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svgData = await Svg.load('arrow0.svg');
    add(SvgComponent(svg: svgData, size: size, anchor: Anchor.center, position: size / 2,));
    add(CircleHitbox(radius: 5)
    // ..paint.color = const Color(0x550000FF)
    // ..renderShape = true
      ..position = Vector2(31, 4),
    );
  }

  late double _speed_x;
  late double _speed_y;

  @override
  void update(double dt) {
    super.update(dt);
    _speed_y -= dt * 450;

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
      // other.onHit();
      game.onTargetHit(other);
      // removeFromParent();
    } else if (other is Wall) {
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
