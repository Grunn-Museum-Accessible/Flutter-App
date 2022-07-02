import 'dart:math' as Math;

import 'package:app/helpers/ble.dart';
import 'package:app/helpers/globals.dart';
import 'package:app/libs/positioning/positioning.dart';
import 'package:app/libs/surround_sound/src/sound_controller.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PositioningScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Route route;

  PositioningScreen({Key? key, required this.device, required this.route})
      : super(key: key);

  @override
  PositioningScreenState createState() => PositioningScreenState();
}

class PositioningScreenState extends State<PositioningScreen> {
  late BleDevice bleDevice;
  late PositioningVisualiser positionVisualizer;
  late final SoundController _controller;
  String soundFile =
      'https://sfmygozkc1b6pom6ld5krvdok3dpc2eh.ui.nabu.casa/local/ping.mp3';

  List<double> anchor1 = [20, 20, 20];
  List<double> anchor2 = [20, 350, 20];
  List<double> anchor3 = [350, 500, 20];

  List<String> guids = [
    '667f1c78-be2e-11ec-9d64-0242ac120002', // anchor 1
    '667f1c78-be2e-11ec-9d64-0242ac120003', // anchor 2
    '667f1c78-be2e-11ec-9d64-0242ac120005'  // anchor 3
  ];

  @override
  void dispose() async {
    _controller.dispose();
    audioPlayer.stop();
    super.dispose();
    await bleDevice.deconstruct();
  }

  @override
  void initState() {
    super.initState();
    _controller = SoundController(soundFile)..loopAudio(true);

    connectToBleDevice(widget.device).then((ble) {
      setState(() {
        bleDevice = ble;
      });

      _setupAnchors().then((_) {
        _addListeneres();
      });
    });

    positionVisualizer = PositioningVisualiser(
      checkDistance: checkDistance,
      getAnchorInfo: getAnchorInfo,
      route: widget.route,
      setAngle: setAngle,
      maxOffline: 100,
    );
  }

  Future<void> _setupAnchors() async {
    String uuid = '667f1c78-be2e-11ec-9d64-0242ac120004';
    BluetoothCharacteristic bleChar = bleDevice.getBluetoothCharacterstic(uuid);

    String createAnchorString() {
      return '20|20:20|350:350|500';
    }

    return bleChar.write(createAnchorString().codeUnits);
  }

  void _addListeneres() async {
    await bleDevice.addListenerToCharacteristic(guids[0], _anchor1Listener);
    await bleDevice.addListenerToCharacteristic(guids[1], _anchor2Listener);
    await bleDevice.addListenerToCharacteristic(guids[2], _anchor3Listener);
  }

  void _anchor1Listener(List<int> chars) {
    String strVal = String.fromCharCodes(chars);
    String part = strVal.split('.')[0];
    if (isNumeric(part)) {
      try {
        setState(() {
          anchor1 = [20, 20, double.parse(part)];
        });
      } catch (e) {
        // empty catch
      }
    }
  }

  void _anchor2Listener(List<int> chars) {
    String part = String.fromCharCodes(chars);
    if (isNumeric(part)) {
      try {
        setState(() {
          anchor2 = [20, 350, double.parse(part)];
        });
      } catch (e) {
        // empty catch
      }
    }
  }

  void _anchor3Listener(List<int> chars) {
    String part = String.fromCharCodes(chars);
    if (isNumeric(part)) {
      try {
        setState(() {
          anchor3 = [350, 500, double.parse(part)];
        });
      } catch (e) {
        // empty catch
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 38, 38, 38),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 38, 38, 38),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Center(
            child: SvgPicture.asset(
              'assets/images/groningerMuseumLogo.svg',
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Text(
                              'Distance of anchor 1: ' + anchor1[2].toString(),
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Distance of anchor 2: ' + anchor2[2].toString(),
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Distance of anchor 3: ' + anchor3[2].toString(),
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return positionVisualizer;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkDistance(num distance, num maxDist) async {
    if (distance > maxDist) {
      await _controller.loopAudio(true);
      await _controller.play();
    } else {
      await _controller.loopAudio(false);
      await _controller.pause();
    }
  }

  double degToRadians(num deg) {
    return deg * Math.pi / 180;
  }

  void setAngle(num angle, num compassAngle) {
    _controller.setAngle(
      (compassAngle - angle + 180) % 360 - 180
    );
  }

  List<Anchor> getAnchorInfo() {
    return [
      Anchor.fromList(anchor1),
      Anchor.fromList(anchor2),
      Anchor.fromList(anchor3)
    ];
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}
