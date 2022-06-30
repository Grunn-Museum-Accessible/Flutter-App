import 'dart:developer';
import 'dart:io';
import 'package:app/widgets/spacer.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart' hide Spacer, Route;
import 'package:flutter/services.dart';

class AddAudioPointDialog extends StatefulWidget {
  final void Function(String? audioFile, num? range) addRoute;
  AddAudioPointDialog({Key? key, required this.addRoute}) : super(key: key);

  @override
  State<AddAudioPointDialog> createState() => _AddAudioPointDialogState();
}

class _AddAudioPointDialogState extends State<AddAudioPointDialog> {
  String soundFilePath = '';
  num soundRange = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return AlertDialog();
    return AlertDialog(
      title: Text('Voeg audiobestand toe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Berijk in meters'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (str) {
              soundRange = num.tryParse(str) ?? 0;
            },
          ),
          Spacer(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // direction: Axis.horizontal,
            children: [
              Text(
                soundFilePath != ''
                    ? parseSoundFile()
                    : 'Geen bestand\ngeselecteerd',
              ),
              ElevatedButton(
                onPressed: () async {
                  String newImage = await FilesystemPicker.open(
                        title: 'Selecteer afbeelding ',
                        context: context,
                        rootDirectory: Directory('storage/emulated/0'),
                        fsType: FilesystemType.file,
                        allowedExtensions: ['.wav', '.mp3'],
                        fileTileSelectMode: FileTileSelectMode.wholeTile,
                      ) ??
                      '';
                  if (newImage != '') {
                    setState(() {
                      soundFilePath = newImage;
                    });
                  }
                },
                child: Text(
                  'Selecteer\naudiobestand',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('annuleer'),
        ),
        ElevatedButton(
          onPressed: () {
            log(soundFilePath);
            widget.addRoute(soundFilePath, soundRange);
            Navigator.of(context).pop();
          },
          child: Text('toevoegen'),
        ),
      ],
    );
  }

  String parseSoundFile([int maxchars = 17]) {
    String filePart = soundFilePath.split('/').last;

    if (filePart.length <= maxchars) {
      return filePart;
    }

    return filePart.substring(0, maxchars - 3) + '...';
  }
}
