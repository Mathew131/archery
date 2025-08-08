import 'package:flame/components.dart';

class WallSpec {
  final Vector2 pos;
  final Vector2 size;
  WallSpec(this.pos, this.size);
}

class TargetSpec {
  final Vector2 pos;
  final int type;
  final Vector2 velocity;
  double circleRadius_;
  double angularSpeed_;
  TargetSpec(this.pos, this.type, this.velocity, this.circleRadius_, this.angularSpeed_);
}

class LevelSpec {
  final List<WallSpec> walls;
  final List<TargetSpec> targets;
  LevelSpec({required this.walls, required this.targets});
}

// WallSpec(Vector2(280, 240), Vector2(10, 70)),

final kLevels = <LevelSpec>[
  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(160, 280), 1, Vector2(180,   0), 0, 0),
      TargetSpec(Vector2(280, 200), 0, Vector2(  0, 220), 0, 0),
      TargetSpec(Vector2(220, 180), 3, Vector2.zero(),    40, 2.0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(120, 260), 2, Vector2(120, 120), 0, 0),
      TargetSpec(Vector2(300, 180), 1, Vector2(-200,  0), 0, 0),
      TargetSpec(Vector2(240, 120), 3, Vector2.zero(),     30, 2.8),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(260, 140), 0, Vector2(0, 250), 0, 0),
      TargetSpec(Vector2(200, 220), 1, Vector2(220,  0), 0, 0),
      TargetSpec(Vector2(320, 260), 2, Vector2(-140, 90), 0, 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(170, 190), 3, Vector2.zero(),     55, 1.6),
      TargetSpec(Vector2(300, 260), 0, Vector2(0, 180),    0, 0),
      TargetSpec(Vector2(240, 320), 1, Vector2(200, 0),    0, 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(140, 300), 1, Vector2(260, 0),  0, 0),
      TargetSpec(Vector2(260, 220), 2, Vector2(110, 80), 0, 0),
      TargetSpec(Vector2(310, 150), 3, Vector2.zero(),    35, 3.0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(230, 180), 0, Vector2(0, 200),   0, 0),
      TargetSpec(Vector2(280, 280), 1, Vector2(-240, 0),  0, 0),
      TargetSpec(Vector2(200, 240), 3, Vector2.zero(),     70, 1.3),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(320, 120), 0, Vector2(0, 230),   0, 0),
      TargetSpec(Vector2(140, 260), 2, Vector2(130, 90),  0, 0),
      TargetSpec(Vector2(260, 200), 1, Vector2(220, 0),   0, 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(180, 150), 3, Vector2.zero(),     45, 2.2),
      TargetSpec(Vector2(300, 220), 2, Vector2(-120, 80),  0, 0),
      TargetSpec(Vector2(230, 300), 1, Vector2(200, 0),    0, 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(150, 320), 0, Vector2(0, 180),    0, 0),
      TargetSpec(Vector2(280, 180), 3, Vector2.zero(),      60, 1.8),
      TargetSpec(Vector2(220, 240), 2, Vector2(140, -90),   0, 0),
    ],
  ),

  LevelSpec(
    walls: [],
    targets: [
      TargetSpec(Vector2(200, 200), 3, Vector2.zero(),      80, 1.2),
      TargetSpec(Vector2(310, 260), 1, Vector2(-220, 0),    0, 0),
      TargetSpec(Vector2(140, 220), 0, Vector2(0, 210),     0, 0),
    ],
  ),
];

