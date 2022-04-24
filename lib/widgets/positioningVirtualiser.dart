import 'dart:developer' as dev;
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import "package:p5/p5.dart";

class PositioningVisualiser extends StatefulWidget {
  List<List<int>> anchors;
  List<List<int>> Function() getRots;

  PositioningVisualiser(
      {Key? key, required this.anchors, required this.getRots})
      : super(key: key);

  @override
  State<PositioningVisualiser> createState() => _PositioningVisualiserState();
}

class _PositioningVisualiserState extends State<PositioningVisualiser>
    with SingleTickerProviderStateMixin {
  late MySketch sketch;
  late PAnimator animator;

  @override
  void initState() {
    super.initState();
    sketch = MySketch(widget.getRots);
    // Need an animator to call the draw() method in the sketch continuously,
    // otherwise it will be called only when touch events are detected.
    animator = PAnimator(this);
    animator.addListener(() {
      setState(() {
        sketch.redraw();
      });
    });
    animator.run();
  }

  @override
  void dispose() {
    animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log('size of widget: ' + MediaQuery.of(context).size.toString());

    return Container(
      // clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height - 165,
      width: MediaQuery.of(context).size.width,
      child: PWidget(sketch),
    );
  }
}

class MySketch extends PPainter {
  List<List<int>> Function() getAnchors;
  MySketch(this.getAnchors);

  void setup() {
    // size(300, 300);
  }

  void draw() {
    background(color(255, 255, 255));

    strokeWeight(1);
    List<List<int>> anchors = getAnchors();

    List<List<int>> intersections = getIntersections(anchors);
    drawAnchors(anchors);
    drawPoints(intersections);
    dev.log(anchors.toString());
  }

  List<List<int>> getIntersections(List<List<int>> anchors) {
    int x1 = anchors[0][0];
    int y1 = anchors[0][1];
    int r1 = anchors[0][2];

    int x2 = anchors[1][0];
    int y2 = anchors[1][1];
    int r2 = anchors[1][2];

    int dx = x2 - x1;
    int dy = y2 - y1;

    int d = sqrt(dx * dx + dy * dy).round();

    if (d > r1 + r2) return [];

    double cd = ((r1 * r1) - (r2 * r2) + (d * d)) / (2 * d);
    double hcl = sqrt((r1 * r1) - (cd * cd));
    double cmpx = x1 + ((cd * dx) / d);
    double cmpy = y1 + ((cd * dy) / d);

    var i1 = [
      (cmpx + (hcl * dy) / d).round(),
      (cmpy - (hcl * dx) / d).round(),
    ];
    var i2 = [
      (cmpx - (hcl * dy) / d).round(),
      (cmpy + (hcl * dx) / d).round(),
    ];
    return [i1, i2];
    // return [
    //   [100, 100]
    // ];
  }

  void drawPoints(intersections) {
    strokeWeight(20);
    stroke(Colors.red);
    intersections.forEach((i) {
      fill(Colors.black);
      paintCanvas.drawCircle(
          Offset(i[0].toDouble(), i[1].toDouble()), 10, fillPaint);
    });
  }

  void drawAnchors(List<List<int>> anchors) {
    anchors.forEach((pos) {
      stroke(Colors.black);
      fill(Color.fromARGB(106, 244, 67, 54));
      paintCanvas.drawCircle(Offset(pos[0].toDouble(), pos[1].toDouble()),
          pos[2].toDouble(), strokePaint);

      paintCanvas.drawCircle(Offset(pos[0].toDouble(), pos[1].toDouble()),
          pos[2].toDouble(), fillPaint);

      fill(Colors.black);
      paintCanvas.drawCircle(
          Offset(pos[0].toDouble(), pos[1].toDouble()), 5, fillPaint);
    });
  }
}
