// ignore_for_file: lines_longer_than_80_chars, always_use_package_imports

import 'dart:convert';
import 'dart:math' show atan2, pi, sqrt;

import './point.dart';

class Line {
  late Point start;
  late Point end;

  late num maxDistance;

  Line(this.start, this.end, [this.maxDistance = 100]);
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

    maxDistance = num.tryParse(parsed['maxDistance']) ?? 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line && (other.start == start && other.end == end);

  String toJson() {
    return '{"start": ${start.toJson()}, "end":${end.toJson()}, "maxDistance": "$maxDistance"}';
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
