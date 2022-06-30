// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, lines_longer_than_80_chars

import 'dart:convert';
import 'dart:math';

import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:flutter/cupertino.dart';

class Route {
  late String name;
  late String description;
  late String image;

  ValueNotifier<List<Line>> _parts = ValueNotifier<List<Line>>([]);

  List<Line> get parts => _parts.value;
  set parts(List<Line> newParts) => _parts.value = newParts;

  get routePartNotifier => _parts;

  Point? tempLast;
  Route(this.name, this.description, this.image, parts) {
    _parts.value = parts;
  }

  Route.fromList(
    this.name,
    this.description,
    this.image,
    List<List<num>> list,
  ) {
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
      _parts.notifyListeners();
    }
  }

  Route.fromString(String source) {
    var parsed = jsonDecode(source);
    name = parsed['name'];
    image = parsed['image'];
    description = parsed['description'];

    parts = [];
    parsed['parts'].forEach((element) {
      // var startPointType = ;
      List<Point> lineEnds = [];
      ['start', 'end'].forEach((end) {
        lineEnds.add(Point.fromString(jsonEncode(element[end])));
      });
      parts.add(Line(lineEnds[0], lineEnds[1]));
    });

    _parts.notifyListeners();
  }

  static List<Route> routeListFromString(String json) {
    List<dynamic> parsed = jsonDecode(json);

    return parsed.map((i) {
      // print(i['parts']);

      List<Line> _parts = [];

      i['parts'].forEach((element) {
        // var startPointType = ;
        List<Point> lineEnds = [];
        ['start', 'end'].forEach((end) {
          lineEnds.add(
            Point(
              element[end]['x'],
              element[end]['y'],
              soundFile: element[end]['soundFile'],
              soundRange: element[end]['soundRange'],
            ),
          );
        });
        _parts.add(Line(lineEnds[0], lineEnds[1]));
      });

      return Route(
        i['name'] ?? '',
        i['description'] ?? '',
        i['image'] ?? '',
        _parts,
      );
    }).toList();
  }

  String toJson() {
    String json =
        '{"name": "$name", "image": "$image" "description", "$description", "parts": [';
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
      _parts.value.add(Line(end, point));
      _parts.notifyListeners();
    } else {
      tempLast = point;
    }
  }

  List<Point> get bounds {
    if (parts.isEmpty) {
      return [];
    }
    // get list of x's and y's
    List<num> xs = [parts.first.start.x];
    List<num> ys = [parts.first.start.y];
    parts.forEach((element) {
      xs.add(element.end.x);
      ys.add(element.end.y);
    });

    // get x range
    num minX = xs.reduce(min);
    num maxX = xs.reduce(max);

    // get y range
    num minY = ys.reduce(min);
    num maxY = ys.reduce(max);

    return [
      Point(minX, minY),
      Point(maxX, maxY),
    ];
  }

  List<String> get AudioFiles {
    List<String> files = [];

    parts.forEach((part) {
      if (part.start.soundFile != null) {
        files.add(part.start.soundFile!);
      }

      if (part.end.soundFile != null) {
        files.add(part.end.soundFile!);
      }
      // files.addAll([part.start.soundFile, part.end.soundFile]);
    });

    return files;
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
