// ignore_for_file: always_use_package_imports

import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart' hide Route;

import './anchor.dart';
import './line.dart';
import './point.dart';

import 'package:p5/p5.dart';

class Route {
  late List<Line> parts;

  Route(this.parts);
  Route.fromList(List<List<num>> list) {
    parts = [];
    for (int i = 0; i < list.length - 1; i++) {
      parts.add(Line.fromList([list[i], list[i + 1]]));
    }
  }

  get length {
    return parts.length;
  }

  Line? getNextPart(current) {
    if (parts.last == current) {
      return null;
    }
    return parts[parts.indexOf(current) + 1];
  }
}

// typedef Line = List<List<num>>;
// typedef Point = List<num>;

class PositioningVisualiser extends StatefulWidget {
  final List<Anchor> Function() getAnchorInfo;
  final void Function(num angle) setAngle;

  final Route route;

  final num maxOffline;

  PositioningVisualiser(
      {Key? key,
      required this.getAnchorInfo,
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
      widget.getAnchorInfo,
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
  List<Anchor> Function() getAnchors;
  void Function(num angle) setAngle;
  Route route;
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
    List<Anchor> anchors = getAnchors();
    drawAnchors(anchors);
    drawPath(route);

    // check if there are intersections
    Point? intersection = mostLikelyPosistion(getIntersections(anchors));
    if (intersection == null) {
      return;
    }

    previousLoc = intersection;
    // calulate the closest line and the angle and distance towards it.
    Point closestPoint = getClosestPointOnRoute(intersection, route);
    num angleOfLine = getAngleOfLine(Line(intersection, closestPoint));
    num distanceToClosestPoint =
        getLenghtOfLine(Line(intersection, closestPoint));

    Point nextWaypoint = closestPoint;

    if (distanceToClosestPoint > 100) {
      angleOfLine += 90;
    } else {
      // you are within a distance of the line

      // get the closest part of the route to the current possition
      Line closestLine = getClosestPartOfRoute(intersection, route);
      // if the closest point is the end of the line we route to the next part
      if (getLenghtOfLine(Line(closestPoint, closestLine.end)) < 30) {
        // get the next line to get its end. if there are no parts left
        // we take the current line
        Line nextLine = route.getNextPart(closestLine) ?? closestLine;
        nextWaypoint = nextLine.end;

        // calculate the angle to the next waypoint
        angleOfLine = getAngleOfLine(
          Line(
            intersection,
            nextLine.end,
          ),
        );
      } else {
        nextWaypoint = closestPoint;

        angleOfLine = getAngleOfLine(Line(
          intersection,
          closestLine.end,
        ));
      }

      // num combiningFactor =
      //     scaleBetween(distanceToClosestPoint, -angleToEndOfLine, 0, 0, 100) *
      //         -1;
      // log(combiningFactor.toString());
      angleOfLine += 90;
    }

    setAngle(angleOfLine);

    // draw line to nesxt waypoint
    drawLine(intersection, nextWaypoint);
    drawPoints([intersection, nextWaypoint]);
  }

  bool isLeftOfLine(Point point, Line line) {
    return ((line.end.x - line.start.x) * (point.y - line.start.y) -
            (line.end.y - line.start.y) * (point.x - line.start.x)) >
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

  void drawLine(Point start, Point end) {
    stroke(Colors.black);
    strokeWeight(4);
    line(
      start.x.toDouble(),
      start.y.toDouble(),
      end.x.toDouble(),
      end.y.toDouble(),
    );
  }

  num getLenghtOfLine(Line line) {
    num x = line.end.x - line.start.x;
    num y = line.end.y - line.start.y;

    return sqrt(x * x + y * y);
  }

  Point getClosestPointOnLine(Point point, Line line) {
    num a = point.x - line.start.x;
    num b = point.y - line.start.y;

    num c = line.end.x - line.start.x;
    num d = line.end.y - line.start.y;

    num dot = a * c + b * d;
    num lenSq = c * c + d * d;
    num param = -1;

    if (lenSq != 0) {
      param = dot / lenSq;
    }

    num xx, yy = 0;

    if (param < 0) {
      xx = line.start.x;
      yy = line.start.y;
    } else if (param > 1) {
      xx = line.end.x;
      yy = line.end.y;
    } else {
      xx = line.start.x + param * c;
      yy = line.start.y + param * d;
    }

    return Point(xx, yy);
  }

  num getDistanceToLine(Point point, Line line) {
    var closestPoint = getClosestPointOnLine(point, line);
    num dx = point.x - closestPoint.x;
    num dy = point.y - closestPoint.y;

    return sqrt(dx * dx + dy * dy);
  }

  num getAngleOfLine(Line line) {
    num dx = line.end.x - line.start.x;
    num dy = line.end.y - line.start.y;

    num theta = atan2(dy, dx) * (180 / pi);
    if (theta < 0) theta += 360;
    // return atan2(dy, dx);
    return theta;
  }

  List<Point> getIntersections(List<Anchor> anchors) {
    num x1 = anchors[0].x;
    num y1 = anchors[0].y;
    num r1 = anchors[0].distance;

    num r2 = anchors[1].distance;

    num dx = anchors[1].x - x1;
    num dy = anchors[1].y - y1;

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

    var i1 = Point(
      (cmpx + (hcl * dy) / d).round(),
      (cmpy - (hcl * dx) / d).round(),
    );
    var i2 = Point(
      (cmpx - (hcl * dy) / d).round(),
      (cmpy + (hcl * dx) / d).round(),
    );

    return [i1, i2];
  }

  Line getClosestPartOfRoute(Point point, Route route) {
    num closest = getDistanceToLine(point, route.parts.first);
    Line line = route.parts.first;

    for (int i = 1; i < route.length; i++) {
      num distance = getDistanceToLine(point, route.parts[i]);
      if (distance < closest) {
        closest = distance;
        line = route.parts[i];
      }
    }

    return line;
  }

  Point getClosestPointOnRoute(
    Point point,
    Route path,
  ) {
    Line pathPart = getClosestPartOfRoute(point, path);
    return getClosestPointOnLine(point, pathPart);
  }

  void drawPath(Route route) {
    strokeWeight(5);
    stroke(Colors.black);
    for (int i = 0; i < route.length; i++) {
      line(
        route.parts[i].start.x.toDouble(),
        route.parts[i].start.y.toDouble(),
        route.parts[i].end.x.toDouble(),
        route.parts[i].end.y.toDouble(),
      );
    }
  }

  void drawPoints(List<Point> intersections) {
    strokeWeight(20);
    stroke(Colors.red);
    intersections.forEach((i) {
      fill(Colors.black);
      paintCanvas.drawCircle(
        i.toOffset(),
        10,
        fillPaint,
      );
    });
  }

  void drawAnchors(List<Anchor> anchors) {
    strokeWeight(5);
    anchors.forEach((pos) {
      stroke(Colors.black);
      fill(Color.fromARGB(106, 244, 67, 54));
      paintCanvas.drawCircle(
        pos.coordsToOffset(),
        pos.distance.toDouble(),
        strokePaint,
      );

      paintCanvas.drawCircle(
        pos.coordsToOffset(),
        pos.distance.toDouble(),
        fillPaint,
      );

      fill(Colors.black);
      paintCanvas.drawCircle(pos.pos.toOffset(), 5, fillPaint);
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

    num closest = -1;
    intersections.forEach((element) {
      // get the distance from previous pos
      num dist = distanceBetweenPoints(element, previousLoc ?? Point(0, 0));
      if (closest == -1 || closest > dist) {
        closest = dist;
        mostLikely = element;
      }
    });
    return mostLikely;
  }

  num distanceBetweenPoints(Point point1, Point point2) {
    return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2));
  }
}
