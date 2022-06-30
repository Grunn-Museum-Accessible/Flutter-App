// ignore: always_use_package_imports
import './point.dart';

class Anchor extends Point {
  late num distance;

  Anchor(num x, num y, this.distance) : super(x, y);
  Anchor.fromPoint(Point point, this.distance) : super(point.x, point.y);

  /// anchorInfo[0] = x, anchorInfo[1] = y, anchorInfo[2] = distancex
  Anchor.fromList(List<num> anchorInfo) : super(anchorInfo[0], anchorInfo[1]) {
    distance = anchorInfo[2];
  }
}
