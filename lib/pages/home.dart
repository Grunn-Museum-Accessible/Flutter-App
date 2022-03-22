import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> pages;

  const HomeScreen({
    required this.pages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(),
        appBar: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                print(_scaffoldKey.currentState!.hasDrawer);
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          title: Center(
            child: SvgPicture.asset(
              'assets/images/groningerMuseumLogo.svg',
              semanticsLabel: 'Logo groninger museum',
            ),
          ),
        ),
        body: Center(
            child: Text(
          ModalRoute.of(context)?.settings.name ?? 'unkown route',
        )));
  }
}
