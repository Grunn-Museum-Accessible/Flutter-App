import 'dart:convert';

import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';

class SoundPoint extends Point {
  num soundRange;
  String soundFile;

  SoundPoint(x, y, this.soundFile, this.soundRange) : super(x, y);

  factory SoundPoint.fromString(String json) {
    var data = jsonDecode(json);

    num x = num.parse(data['x']);
    num y = num.parse(data['y']);

    String soundFile = data['soundFile'];
    num soundRange = num.parse(data['soundRange']);

    return SoundPoint(x, y, soundFile, soundRange);
  }

  @override
  get hasSound => true;

  @override
  String toJson() {
    return '{"x": "$x", "y":"$y", "soundRange":"$soundRange", "soundFile":"$soundFile"}';
  }
}
