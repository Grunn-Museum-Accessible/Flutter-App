import './point.dart';

class Line {
  late Point start;
  late Point end;

  Line(this.start, this.end);
  Line.fromList(list) {
    start = Point.fromList(list[0]);
    end = Point.fromList(list[1]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line && (other.start == start && other.end == end);
}
