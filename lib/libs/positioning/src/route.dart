import 'dart:convert';

import 'package:app/helpers/globals.dart';
import 'package:app/libs/positioning/positioning.dart';

class Route {
  late String name;
  late String thumbnail;
  late String? description;
  late List<Line> parts;
  Point? tempLast;

  Route({
    required this.name,
    required this.thumbnail,
    required this.parts,
    this.description
  });

  Route.fromList({
    required String name,
    required String thumbnail,
    required List<List<num>> list,
    String? description
  }) {
    this.name = name;
    this.thumbnail = thumbnail;
    if (description != null) {
      this.description = description;
    }

    parts = [];
    for (int i = 0; i < list.length - 1; i++) {
      parts.add(
        Line(
          Point(list[i][0], list[i][1]),
          Point(list[i + 1][0], list[i + 1][1])
        )
      );
    }
  }

  Route.fromString(String source) {
    var parsed = jsonDecode(source);
    name = parsed['name'];
    description = parsed['description'];
    thumbnail = parsed['thumbnail'];

    parts = [];
    parsed['parts'].forEach((element) {
      parts.add(Line(
        Point.fromString(jsonEncode(element['start'])),
        Point.fromString(jsonEncode(element['end']))
      ));
    });
  }

  String toJSON() {
    String json = '{"name": "$name", "thumbnail": "$thumbnail", ';
    if (description != null) {
      json += '"description": "$description", ';
    }

    json += '"parts": [';
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
