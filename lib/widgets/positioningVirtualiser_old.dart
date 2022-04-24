import 'dart:developer' as Dev;
import 'dart:math';

import 'package:flutter/material.dart';

class PositioningVisualiser extends StatelessWidget {
  final Size size;
  final List<AnchorInfo> anchors;

  const PositioningVisualiser({
    Key? key,
    required this.size,
    required this.anchors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.hardEdge,
      child: CustomPaint(
        painter: CanvasPainter(anchors),
        size: size,
      ),
    );
  }
}

class AnchorInfo {
  final Offset pos;
  final Size anchorSpace;
  final double distance;
  Color rangeColor;

  /// a class to represent the data required to draw the anchor and its distance
  ///
  /// the x and y should be between the range
  AnchorInfo(
      {required this.pos,
      required this.distance,
      required this.rangeColor,
      required this.anchorSpace});

  int xToPixelCoord(int maxX) {
    // return (maxX * pos.dx).toInt();

    return ((maxX / anchorSpace.width) * pos.dx).toInt();
  }

  int yToPixelCoord(int maxY) {
    return ((maxY / anchorSpace.height) * pos.dx).toInt();
  }

  Offset xyOffsetFromLeftBottom(Size size) {
    return Offset(
      xToPixelCoord(size.width.toInt()).toDouble(),
      size.height - yToPixelCoord(size.height.toInt()),
    );
  }

  int distanceToPixels(Size canvasSize) {
    double bigA = anchorSpace.height > anchorSpace.width
        ? anchorSpace.height
        : anchorSpace.width;

    double bigC = canvasSize.height > canvasSize.width
        ? canvasSize.height
        : canvasSize.width;

    return ((bigC / bigA) * distance).toInt();
  }

  Offset toPixelOffset(Size canvasSize) {
    return Offset(
      xToPixelCoord(canvasSize.width.toInt()).toDouble(),
      yToPixelCoord(canvasSize.height.toInt()).toDouble(),
    );
  }

  double distanceFrom(AnchorInfo a2, Size canvasSize) {
    Offset a1Pos = toPixelOffset(canvasSize);
    Offset a2Pos = a2.toPixelOffset(canvasSize);

    Offset left = a1Pos.dx > a2Pos.dx ? a1Pos : a2Pos;
    Offset right = a1Pos.dx < a2Pos.dx ? a1Pos : a2Pos;

    Offset top = a1Pos.dy > a2Pos.dy ? a1Pos : a2Pos;
    Offset bottom = a1Pos.dy < a2Pos.dy ? a1Pos : a2Pos;

    double distBetweenX = (left.dx - right.dx);
    double distBetweenY = (bottom.dy - top.dy);

    return sqrt((distBetweenY * distBetweenY) + (distBetweenX * distBetweenX));
  }

  /// check if the anchors rages overlap
  bool overlapsWith(AnchorInfo a2, Size canvasSize) {
    bool overlapping = false;
    // convert them to the same anchorspace by converting
    // them to precision*precision pizels
    Offset a1Pos = toPixelOffset(canvasSize);
    Offset a2Pos = a2.toPixelOffset(canvasSize);
    int a2Dist = distanceToPixels(canvasSize);

    double distBetween = distanceFrom(a2, canvasSize);
    int totalRange = a2Dist + distanceToPixels(canvasSize);
    return distBetween < totalRange;
  }

  List<Offset> getOverlapPoints(AnchorInfo a2, Size canvasSize) {
    if (!overlapsWith(a2, canvasSize)) return [];

    // calculate the points in between current and a2 expecting the
    // same canvas size
    var X1 = xToPixelCoord(canvasSize.width.toInt());
    var Y1 = yToPixelCoord(canvasSize.width.toInt());

    var X2 = a2.xToPixelCoord(canvasSize.width.toInt());
    var Y2 = a2.yToPixelCoord(canvasSize.width.toInt());

    var r1 = distanceToPixels(canvasSize);
    var r2 = a2.distanceToPixels(canvasSize);

    var dx = X2 - X1;
    var dy = Y2 - Y1;
    var d = sqrt(dx * dx + dy + dy).toInt();

    var chordDistance = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    var halfChordLength = sqrt(r1 * r1 - chordDistance * chordDistance);

    var chordMidpointX = X1 + ((chordDistance * dx) / d);
    var chordMidpointY = Y1 + ((chordDistance * dy) / d);

    Dev.log((chordMidpointX + (halfChordLength * dy) / d).toString());
    Dev.log((chordMidpointY - (halfChordLength * dx) / d).toString());

    Dev.log((chordMidpointX - (halfChordLength * dy) / d).toString());
    Dev.log((chordMidpointY + (halfChordLength * dx) / d).toString());

    return [
      Offset(
        chordMidpointX + (halfChordLength * dy) / d,
        chordMidpointY - (halfChordLength * dx) / d,
      ),
      Offset(
        chordMidpointX - (halfChordLength * dy) / d,
        chordMidpointY + (halfChordLength * dx) / d,
      )
    ];
  }
}

class CanvasPainter extends CustomPainter {
  List<AnchorInfo> anchors;
  late Canvas canvas;
  late Size size;
  late Paint paintVar;

  CanvasPainter(this.anchors);

  @override
  void paint(Canvas canvas, Size size) {
    // setup paint vars
    this.canvas = canvas;
    this.size = size;
    paintVar = Paint();

    // paint the center of all anvhors
    anchors.forEach((a) {
      _paintRadius(a.toPixelOffset(size), a.rangeColor,
          a.distanceToPixels(size).toDouble());

      _paintPoint(
        a.toPixelOffset(size),
        Colors.red,
      );
    });
    List<Offset> overlaps = [];
    for (int i = 0; i < anchors.length - 1; i++) {
      overlaps.addAll(anchors[i].getOverlapPoints(anchors[i + 1], size));
    }
    // Dev.log(overlaps.toString());
    overlaps.forEach((element) {
      //   Offset(
      //   xToPixelCoord(size.width.toInt()).toDouble(),
      //   size.height - yToPixelCoord(size.height.toInt()),
      // );
      canvas.drawCircle(
        // Offset(0, 390),
        convertOffsetToBottomLeft(Offset(105, 305), size),
        8,
        paintVar,
      );
      // _paintPoint(Offset(470, 40), Colors.red);
    });

    // var overlaps =
  }

  void _paintPoint(
    Offset xyOffset,
    Color color,
  ) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(xyOffset, 5, paint);

    paint.style = PaintingStyle.fill;
    paint.color = color;
    canvas.drawCircle(xyOffset, 5, paint);
  }

  void _paintRadius(Offset xyOffset, Color rangeColor, double distance) {
    var paint = Paint();
    paint.color = rangeColor;
    canvas.drawCircle(xyOffset, distance, paint);

    paint.color = Colors.black;
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(xyOffset, distance, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Offset convertOffsetToBottomLeft(Offset offset, Size canvasSize) {
  return Offset(offset.dx, canvasSize.height - offset.dy);
}
