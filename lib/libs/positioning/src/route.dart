import 'dart:convert';
import 'dart:developer';
import 'package:app/libs/positioning/positioning.dart';

class Route {
  late String name;
  late String thumbnail;
  late String? description;
  late List<Line> parts;
  Point? tempLast;

  Route(
      {required this.name,
      required this.thumbnail,
      required this.parts,
      this.description});

  Route.fromList(
      {required String name,
      required String thumbnail,
      required List<dynamic> list,
      String? description}) {
    this.name = name;
    this.thumbnail = thumbnail;
    if (description != null) {
      this.description = description;
    }

    parts = [];
    for (int i = 0; i < list.length - 1; i++) {
      parts.add(Line(
        Point.fromString(jsonEncode(list[i]['start'])),
        Point.fromString(jsonEncode(list[i]['end'])),
      ));
    }
  }

  static Route? fromString(String source) {
    try {
      var parsed = jsonDecode(source);
      String name = parsed['name'];
      String description = parsed['description'];
      String thumbnail = parsed['image'];

      List<Line> parts = [];
      parsed['parts'].forEach((element) {
        parts.add(Line(Point.fromString(jsonEncode(element['start'])),
            Point.fromString(jsonEncode(element['end']))));
      });
      return Route(
        name: name,
        description: description,
        thumbnail: thumbnail,
        parts: parts,
      );
    } catch (e) {
      log('one or more fields are invalid: ' + e.toString());
    }
  }

  String toJSON() {
    String json = '{"name": "$name", "image": "$thumbnail", ';
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
