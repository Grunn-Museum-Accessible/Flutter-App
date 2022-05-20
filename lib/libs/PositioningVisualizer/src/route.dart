import 'dart:convert';
import 'dart:io';

import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/libs/PositioningVisualizer/src/soundPoint.dart';

class Route {
  late List<Line> parts;
  Point? tempLast;
  Route(this.parts);

  Route.fromList(List<List<num>> list) {
    parts = [];
    for (int i = 0; i < list.length - 1; i++) {
      parts.add(Line.fromList([list[i], list[i + 1]]));
    }
  }
  Route.fromString(String source) {
    List<dynamic> parsed = jsonDecode(source);
    parts = [];
    parsed.forEach((element) {
      // var startPointType = ;
      List<Point> lineEnds = [];
      ['start', 'end'].forEach((end) {
        var pointTypeConst = element[end]['soundFile'] == null
            ? Point.fromString
            : SoundPoint.fromString;

        lineEnds.add(pointTypeConst(jsonEncode(element)));
      });
      parts.add(Line.fromList(lineEnds));
    });
  }
  String toJson() {
    String json = '[';
    json += parts.map((e) => e.toJson()).join(',');
    json += ']';

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
