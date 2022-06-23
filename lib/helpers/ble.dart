import 'dart:async';

import 'package:app/libs/positioning/positioning.dart';
import 'package:app/pages/route.dart' show RouteScreen;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

/// function to simplify the setup of a BleDevice by creating and calling the
/// required functions
Future<BleDevice> connectToBleDevice(BluetoothDevice device) async {
  var completer = Completer<BleDevice>();
  BleDevice bleDev = BleDevice(device);
  bleDev.setupBleConnection().then((v) {
    completer.complete(bleDev);
  });
  return completer.future;
}

checkBlePerm() async {
  var status = await Permission.bluetooth.status;
  if (status.isDenied) {
    await Permission.bluetooth.request();
  }

  if (await Permission.bluetooth.status.isPermanentlyDenied) {
    openAppSettings();
  }
}

List<Widget> buildConnectedDevices(
    BuildContext context, List<ScanResult> devices, Route route) {
  ThemeData themeData = Theme.of(context);
  List<Widget> widgets = [];

  devices.forEach((d) => widgets.add(ListTile(
      title: Text(d.device.name, style: themeData.textTheme.headline6),
      subtitle:
          Text(d.device.id.toString(), style: themeData.textTheme.subtitle2),
      trailing: IconButton(
        icon: Icon(
          Icons.bluetooth_searching_rounded,
          color: Color(0xFF000000),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteScreen(device: d.device, route: route),
            ),
          );
        },
        tooltip: 'Verbind met ${d.device.name}',
      ))));

  return widgets;
}

void scanDevices(
    {required BuildContext context,
    required Route route,
    required FlutterBlue flutterBlue,
    required void Function(List<ScanResult> results) callback}) async {
  await Permission.bluetoothScan.request();
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.location.request();

  await flutterBlue.stopScan();

  flutterBlue.startScan(timeout: Duration(seconds: 5));
  flutterBlue.scanResults.listen((results) {
    if (results.length > 0) {
      callback(results);
    }
  });
}

class BleDevice {
  bool _setupComplete = false;
  Map<Guid, StreamSubscription<List<int>>> listeners = {};

  BluetoothDevice _device;
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _charactersitics = [];

  BleDevice(this._device);

  Future<void> setupBleConnection() {
    var completer = Completer<void>();
    // check if the device is already connected
    _connectDevice().then((_) {
      // get all the services of the device
      _getAllServices().then((servicesFound) {
        _services = servicesFound;
        _services.forEach((element) {
          _charactersitics.addAll(_getBleCharacteristics(element.uuid));
        });
        _setupComplete = true;
        completer.complete();
      });
    });
    return completer.future;
  }

  Future<void> deconstruct() async {
    _device.disconnect().then((_) {
      print('disconnected');
      listeners.forEach((key, value) {
        value.cancel();
      });
    });
  }

  Future<void> _connectDevice() async {
    List<BluetoothDevice> connectedDevices =
        await FlutterBlue.instance.connectedDevices;
    if (connectedDevices.contains(_device)) {
      return;
    }

    return _device.connect();
  }

  // private service methods
  Future<List<BluetoothService>> _getAllServices() {
    return _device.discoverServices();
  }

  BluetoothService _getService(Guid uuid) {
    var filteredservices = _services.where((element) => element.uuid == uuid);

    if (filteredservices.length > 0) throw ServiceNotFound();
    return filteredservices.first;
  }

  // private characteristic methods
  List<BluetoothCharacteristic> _getBleCharacteristics(Guid serviceUUID) {
    var filteredServices =
        _services.where((element) => element.uuid == serviceUUID);
    if (filteredServices.length <= 0) throw ServiceNotFound();

    return filteredServices.first.characteristics;
  }

  BluetoothCharacteristic _getBleChar(Guid serviceUUID) {
    var filteredchars =
        _charactersitics.where((element) => element.uuid == serviceUUID);
    if (filteredchars.length <= 0) throw CharacteristicNotFound();

    return filteredchars.first;
  }

  BluetoothCharacteristic getBluetoothCharacterstic(String uuid) {
    if (!_setupComplete) throw SetupNotCompleted();
    return _getBleChar(Guid(uuid));
  }

  Future<StreamSubscription<List<int>>> addListenerToCharacteristic(
      String uuid, void Function(List<int>) func) async {
    if (!_setupComplete) throw SetupNotCompleted();
    BluetoothCharacteristic char = _getBleChar(Guid(uuid));
    await char.setNotifyValue(true);
    var list = char.value.listen(func);
    listeners.putIfAbsent(Guid(uuid), () => list);

    return list;
  }

  StreamSubscription<List<int>> getCharactersticListener(String uuid) {
    var list = listeners[Guid(uuid)];
    if (list == null) throw ListenerNotFound();

    return list;
  }

  // value getters and setters
  Future<String> getCharacteristicVal(String uuid) async {
    if (!_setupComplete) throw SetupNotCompleted();
    BluetoothCharacteristic char = _getBleChar(Guid(uuid));

    List<int> res = await char.read();
    return String.fromCharCodes(res);
  }

  Future<void> setCharacteristicVal(String uuid, String value) async {
    if (!_setupComplete) throw SetupNotCompleted();
    BluetoothCharacteristic char = _getBleChar(Guid(uuid));

    return char.write(value.codeUnits);
  }

  /// get a single ble service
  ///
  /// if the service does not exist we throw an exception
  BluetoothService? getBluetoothService(String uuid) {
    if (!_setupComplete) throw SetupNotCompleted();
    return _getService(Guid(uuid));
  }
}

class ListenerNotFound implements Exception {
  String errMsg() => 'the requested listener was not found';
}

class ServiceNotFound implements Exception {
  String errMsg() => 'the requested service was not found';
}

class CharacteristicNotFound implements Exception {
  String errMsg() => 'the requested characteristic was not found';
}

class SetupNotCompleted implements Exception {
  String errMsg() =>
      'the setup is not completed. Call setupBleConnection() before calling methods';
}
