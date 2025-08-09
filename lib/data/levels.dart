import 'package:flame/components.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';

class WallSpec {
  final Vector2 pos;
  final Vector2 size;
  WallSpec(this.pos, this.size);
}

class TargetSpec {
  Vector2 position_;
  int type_;
  Vector2 velocity_;
  double circleRadius_;
  double angularSpeed_;
  double angle_;
  double period_triangle_;
  double left_;
  double right_;
  double bottom_;
  double top_;

  TargetSpec({Vector2? position, int type = 0, Vector2? velocity, double circleRadius = 0, double angularSpeed = 0, double angle = 0, double period_triangle = 0,
    double left = 0, double right = 0, double bottom = 0, double top = 0
  })  : position_ = position ?? Vector2.zero(),
        type_ = type,
        velocity_ = velocity ?? Vector2.zero(),
        circleRadius_ = circleRadius,
        angularSpeed_ = angularSpeed,
        angle_ = angle,
        period_triangle_ = period_triangle,
        left_ = left,
        right_ = right,
        bottom_ = bottom,
        top_ = top;
}

class LevelSpec {
  final List<WallSpec> walls;
  final List<TargetSpec> targets;
  LevelSpec({required this.walls, required this.targets});
}

// TargetSpec(position:, type: 0, velocity:, top:, bottom:), // по вертикали
// TargetSpec(position:, type: 1, velocity:, left:, right:), // по горизонтали
// TargetSpec(position:, type: 2, velocity:, left:, right:), // по диагонали
// TargetSpec(position:, type: 3, circleRadius:, angularSpeed:, angle:), // по окружности
// TargetSpec(position:, type: 2, velocity:, period_triangle:), // зубчато

final kLevels = <LevelSpec>[
  LevelSpec(
    walls: [
      WallSpec(Vector2(sl<Data>().sizeGameScreen.x / 2.5, sl<Data>().sizeGameScreen.y / 6.8), Vector2(70, 10)),
    ],
    targets: [
      // может как-то укоротить position
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 2), type: 1, velocity: Vector2(200, 0), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 2.5), type: 1, velocity: Vector2(-100, 0), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 5), type: 3, circleRadius: 80, angularSpeed: 1.5, angle: 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 2), type: 2, velocity: Vector2(200, 100), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 2, velocity: Vector2(-150, -100), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 6), type: 2, velocity: Vector2(100, 100), left: 0, right: sl<Data>().sizeGameScreen.x),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 1, velocity: Vector2(200, 0), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 2, velocity: Vector2(0, 100), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 120, angularSpeed: 1.5, angle: 0),
    ],
  ),

  LevelSpec(
    walls: [
      WallSpec(Vector2(0, sl<Data>().sizeGameScreen.y / 7), Vector2(110, 10)),
      WallSpec(Vector2(sl<Data>().sizeGameScreen.x - 100, sl<Data>().sizeGameScreen.y / 7), Vector2(100, 10)),
    ],
    targets: [
      TargetSpec(position: Vector2(45, sl<Data>().sizeGameScreen.y / 8), type: 1, velocity: Vector2(200, 0), left: 0, right: sl<Data>().sizeGameScreen.x/2),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2 + 45, sl<Data>().sizeGameScreen.y / 8), type: 1, velocity: Vector2(200, 0), left: sl<Data>().sizeGameScreen.x/2, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 4, velocity: Vector2(200, 200), period_triangle: 20),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.5, sl<Data>().sizeGameScreen.y / 7), type: 0, velocity: Vector2(0, 200), bottom: 0, top: (sl<Data>().sizeGameScreen.y - 250)/2),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 4), type: 4, velocity: Vector2(200, 200), period_triangle: 20),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 4, sl<Data>().sizeGameScreen.y / 2), type: 0, velocity: Vector2(0, 200), bottom: (sl<Data>().sizeGameScreen.y - 250)/2, top: sl<Data>().sizeGameScreen.y - 250 + 45),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 2.5), type: 2, velocity: Vector2(150, 150), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 2.5), type: 2, velocity: Vector2(-150, -150), left: 0, right: sl<Data>().sizeGameScreen.x),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 2.5), type: 2, velocity: Vector2(150, -150), left: 0, right: sl<Data>().sizeGameScreen.x),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 3, sl<Data>().sizeGameScreen.y / 2), type: 4, velocity: Vector2(200, 150), period_triangle: 20),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.5, sl<Data>().sizeGameScreen.y / 3), type: 4, velocity: Vector2(200, 100), period_triangle: 30),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 6), type: 4, velocity: Vector2(100, 250), period_triangle: 15),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.5, sl<Data>().sizeGameScreen.y / 4), type: 3, circleRadius: 80, angularSpeed: 1.5, angle: 0),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 70, angularSpeed: 1.7, angle: 1),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 3, sl<Data>().sizeGameScreen.y / 2), type: 3, circleRadius: 60, angularSpeed: 2, angle: 2),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2.5, sl<Data>().sizeGameScreen.y / 4), type: 3, circleRadius: 60, angularSpeed: 1.5, angle: 0),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 2, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 70, angularSpeed: 1.7, angle: 1.5),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.5, sl<Data>().sizeGameScreen.y / 2), type: 3, circleRadius: 80, angularSpeed: 2.2, angle: 0.5),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 90, angularSpeed: 3, angle: 0),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 90, angularSpeed: 3, angle: 2.1),
      TargetSpec(position: Vector2(sl<Data>().sizeGameScreen.x / 1.8, sl<Data>().sizeGameScreen.y / 3), type: 3, circleRadius: 90, angularSpeed: 3, angle: 4.2),
    ],
  ),
];

