import 'package:flutter/material.dart';

class Point {
  late num x;
  late num y;

  Point(this.x, this.y);
  Point.fromList(List<num> coordinates) {
    x = coordinates[0];
    y = coordinates[1];
  }

  Offset toOffset() {
    return Offset(x.toDouble(), y.toDouble());
  }

  /// convert a 2d list to a list of points List<Point>
  static List<Point> fromListToListOfPoints(List<List<num>> e) {
    return e.map((e) => Point.fromList(e)).toList();
  }
}
