import './point.dart';
import 'package:flutter/material.dart';

class Anchor {
  late Point pos;
  late num distance;

  get x => pos.x;
  get y => pos.y;

  Anchor(num x, num y, this.distance) {
    pos = Point(x, y);
  }

  Offset coordsToOffset() {
    return pos.offset;
  }

  /// anchorInfo[0] = x, anchorInfo[1] = y, anchorInfo[2] = distance
  Anchor.fromList(List<int> anchorInfo) {
    pos = Point(anchorInfo[0], anchorInfo[1]);
    distance = anchorInfo[2];
  }
}
