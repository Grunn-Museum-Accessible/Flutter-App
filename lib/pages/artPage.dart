import 'package:app/helpers/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArtPage extends StatefulWidget {
  final Map<String, dynamic> pages;
  final Map<String, String> kunstwerk;
  String buttonText = 'Play audio description';

  ArtPage({required this.pages, required this.kunstwerk, Key? key})
      : super(key: key) {
    if (kunstwerk.containsKey('audioFile')) {
      audioManager.addStream(kunstwerk['audioFile'] ?? '', false);
    }
  }

  @override
  State<ArtPage> createState() => _ArtPageState();
}

class _ArtPageState extends State<ArtPage> {
  bool playing = false;

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: SvgPicture.asset(
            'assets/images/groningerMuseumLogo.svg',
            semanticsLabel: 'Logo groninger museum',
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Image.asset(widget.kunstwerk['image'] ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kunstwerk['name'] ?? '',
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                  ),
                ),
                if (widget.kunstwerk.containsKey('audioFile'))
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xFF4536AA),
                      ),
                    ),
                    onPressed: () {
                      if (playing) {
                        audioManager
                            .stopStream(widget.kunstwerk['audioFile'] ?? '');
                      } else {
                        audioManager
                            .playStream(widget.kunstwerk['audioFile'] ?? '');
                      }

                      setState(() {
                        playing = !playing;
                        if (playing) {
                          widget.buttonText = 'Stop playing';
                        } else {
                          widget.buttonText = 'Play audio description';
                        }
                      });
                    },
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      widget.kunstwerk['kunstenaar'] ?? '',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.kunstwerk.containsKey('date'))
                      Text(
                        ', ' + (widget.kunstwerk['date'] ?? ''),
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                if (widget.kunstwerk.containsKey('desc'))
                  Text(
                    widget.kunstwerk['desc'] ?? '',
                    style: TextStyle(fontSize: 12.0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
