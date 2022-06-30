import 'package:app/helpers/ble.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/widgets/AddAudioPointDialog.dart';
import 'package:app/widgets/routeCreationVIsualiser.dart';
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
  late CreateRouteVisualizer positionVisualizer;

  List<double> anchor1 = [20, 20, 20];
  List<double> anchor2 = [20, 350, 20];
  List<double> anchor3 = [350, 500, 20];

  List<String> guids = [
    '667f1c78-be2e-11ec-9d64-0242ac120002', // anchor 1
    '667f1c78-be2e-11ec-9d64-0242ac120003', // anchor 2
    '667f1c78-be2e-11ec-9d64-0242ac120005' // anchor 2
  ];

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

      _setupAnchors().then((_) {
        _addListeneres();
      });
    });

    positionVisualizer = CreateRouteVisualizer(
      getAnchorInfo: getAnchorInfo,
      route: widget.route,
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
                                Icons.add_location,
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
