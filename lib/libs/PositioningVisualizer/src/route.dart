import 'dart:convert';

import 'package:app/helpers/globals.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';

class Route {
  late String name;

  late List<Line> parts;
  Point? tempLast;
  Route(this.name, this.parts);

  Route.fromList(String name, List<List<num>> list) {
    this.name = name;
    parts = [];
    for (int i = 0; i < list.length - 1; i++) {
      parts.add(
        Line(
          Point(
            list[i][0],
            list[i][1],
          ),
          Point(
            list[i + 1][0],
            list[i + 1][1],
          ),
        ),
      );
    }
  }

  Route.fromString(String source) {
    var parsed = jsonDecode(source);
    name = parsed['name'];

    parts = [];
    parsed['parts'].forEach((element) {
      // var startPointType = ;
      List<Point> lineEnds = [];
      ['start', 'end'].forEach((end) {
        lineEnds.add(Point.fromString(jsonEncode(element[end])));
      });
      parts.add(Line(lineEnds[0], lineEnds[1]));
    });
  }
  String toJson() {
    String json = '{"name": "$name", "parts": [';
    json += parts.map((e) => e.toJson()).join(',');
    json += ']}';

    return json;
  }

  get length => parts.length;
  get start => length > 0 ? parts.first.start : null;
  get end {
    if (length > 0) {
      return parts.last.end;
    } else if (tempLast != null) {
      return tempLast;
    }
  }

  Line? getNextPart(current) {
    if (parts.last == current) {
      return null;
    }
    return parts[parts.indexOf(current) + 1];
  }

  void removePartAt(int part) {
    if (part == 0) {
      parts.removeAt(part);
    } else if (length == part) {
      parts.removeLast();
    } else if (length > part) {
      parts.removeAt(part);
      parts[part - 1].end = parts[part].start;
    }
  }

  void addPart(Point point) {
    if (length > 0 || tempLast != null) {
      parts.add(Line(end, point));
    } else {
      tempLast = point;
    }

    restAPI.updateRoute(this);
  }

  operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (!(other is Route)) {
      return false;
    } else if (other.parts.length != parts.length) {
      return false;
    }
    for (int i = 0; i < parts.length; i++) {
      if (parts[i] != other.parts[i]) {
        return false;
      }
    }
    return true;
  }
}
