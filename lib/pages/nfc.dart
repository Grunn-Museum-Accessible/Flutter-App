import 'dart:math' as math;
import 'package:app/helpers/background.dart';
import 'package:app/helpers/ble.dart';
import 'package:app/libs/positioning/positioning.dart';
import 'package:app/pages/devices.dart' show DevicesScreen;
import 'package:app/pages/route.dart' show RouteScreen;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCScreen extends StatefulWidget {
  final Route route;

  NFCScreen({
    Key? key,
    required this.route
  }) : super(key: key);

  @override
  NFCScreenState createState() => NFCScreenState();
}

class NFCScreenState extends State<NFCScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = true;
  List<ScanResult> foundDevices = [];

  List<Widget> get foundDevicesWidgets => buildConnectedDevices(
    context, foundDevices, widget.route);

  void _startScan() {
    scanDevices(
      context: context,
      route: widget.route,
      flutterBlue: flutterBlue,
      callback: (results) => setState(() {
        foundDevices = results;
        isScanning = false;
      })
    );
  }

  @override
  void setState(void Function() fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    NfcManager.instance.isAvailable().then(
      (bool isAvailable) {
        if (isAvailable) {
          _startScan();
          NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
              Ndef? ndef = Ndef.from(tag);
              if (ndef == null) return;

              NdefMessage msg = await ndef.read();
              msg.records.forEach((element) {
                String readValue = String.fromCharCodes(element.payload)
                  .substring(3)
                  .toUpperCase();

                foundDevices.forEach((dev) {
                  if (dev.device.id.toString() == readValue) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteScreen(
                          device: dev.device,
                          route: widget.route
                        ),
                      ),
                    );
                  }
                });
              });
            },
          );
        } else {
          Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (context) => DevicesScreen(
              devices: foundDevices,
              route: widget.route
            ))
          );
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.route.name,
          style: themeData.textTheme.headline3,
          textAlign: TextAlign.center
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Header(size: size),
          Visibility(
            visible: !isScanning,
            child: Stack(
              children: [
                printClippedText(
                  'VERBIND MET\nNFC', 
                  TextStyle(
                    color: Color(0xFF0F595B),
                    fontFamily: 'Eurostile',
                    fontSize: 28
                  ), 
                  TextStyle(
                    color: Color(0xFF000000),
                    fontFamily: 'Eurostile',
                    fontSize: 28
                  ),
                  100.0
                ),
                MediaQuery.of(context).orientation == Orientation.landscape
                ? SizedBox.shrink() : Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/nfc.svg',
                    color: Color(0xFF0F595B),
                    width: size.width * 0.8
                  )
                )
              ]
            ),
            replacement: Column(
              children: [
                printClippedText(
                  'APPARATEN ZOEKEN', 
                  TextStyle(
                    color: Color(0xFF0F595B),
                    fontFamily: 'Eurostile',
                    fontSize: 28
                  ), 
                  TextStyle(
                    color: Color(0xFF000000),
                    fontFamily: 'Eurostile',
                    fontSize: 28
                  ),
                  100.0
                ),
                Padding(
                  padding: EdgeInsets.all(36),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
          /**
           * Go to devices page
           */
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => DevicesScreen(
                        devices: foundDevices,
                        route: widget.route
                      ))
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'GEEN NFC?', 
                        style: themeData.textTheme.headline2,
                        semanticsLabel: 'Handmatig verbinden',
                      ),
                      SizedBox(height: 20),
                      Transform.rotate(
                        angle: 330 * math.pi / 180,
                        child: Icon(
                          Icons.touch_app_rounded,
                          color: Color(0xFF000000),
                          size: 50.0,
                        )
                      ),
                      SizedBox(height: 20)
                    ]
                  )
                )
              )
            ]
          )
        ]
      ),
    );
  }
}
