import 'dart:convert';

import './point.dart';

class Line {
  late Point start;
  late Point end;

  Line(this.start, this.end);
  Line.fromList(list) {
    start = Point.fromList(list[0]);
    end = Point.fromList(list[1]);
  }
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
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line && (other.start == start && other.end == end);

  String toJson() {
    return '{"start": ${start.toJson()}, "end":${end.toJson()}}';
  }
}
