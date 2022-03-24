import 'package:app/helpers/globals.dart';
import 'package:app/widgets/audioplayer.dart';
import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AudioManagerTestScreen extends StatelessWidget {
  final Map<String, dynamic> pages;

  const AudioManagerTestScreen({
    required this.pages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(pages: pages),
      body: Center(
        child: Column(
          children: [
            AudioController(
                audioSource: 'long_audio.mp3',
                lowerVolume: true,
                child: Text('long music with lower volume',
                    style: TextStyle(color: Colors.black))),
            AudioController(
                audioSource: 'medium_audio.wav',
                child: Text('medium music with no lower volume',
                    style: TextStyle(color: Colors.black))),
            AudioController(
                audioSource: 'short_audio.mp3',
                lowerVolume: true,
                child: Text('short music with lower volume',
                    style: TextStyle(color: Colors.black))),
            TextButton(
                onPressed: audioManager.stopAllStreams,
                child: Text('stop all', style: TextStyle(color: Colors.black)))
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Center(
          child: SvgPicture.asset(
            'assets/images/groningerMuseumLogo.svg',
            semanticsLabel: 'Logo groninger museum',
          ),
        ),
      ),
    );
  }
}
