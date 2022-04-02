import 'package:app/helpers/globals.dart';
import 'package:app/pages/artPage.dart';
import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaintingsListPage extends StatelessWidget {
  final Map<String, dynamic> pages;
  const PaintingsListPage({required this.pages, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(pages: pages),
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
      body: Center(
        child: Column(
          children: [
            TextButton(
              child: Text(
                'Dans om vrijgeidsboom',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ArtPage(
                          pages: pages,
                          kunstwerk: ArtPieces['dans_om_vrijheidsboom'] ??
                              <String, String>{});
                    },
                  ),
                );
              },
            ),
            TextButton(
              child: Text(
                'landschap met paard',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ArtPage(
                          pages: pages,
                          kunstwerk: ArtPieces['landschap_met_paard'] ??
                              <String, String>{});
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
