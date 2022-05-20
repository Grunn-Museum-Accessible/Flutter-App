import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';

class Point {
  late num x;
  late num y;

  Point(this.x, this.y);
  Point.fromList(List<num> coordinates) {
    x = coordinates[0];
    y = coordinates[1];
  }

  Point.fromString(String json) {
    var parsedJson = jsonDecode(json);
    x = parsedJson['x'];
    y = parsedJson['y'];
  }

  get offset => Offset(x.toDouble(), y.toDouble());

  /// convert a 2d list to a list of points List<Point>
  static List<Point> fromListToListOfPoints(List<List<num>> e) {
    return e.map((e) => Point.fromList(e)).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && (other.x == x && other.y == y);

  String toJson() {
    return '{"x":"$x", "y":"$y"}';
  }
}
