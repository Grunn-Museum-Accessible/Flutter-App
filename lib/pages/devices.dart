import 'package:app/helpers/background.dart';
import 'package:app/helpers/ble.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_blue/flutter_blue.dart';

class DevicesScreen extends StatefulWidget {
  final List<ScanResult> devices;
  final Route route;

  DevicesScreen({Key? key, required this.devices, required this.route})
      : super(key: key);

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = true;
  List<ScanResult> foundDevices = [];

  List<Widget> get foundDevicesWidgets =>
      buildConnectedDevices(context, foundDevices, widget.route);

  void _startScan() {
    scanDevices(
      context: context,
      route: widget.route,
      flutterBlue: flutterBlue,
      callback: (results) => setState(
        () {
          foundDevices = results;
          isScanning = false;
        },
      ),
    );
  }

  @override
  void setState(void Function() fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    foundDevices = widget.devices;
    if (foundDevices.length == 0) {
      _startScan();
    } else {
      isScanning = false;
    }

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
            title: Text(widget.route.name,
                style: themeData.textTheme.headline3,
                textAlign: TextAlign.center),
            elevation: 0.0),
        body: Stack(children: [
          Header(size: size),
          Visibility(
              visible: !isScanning,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    printClippedText(
                        'VERBIND HANDMATIG',
                        TextStyle(
                            color: Color(0xFF0F595B),
                            fontFamily: 'Eurostile',
                            fontSize: 28),
                        TextStyle(
                            color: Color(0xFF000000),
                            fontFamily: 'Eurostile',
                            fontSize: 28),
                        100.0),
                    Flexible(
                        child: RefreshIndicator(
                            onRefresh: () async {
                              _startScan();
                            },
                            child: ListView(
                                padding: EdgeInsets.zero,
                                children: foundDevicesWidgets,
                                physics:
                                    const AlwaysScrollableScrollPhysics())))
                  ]),
              replacement: Center(
                  child: Column(children: [
                printClippedText(
                    'APPARATEN ZOEKEN',
                    TextStyle(
                        color: Color(0xFF0F595B),
                        fontFamily: 'Eurostile',
                        fontSize: 28),
                    TextStyle(
                        color: Color(0xFF000000),
                        fontFamily: 'Eurostile',
                        fontSize: 28),
                    100.0),
                Padding(
                  padding: EdgeInsets.all(36),
                  child: CircularProgressIndicator(),
                )
              ])))
        ]));
  }
}
