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
      drawer: NavBar(pages: pages),
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: 
          Center(
            child: SvgPicture.asset(
              'assets/images/groningerMuseumLogo.svg',
              semanticsLabel: 'Logo groninger museum',
            ),
          ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('current: homeRoute'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              }, 
              child: Text(
                'home page', 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/routes_beheren/nieuwe_maken');
              }, 
              child: Text(
                'nieuwe maken', 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/routes_beheren/route_bewerken');
              }, 
              child: Text(
                'Route Bewerken', 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            
          ],
        ) 
      ),
    );
  }
}
