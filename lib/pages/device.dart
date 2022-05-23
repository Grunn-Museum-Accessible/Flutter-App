import 'dart:convert';
import 'dart:developer';
import 'dart:math' as Math;

import 'package:app/helpers/ble.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/widgets/AddAudioPointDialog.dart';
import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectedDeviceScreen extends StatefulWidget {
  BluetoothDevice device;
  ConnectedDeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);
  @override
  ConnectedDeviceScreenState createState() => ConnectedDeviceScreenState();
}

class ConnectedDeviceScreenState extends State<ConnectedDeviceScreen> {
  late BleDevice bleDevice;
  late PositioningVisualiser positionVisualizer;

  String rot1Val = '0';
  String rot2Val = '0';
  List<int> rot1 = [20, 20, 20];
  List<int> rot2 = [20, 20, 20];
  Route route = Route.fromList('testRoute', [
    [20, 200],
    [100, 400],
    [300, 600],
    [700, 400],
    [750, 300],
    [900, 200],
    [950, 200],
    [1100, 500]
  ]);

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
    connectToBleDevice(widget.device).then((ble) {
      setState(() {
        bleDevice = ble;
      });
      _addListeneres();
    });

    positionVisualizer = PositioningVisualiser(
      getAnchorInfo: getAnchorInfo,
      route: route,
      setAngle: setAngle,
      maxOffline: 100,
    );
  }

  void _addListeneres() async {
    log('adding callback listerners');
    await bleDevice.addListenerToCharacteristic(guids[0], _rot1Listener);
    log('added rot1');
    await bleDevice.addListenerToCharacteristic(guids[1], _rot2Listener);
    log('added rot2');
  }

  void _rot1Listener(List<int> chars) {
    String strVal = String.fromCharCodes(chars);
    log('rot 1: ' + strVal);
    String part = strVal.split('.')[0];
    if (isNumeric(part)) {
      try {
        setState(() {
          rot1Val = part;
          rot1 = [20, 20, int.parse(part, radix: 10)];
        });
      } catch (e) {}
    }
  }

  void _rot2Listener(List<int> chars) {
    String strVal = String.fromCharCodes(chars);
    log('rot 2: ' + strVal);

    String part = strVal.split('.')[0];
    if (isNumeric(part)) {
      try {
        setState(() {
          rot2Val = part;
          rot2 = [350, 500, int.parse(part, radix: 10)];
        });
      } catch (e) {}
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
                      LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return positionVisualizer;
                      }),
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
    );
  }

  double degToRadians(num deg) {
    return deg * Math.pi / 180;
  }

  void setAngle(num angle) {
    // log(angle.toString());
    arrowAngle = angle;
  }

  List<Anchor> getAnchorInfo() {
    return [Anchor.fromList(rot1), Anchor.fromList(rot2)];
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}
