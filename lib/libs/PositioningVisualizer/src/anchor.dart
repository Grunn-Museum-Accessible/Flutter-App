import './point.dart';
import 'package:flutter/material.dart';

class Anchor extends Point {
  late num distance;

  Anchor(num x, num y, this.distance) : super(x, y);
  Anchor.fromPoint(Point point, this.distance) : super(point.x, point.y);

  /// anchorInfo[0] = x, anchorInfo[1] = y, anchorInfo[2] = distancex
  Anchor.fromList(List<int> anchorInfo) : super(anchorInfo[0], anchorInfo[1]) {
    distance = anchorInfo[2];
  }
}
