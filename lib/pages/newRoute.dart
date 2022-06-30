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

// ignore: must_be_immutable
class NewRoute extends StatefulWidget {
  Route route = Route(
    'Titel',
    'Omschrijving',
    'https://via.placeholder.com/480x270?text=Pas+thumbnail+aan',
    <Line>[],
  );

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
      floatingActionButton: Visibility(
        visible: widget.route.routePartNotifier.value.isNotEmpty &&
            name.length > 1 &&
            desc.length > 1 &&
            image != '',
        child: FloatingActionButton.extended(
          // color: Colors.blue,
          onPressed: () {
            updateServer();
          },
          label: const Text('Opslaan'),
          icon: const Icon(Icons.save),
        ),
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () async {
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

  updateServer([String path = '/create']) {
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
        "[" + widget.route.parts.map((e) => e.toJson()).join(',') + "]";
    widget.route.AudioFiles.forEach((element) {
      req.files.add(http.MultipartFile(
        'file',
        File(element).readAsBytes().asStream(),
        File(element).lengthSync(),
        filename: element,
      ));
    });

    req.send().then((http.StreamedResponse resS) async {
      var res = await http.Response.fromStream(resS);
      if (res.statusCode == 200) {
        setState(() {
          widget.route = Route.fromString(res.body.toString());
        });
      } else {
        log('[HTTP] errror updating route: ' +
            res.statusCode.toString() +
            ' | ' +
            res.body.toString());
      }
    });
  }
}
