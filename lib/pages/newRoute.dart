import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/helpers/globals.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/pages/nfc.dart';
import 'package:app/widgets/spacer.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart' hide Theme, Route, Spacer;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class NewRoute extends StatefulWidget {
  Route route = Route(
      'JR Chronicles',
      'Ontdek de iconische projecten van de internationale bekende franse kunstenaar JR',
      'https://www.groningermuseum.nl/media/2/Tentoonstellingen/2021/JR/_1200x670_crop_center-center_95_none/JR.-GIANTS-Kikito-and-the-Border-Patrol-Tecate-Mexico-U.S.A.-2017.jpg',
      [
        Line(
            Point(60, 75),
            Point(60, 185,
                soundRange: 30,
                soundFile: '/storage/emulated/0/Download/jr-1.mp3'),
            50),
        Line(
            Point(60, 185,
                soundRange: 30,
                soundFile: '/storage/emulated/0/Download/jr-1.mp3'),
            Point(135, 315),
            30),
        Line(Point(135, 315), Point(300, 315), 30),
        Line(
            Point(300, 315),
            Point(300, 460,
                soundRange: 30,
                soundFile: '/storage/emulated/0/Download/jr-2.mp3'),
            40),
        Line(
            Point(300, 460,
                soundRange: 30,
                soundFile: '/storage/emulated/0/Download/jr-2.mp3'),
            Point(190, 600),
            40),
        Line(Point(190, 600), Point(60, 600), 30)
      ]);

  NewRoute({Key? key}) : super(key: key);
  @override
  NewRouteState createState() => NewRouteState();
}

class NewRouteState extends State<NewRoute> {
  List<Route>? routes;

  @override
  void initState() {
    super.initState();
    name = widget.route.name;
    desc = widget.route.description;
    createNewRedraw = redraw;
  }

  String name = '';
  String desc = '';
  String image = '';

  int stateChange = 0;
  void redraw() {
    setState(() {
      stateChange++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.text,
        elevation: 0,
        title: Center(
          child: SvgPicture.asset(
            'assets/images/groningerMuseumLogo.svg',
            color: theme.text,
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return Visibility(
            visible: widget.route.routePartNotifier.value.isNotEmpty &&
                name.length > 1 &&
                desc.length > 1 &&
                true,
            // image != '',
            child: FloatingActionButton.extended(
              // color: Colors.blue,
              onPressed: () {
                updateServer(context);
              },
              label: const Text('Opslaan'),
              icon: const Icon(Icons.save),
            ),
          );
        },
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () async {
              if (await Permission.storage.request().isGranted) {
                String newImage = await FilesystemPicker.open(
                      title: 'Selecteer afbeelding ',
                      context: context,
                      rootDirectory: Directory('storage/emulated/0'),
                      fsType: FilesystemType.file,
                      allowedExtensions: ['.jpg', '.jpeg', '.gif', '.png'],
                      fileTileSelectMode: FileTileSelectMode.wholeTile,
                    ) ??
                    '';

                if (newImage != '') {
                  setState(() {
                    image = newImage;
                  });
                }
              }
            },
            child: Stack(
              children: [
                image != ''
                    ? Image.file(File(image))
                    : Image.network((widget.route.image.startsWith('/')
                            ? 'http://' + serverUrl
                            : '') +
                        widget.route.image),
                Positioned(
                  right: 8,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TextFormField(
                      initialValue: widget.route.name,
                      style: TextStyle(color: theme.text),
                      onChanged: (String val) {
                        setState(() {
                          name = val;
                        });
                      },
                    ),
                    Positioned(
                      right: 8,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    TextFormField(
                      initialValue: widget.route.description,
                      style: TextStyle(color: theme.text),
                      maxLines: 12,
                      onChanged: (String val) {
                        setState(() {
                          desc = val;
                        });
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 8,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NFCScreen(route: widget.route)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Huidige route',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: widget
                                  .route.routePartNotifier.value.isNotEmpty,
                              child: Positioned(
                                right: 8,
                                child: IgnorePointer(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible:
                              widget.route.routePartNotifier.value.isNotEmpty,
                          child: RoutePreview(route: widget.route),
                          replacement: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Spacer(20),
                              Text(
                                'Klik hier om route aan te maken.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  updateServer(BuildContext context, [String path = '/create']) {
    http.MultipartRequest req =
        http.MultipartRequest('POST', Uri.http(serverUrl, path));

    req.fields['name'] = name;
    req.fields['description'] = desc;

    // add thumbnail
    if (image != '') {
      req.files.add(
        http.MultipartFile(
          'file',
          File(image).readAsBytes().asStream(),
          File(image).lengthSync(),
          filename: image.split('/').last,
        ),
      );
    }

    req.fields['parts'] =
        '[' + widget.route.parts.map((e) => e.toJson()).join(',') + ']';
    widget.route.audioFiles.forEach((element) {
      req.files.add(http.MultipartFile(
        'file',
        File(element).readAsBytes().asStream(),
        File(element).lengthSync(),
        filename: element,
      ));
    });

    req.send().then((http.StreamedResponse resS) async {
      //TODO: show errors and completion
      var res = await http.Response.fromStream(resS);

      String usermsg = '';

      log('[HTTP] errror updating route: ' +
          res.statusCode.toString() +
          ' | ' +
          res.body.toString());

      if (res.statusCode == 201) {
        setState(() {
          widget.route = Route.fromString(res.body.toString());
        });
        usermsg = 'De route is succesfol aangemaakt';
      } else {
        log('[HTTP] errror updating route: ' +
            res.statusCode.toString() +
            ' | ' +
            res.body.toString());
        if (res.statusCode == 400) {
          switch (jsonDecode(res.body.toString())['message']) {
            case 'No route name given':
              usermsg = 'ER is geen titel ingevoerd';
              break;
            case 'Route name already in use':
              usermsg = 'Een route met deze naam bestaat al';
              break;
            case 'No file selected for uploading':
              usermsg = 'ir is geen afbeelding toegevoegd aan de route';
              break;
            default:
              usermsg = 'er is iets fout gegaan. probeer later opnieuw';
          }
        }
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(usermsg)));
    });
  }
}
