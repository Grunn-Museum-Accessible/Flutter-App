import 'dart:math' as Math;

import 'package:app/helpers/ble.dart';
import 'package:app/libs/positioning/positioning.dart';
import 'package:app/libs/surround_sound/src/sound_controller.dart';
import 'package:app/widgets/AddAudioPointDialog.dart';
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

  String rot1Val = '0';
  String rot2Val = '0';
  List<int> rot1 = [20, 20, 20];
  List<int> rot2 = [350, 500, 20];

  List<String> guids = [
    '667f1c78-be2e-11ec-9d64-0242ac120002', // rot 1
    '667f1c78-be2e-11ec-9d64-0242ac120003' // rot 2
  ];

  num arrowAngle = 0;

  @override
  void dispose() {
    bleDevice.deconstruct();
    super.dispose();
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
      return '20|20:350|500';
    }

    return bleChar.write(createAnchorString().codeUnits);
  }

  void _addListeneres() async {
    await bleDevice.addListenerToCharacteristic(guids[0], _rot1Listener);
    await bleDevice.addListenerToCharacteristic(guids[1], _rot2Listener);
  }

  void _rot1Listener(List<int> chars) {
    String strVal = String.fromCharCodes(chars);
    String part = strVal.split('.')[0];
    if (isNumeric(part)) {
      try {
        setState(() {
          rot1Val = part;
          rot1 = [20, 20, int.parse(part, radix: 10)];
        });
      } catch (e) {
        // empty catch
      }
    }
  }

  void _rot2Listener(List<int> chars) {
    String strVal = String.fromCharCodes(chars);
    String part = strVal.split('.')[0];
    if (isNumeric(part)) {
      try {
        setState(() {
          rot2Val = part;
          rot2 = [350, 500, int.parse(part, radix: 10)];
        });
      } catch (e) {
        // empty catch
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            'Distance of anchor 1: ' + rot1Val,
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          Text(
                            'Distance of anchor 2: ' + rot2Val,
                            style: TextStyle(fontSize: 30, color: Colors.white),
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
                        Positioned(
                          top: 10,
                          right: 20,
                          child: AnimatedRotation(
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 300),
                            turns: arrowAngle.toDouble() / 360,
                            child: Image.asset(
                              'assets/images/arrow.png',
                              height: 100,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 212, 255, 0),
                              ),
                            ),
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddAudioPointDialog(
                                      addRoute: positionVisualizer.addPoint,
                                    );
                                  });
                            },
                            onPressed: () {
                              positionVisualizer.addPoint(null, null);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add,
                                size: 48,
                                color: Color.fromARGB(255, 38, 38, 38),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkDistance(num distance) async {
    if (distance > 30) {
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

  void setAngle(num angle) {
    _controller.setAngle(angle);
    arrowAngle = angle;
  }

  List<Anchor> getAnchorInfo() {
    return [Anchor.fromList(rot1), Anchor.fromList(rot2)];
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}
