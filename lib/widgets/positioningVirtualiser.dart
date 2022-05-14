import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:p5/p5.dart';

typedef Line = List<List<num>>;
typedef Point = List<num>;

class PositioningVisualiser extends StatefulWidget {
  List<Point> Function() getRots;
  void Function(num angle) setAngle;

  List<Point> anchors;
  List<Point> route;

  num maxOffline;

  PositioningVisualiser(
      {Key? key,
      required this.anchors,
      required this.getRots,
      required this.route,
      required this.setAngle,
      required this.maxOffline})
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
    sketch = MySketch(
      widget.getRots,
      widget.route,
      widget.setAngle,
      widget.maxOffline,
    );
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
  List<Point> Function() getAnchors;
  void Function(num angle) setAngle;
  Line route;
  Point? previousLoc;

  num maxOffline;

  MySketch(
    this.getAnchors,
    this.route,
    this.setAngle,
    this.maxOffline,
  );

  void setup() {
    // size(300, 300);
  }

  void draw() {
    background(color(255, 255, 255));

    strokeWeight(1);
    List<Point> anchors = getAnchors();
    drawAnchors(anchors);
    drawPath(route);

    // check if there are intersections
    Point? intersection = mostLikelyPosistion(getIntersections(anchors));
    if (intersection == null) {
      return;
    }

    previousLoc = intersection;
    Point point = getClosestPointOnPath(intersection, route);
    drawPoints([intersection, point]);

    drawLine(previousLoc![0], previousLoc![1], point[0], point[1]);
    num angleOfLine = getAngleOfLine([intersection, point]);

    // num distanceToLine = getLenghtOfLine([intersection, point]).abs();

    // if (distanceToLine > 100) {
    angleOfLine += 90;
    // } else {
    //   angleOfLine += scaleBetween(distanceToLine, 0, 90, 0, 100);
    // }
    setAngle(angleOfLine);
  }

  bool isLeftOfLine(Point point, Line line) {
    return ((line[1][0] - line[0][0]) * (point[1] - line[0][1]) -
            (line[1][1] - line[0][1]) * (point[0] - line[0][0])) >
        0;
  }

  num scaleBetween(
    num unscaled,
    num minAllowed,
    num maxAllowed,
    num min,
    num max,
  ) {
    return ((maxAllowed - minAllowed) * (unscaled - min) / (max - min)) +
        minAllowed;
  }

  void drawLine(num x1, num y1, num x2, num y2) {
    stroke(Colors.black);
    strokeWeight(2);
    line(x1.toDouble(), y1.toDouble(), x2.toDouble(), y2.toDouble());
  }

  num getLenghtOfLine(Line line) {
    num x = line[1][0] - line[0][0];
    num y = line[1][1] - line[0][1];

    return sqrt(x * x + y * y);
  }

  Point getClosestPointOnLine(Point point, Line line) {
    num a = point[0] - line[0][0];
    num b = point[1] - line[0][1];

    num c = line[1][0] - line[0][0];
    num d = line[1][1] - line[0][1];

    num dot = a * c + b * d;
    num lenSq = c * c + d * d;
    num param = -1;

    if (lenSq != 0) {
      param = dot / lenSq;
    }

    num xx, yy = 0;

    if (param < 0) {
      xx = line[0][0];
      yy = line[0][1];
    } else if (param > 1) {
      xx = line[1][0];
      yy = line[1][1];
    } else {
      xx = line[0][0] + param * c;
      yy = line[0][1] + param * d;
    }

    return [xx, yy];
  }

  num getDistanceToLine(Point point, Line line) {
    var closestPoint = getClosestPointOnLine(point, line);
    num dx = point[0] - closestPoint[0];
    num dy = point[1] - closestPoint[1];

    return sqrt(dx * dx + dy * dy);
  }

  num getAngleOfLine(Line line) {
    num dx = line[1][0] - line[0][0];
    num dy = line[1][1] - line[0][1];

    num theta = atan2(dy, dx) * (180 / pi);
    if (theta < 0) theta += 360;
    // return atan2(dy, dx);
    return theta;
  }

  List<Point> getIntersections(List<Point> anchors) {
    num x1 = anchors[0][0];
    num y1 = anchors[0][1];
    num r1 = anchors[0][2];

    num x2 = anchors[1][0];
    num y2 = anchors[1][1];
    num r2 = anchors[1][2];

    num dx = x2 - x1;
    num dy = y2 - y1;

    int d = sqrt(dx * dx + dy * dy).round();

    if (d > r1 + r2) return [];

    num cd = ((r1 * r1) - (r2 * r2) + (d * d)) / (2 * d);
    num t = ((r1 * r1) - (cd * cd));
    if (t < 0) {
      return [];
    }
    num hcl = sqrt(t);
    num cmpx = x1 + ((cd * dx) / d);
    num cmpy = y1 + ((cd * dy) / d);

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

  Line getClosestPartOfPath(Point point, Line pathPoints) {
    var line = [pathPoints[0], pathPoints[1]];
    num closest = getDistanceToLine(point, line);

    for (int i = 1; i < pathPoints.length - 1; i++) {
      num distance =
          getDistanceToLine(point, [pathPoints[i], pathPoints[i + 1]]);
      if (distance < closest) {
        closest = distance;
        line = [pathPoints[i], pathPoints[i + 1]];
      }
    }

    return line;
  }

  Point getClosestPointOnPath(
    Point point,
    Line path,
  ) {
    Line pathPart = getClosestPartOfPath(point, path);
    return getClosestPointOnLine(point, pathPart);
  }

  void drawPath(Line pathPoints) {
    strokeWeight(5);
    stroke(Colors.black);
    for (int i = 0; i < pathPoints.length - 1; i++) {
      line(pathPoints[i][0].toDouble(), pathPoints[i][1].toDouble(),
          pathPoints[i + 1][0].toDouble(), pathPoints[i + 1][1].toDouble());
    }
  }

  void drawPoints(List<Point> intersections) {
    strokeWeight(20);
    stroke(Colors.red);
    intersections.forEach((i) {
      fill(Colors.black);
      paintCanvas.drawCircle(
          Offset(i[0].toDouble(), i[1].toDouble()), 10, fillPaint);
    });
  }

  void drawAnchors(List<Point> anchors) {
    strokeWeight(5);
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

  Point? mostLikelyPosistion(List<Point> intersections) {
    if (intersections.length <= 0) {
      return null;
    }
    if (previousLoc == null) {
      return intersections[0];
    }
    // calculate the most likely position
    Point mostLikely = intersections[0];

    // get the distance from previous pos
    num closest = -1;
    intersections.forEach((element) {
      num dist = distanceBetweenPoints(element, previousLoc ?? [0, 0]);
      if (closest == -1 || closest > dist) {
        closest = dist;
        mostLikely = element;
      }
    });
    // return [closest[1]];
    return mostLikely;
  }

  num distanceBetweenPoints(Point point1, Point point2) {
    return sqrt(pow(point2[0] - point1[0], 2) + pow(point2[1] - point1[1], 2));
  }
}
