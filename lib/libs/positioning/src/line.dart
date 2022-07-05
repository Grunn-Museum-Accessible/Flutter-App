import 'dart:convert';
import 'dart:math' show atan2, pi, sqrt;

import './point.dart';

class Line {
  late Point start;
  late Point end;

  late num maxDistance;

  Line(this.start, this.end, [this.maxDistance = 30]);
  Line.fromString(String json) {
    var parsed = jsonDecode(json);
    start = Point(
      num.parse(parsed['start']['x']),
      num.parse(parsed['start']['y']),
    );

    end = Point(
      num.parse(parsed['end']['x']),
      num.parse(parsed['end']['y']),
    );

    maxDistance = num.tryParse(parsed['maxDistance']) ?? 30;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line && (other.start == start && other.end == end);

  String toJson() {
    return '{"start": ${start.toJSON()}, "end":${end.toJSON()}, "maxDistance": "$maxDistance"}';
  }

  get angle {
    num dx = end.x - start.x;
    num dy = end.y - start.y;

    num theta = atan2(dy, dx) * (180 / pi);
    if (theta < 0) theta += 360;
    return theta;
  }

  get length {
    num x = end.x - start.x;
    num y = end.y - start.y;

    return sqrt(x * x + y * y);
  }
}
