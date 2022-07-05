// ignore_for_file: always_use_package_imports

import 'dart:developer';
import 'dart:math' hide log;
import 'package:app/libs/PositioningVisualizer/src/route.dart';
import 'package:flutter/material.dart' hide Route;

import './anchor.dart';
import './line.dart';
import './point.dart';

import 'package:p5/p5.dart';

class PositioningVisualiser extends StatefulWidget {
  final List<Anchor> Function() getAnchorInfo;
  final void Function(num angle) setAngle;
  late final void Function(String? audioFile, num? range) addPoint;

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
    widget.addPoint = sketch.addPoint;
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
      height: MediaQuery.of(context).size.height - 181,
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

    List<Anchor> anchors = getAnchors();
    drawStatic(anchors);

    // check if there are intersections and draw the most likely one
    Point? intersection = mostLikelyPosistion(getIntersections(anchors));

    // if there is no intersection we return
    if (intersection == null) return;
    // if there is a iintersection we draw it and store it in previous loc
    previousLoc = intersection;
    drawPoint(intersection, Colors.cyan, 20);

    // if the length of the route is 0 we dont need to do anything
    // from this point
    if (route.length <= 0) return;

    // calulate the closest line, the angle, and distance towards it.
    Point closestPoint = getClosestPointOnRoute(intersection, route);
    num angleOfLine = Line(intersection, closestPoint).angle;
    num distanceToClosestPoint = Line(intersection, closestPoint).length;

    // make variable to store the point to navigate to
    Point nextWaypoint = closestPoint;

    if (distanceToClosestPoint >
        getClosestPartOfRoute(closestPoint, route).maxDistance) {
      // if the distance from the line is bigger than the configured distance
      // we navigate directly to it
      angleOfLine += 90;
    } else {
      // if it is smaller than we navigate to the next point on the line

      // get the closest part of the route to the current possition
      Line closestLine = getClosestPartOfRoute(intersection, route);

      // if we are close enoguh to the end of the line we
      // navigate to the next lines end
      if (Line(closestPoint, closestLine.end).length < 30) {
        // get the next line to get its end. if there are no parts left
        // we take the current line
        Line nextLine = route.getNextPart(closestLine) ?? closestLine;
        nextWaypoint = nextLine.end;

        // calculate the angle to the next waypoint
        angleOfLine = Line(
          intersection,
          nextLine.end,
        ).angle;
      } else {
        // else we navigate to the end of the closest line
        nextWaypoint = closestLine.end;

        angleOfLine = Line(
          intersection,
          closestLine.end,
        ).angle;
      }
      angleOfLine += 90;
    }

    // set the angle of the arrow
    setAngle(angleOfLine);

    // draw line to next waypoint
    drawLine(intersection, nextWaypoint);
    drawPoints([nextWaypoint]);
  }

  /// add the current point to the line
  void addPoint(String? soundFile, num? range) {
    List<Anchor> anchors = getAnchors();
    Point? intersection = mostLikelyPosistion(getIntersections(anchors));
    if (intersection != null) {
      log(soundFile ?? '');
      log((range ?? 0).toString());

      if (soundFile != null) {
        intersection.soundFile = soundFile;
        intersection.soundRange = range;
      }

      route.addPart(intersection);
    }
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

    num xx = 0;
    num yy = 0;

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

  List<Point> getIntersections(List<Anchor> anchors) {
    num x1 = anchors[0].x;
    num y1 = anchors[0].y;
    num r1 = anchors[0].distance;
    num r2 = anchors[1].distance;

    num dx = anchors[1].x - x1;
    num dy = anchors[1].y - y1;

    int d = sqrt(dx * dx + dy * dy).round();

    if (d > r1 + r2 || d == 0) return [];

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

  /// draw all parts of a route
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

  /// draw a single point with optional color and size
  void drawPoint(Point point, [Color? fillColor, num? size]) {
    fill(fillColor ?? Colors.black);
    paintCanvas.drawCircle(
      point.offset,
      (size ?? 10).toDouble(),
      fillPaint,
    );
  }

  /// draw a list of points with optional color and size
  void drawPoints(List<Point> points, [Color? fillColor, num? size]) {
    points.forEach((point) {
      drawPoint(point, fillColor, size);
    });
  }

  /// draw the anchors and the posible positions from it
  void drawAnchors(List<Anchor> anchors) {
    anchors.forEach((pos) {
      strokeWeight(10);
      stroke(Colors.black);
      // stroke(Color.fromARGB(255, 212, 255, 0));
      paintCanvas.drawCircle(
        pos.offset,
        pos.distance.toDouble(),
        strokePaint,
      );
      // Stroke
      strokeWeight(6);
      stroke(Color.fromARGB(255, 212, 255, 0));
      paintCanvas.drawCircle(
        pos.offset,
        pos.distance.toDouble(),
        strokePaint,
      );

      fill(Colors.black);
      paintCanvas.drawCircle(pos.offset, 5, fillPaint);
    });
  }

  /// get the most likely position based on the previuos position and
  /// current intersection points.
  ///
  /// if a empty list is given the function returns null
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
      num dist = element.distanceTo(previousLoc ?? Point(0, 0));
      if (closest == -1 || closest > dist) {
        closest = dist;
        mostLikely = element;
      }
    });
    return mostLikely;
  }

  /// draw a point for each point that has a audio clip added to it
  void drawSoundPointsInRoute() {
    List<Point> soundPoints = [];
    route.parts.forEach((e) {
      if (e.start.hasSound) soundPoints.add(e.start);
      if (e.end.hasSound) soundPoints.add(e.end);
    });

    // drawSoundPoints(soundPoints);
    drawPoints(soundPoints, Colors.amber);

    soundPoints.forEach((point) {
      drawPoint(point, Color.fromARGB(100, 255, 193, 7), point.soundRange);
    });
  }

  // draw the give anchors, route and sound points in the route
  void drawStatic(List<Anchor> anchors) {
    drawAnchors(anchors);
    drawPath(route);

    drawSoundPointsInRoute();
  }
}