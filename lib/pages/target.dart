import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'dart:math';

String calculateScore(Offset hit, Size size, double width, double whichTarget) {
  final center = size.center(Offset.zero);
  final dist = (hit - center).distance;
  if (dist <= (width/(whichTarget * 2.0)) / 2.0) return 'x';
  else if (dist <= (width/(whichTarget * 2.0))) return '10';
  else if (dist <= (width/(whichTarget * 2.0)) * 2.0) return '9';
  else if (dist <= (width/(whichTarget * 2.0)) * 3.0) return '8';
  else if (dist <= (width/(whichTarget * 2.0)) * 4.0) return '7';
  else if (dist <= (width/(whichTarget * 2.0)) * 5.0) return '6';
  else if (dist <= (width/(whichTarget * 2.0)) * 6.0 && whichTarget > 5) return '5';
  else if (dist <= (width/(whichTarget * 2.0)) * 7.0 && whichTarget > 6) return '4';
  else if (dist <= (width/(whichTarget * 2.0)) * 8.0 && whichTarget > 6) return '3';
  else if (dist <= (width/(whichTarget * 2.0)) * 9.0 && whichTarget > 6) return '2';
  else if (dist <= (width/(whichTarget * 2.0)) * 10.0 && whichTarget > 6) return '1';
  else return 'м';
}

class TargetWidget extends StatefulWidget {
  final Function(Offset) onShot;
  final String svgAsset;
  final int currentTable;
  final int curJ;
  final double width;
  final double height;
  final double sizeHits;
  final bool isView;
  final Size size;

  const TargetWidget({
    Key? key,
    required this.onShot,
    required this.svgAsset,
    required this.currentTable,
    required this.curJ,
    required this.width,
    required this.height,
    required this.sizeHits,
    required this.isView,
    required this.size,
  }) : super(key: key);

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget> {
  Offset? currentTap;
  static const double crossOffset = 60.0; // смещение крестика вверх

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          widget.svgAsset,
          width: widget.width,
          height: widget.height,
        ),
        GestureDetector(
          onPanDown: (details) {
            setState(() => currentTap = details.localPosition);
          },
          onPanUpdate: (details) {
            setState(() => currentTap = details.localPosition);
          },

          onPanEnd: (_) {
            final center = widget.size.center(Offset.zero);
            final dist = (currentTap! - Offset(0, crossOffset) - center).distance;


            if (currentTap != null && dist <= widget.width / 2.0 + 40) {
              final hitPos = currentTap! - Offset(0, crossOffset);
              setState(() {
                sl<Data>().hits[sl<Data>().current_name]![widget.currentTable][widget.curJ].add(hitPos);
              });
              widget.onShot(hitPos);
            }

            setState(() {
              currentTap = null;
            });
          },
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _HitsPainter(sl<Data>().hits[sl<Data>().current_name]![widget.currentTable][widget.curJ], currentTap, widget.sizeHits, widget.isView),
          ),
        ),
      ],
    );
  }
}

class _HitsPainter extends CustomPainter {
  final List<Offset> hits;
  final Offset? currentTap;
  final double sizeHits;
  final bool isView;

  static const double crossOffset = 60.0; // смещение крестика вверх
  static const double crossSize = 10.0;

  _HitsPainter(this.hits, this.currentTap, this.sizeHits, this.isView);

  @override
  void paint(Canvas canvas, Size size) {
    final hitPaint = Paint();
    hitPaint.color = Colors.black;

    for (final hit in hits) {
      canvas.drawCircle(hit, sizeHits, hitPaint);
    }

    if (hits.isNotEmpty) {
      final meanX = hits.map((h) => h.dx).reduce((a, b) => a + b) / hits.length;
      final meanY = hits.map((h) => h.dy).reduce((a, b) => a + b) / hits.length;
      final mean = Offset(meanX, meanY);

      final meanCrossPaint = Paint();
      meanCrossPaint.color = Colors.green;
      meanCrossPaint.strokeWidth = 3.0;
      const crossSize = 7.0;

      canvas.drawLine(
        mean.translate(-crossSize, -crossSize),
        mean.translate(crossSize, crossSize),
        meanCrossPaint,
      );
      canvas.drawLine(
        mean.translate(crossSize, -crossSize),
        mean.translate(-crossSize, crossSize),
        meanCrossPaint,
      );
    }



    if (currentTap != null && !isView) {
      final crossPaint = Paint();
      crossPaint.color = Colors.black;
      crossPaint.strokeWidth = 2.0;

      final offset = currentTap! - Offset(0, crossOffset);
      canvas.drawLine(
        offset.translate(-crossSize, 0),
        offset.translate(crossSize, 0),
        crossPaint,
      );
      canvas.drawLine(
        offset.translate(0, -crossSize),
        offset.translate(0, crossSize),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
