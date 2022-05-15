import 'dart:developer';

import 'package:app/pages/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = true;
  List<ScanResult> foundDevices = [];
  List<Widget> foundDevicesWidgets = [];

  void _startScan() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    await flutterBlue.stopScan();
    await flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      foundDevices = results;
      foundDevicesWidgets.clear();
      log("BLE scan completed");
      setState(() {
        foundDevicesWidgets = _buildConnectedDevices(results);
        isScanning = false;
      });
    });

    flutterBlue.stopScan();
  }

  @override
  void initState() {
    _startScan();
    NfcManager.instance.isAvailable().then(
      (bool isAvailable) {
        log("nfc checkable");

        if (isAvailable) {
          log('nfc available');
          // Start Session
          NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
              log("tag discovered");
              // print(tag.data);
              // Do something with an NfcTag instance.
              Ndef? ndef = Ndef.from(tag);
              if (ndef == null) return;

              NdefMessage msg = await ndef.read();
              msg.records.forEach((element) {
                String readValue = String.fromCharCodes(element.payload)
                    .substring(3)
                    .toUpperCase();

                log(readValue);

                foundDevices.forEach((dev) {
                  if (dev.device.id.toString() == readValue) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectedDeviceScreen(
                          device: dev.device,
                        ),
                      ),
                    );
                  }
                });
              });
            },
          );
        }
      },
    );
    super.initState();
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
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Scan the device to connect or click on connect',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          Visibility(
            visible: !isScanning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                  child: Text('found devices',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 500.0,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _startScan();
                    },
                    child: ListView(
                      children: foundDevicesWidgets,
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              ],
            ),
            replacement: Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Searching for devices',
                      style: TextStyle(fontSize: 32),
                    ),
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    // print(widgets);
    return widgets;
  }
}
