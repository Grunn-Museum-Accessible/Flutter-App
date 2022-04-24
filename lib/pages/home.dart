import 'package:app/pages/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = false;
  Set<ScanResult> foundDevices = Set();
  List<Widget> foundDevicesWidgets = [];

  void _startScan() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    await flutterBlue.stopScan();
    await flutterBlue.startScan(timeout: Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) {
      print(results);
      foundDevicesWidgets.clear();
      setState(() {
        foundDevicesWidgets = _buildConnectedDevices(results);
        isScanning = false;
      });
    });

    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: SvgPicture.asset('assets/images/groningerMuseumLogo.svg'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  isScanning = true;
                });
                _startScan();
              },
              child: Text(
                'Start Scanning',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Visibility(
              visible: !isScanning,
              child: SizedBox(
                height: 500.0,
                child: ListView(
                  children: foundDevicesWidgets,
                ),
              ),
              replacement: Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // if (isScanning && foundDevicesWidgets.isEmpty)
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConnectedDevices(List<ScanResult> devices) {
    List<Widget> widgets = [];

    devices.forEach((d) {
      widgets.add(ListTile(
        title: Text(d.device.name),
        subtitle: Text(d.device.id.toString()),
        trailing: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConnectedDeviceScreen(device: d.device),
              ),
            );
          },
          child: Text(
            'Connect',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ));
    });
    print(widgets);
    return widgets;
  }
}
