import 'dart:convert' show jsonDecode;
import 'dart:math';

import 'package:app/helpers/restApi.dart';
import 'package:flutter/material.dart';

class Point {
  late num x;
  late num y;

  num? soundRange;
  String? soundFile;

  Point(
    this.x,
    this.y, {
    this.soundFile,
    this.soundRange,
  });

  Point.fromString(String json) {
    var parsedJson = jsonDecode(json);

    if (parsedJson['soundRange'] != null) {
      soundFile = parsedJson['soundFile'];
      soundRange = parsedJson['soundRange'];
    }

    x = num.parse(parsedJson['x'].toString());
    y = num.parse(parsedJson['y'].toString());
  }

  get offset => Offset(x.toDouble(), y.toDouble());
  get hasSound => soundRange != null;
  get soundURL => hasSound ? RestClient.baseUrl + soundFile! : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && (other.x == x && other.y == y);

  String toJSON() {
    if (soundFile == null) {
      return '{"x":"$x", "y":"$y"}';
    } else {
      return '{"x": "$x", "y":"$y", "soundRange":"$soundRange", "soundFile":"$soundFile"}';
    }
  }

  num distanceTo(Point other) {
    return sqrt(pow(other.x - x, 2) + pow(other.y - y, 2));
  }
}
