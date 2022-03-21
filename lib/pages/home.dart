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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        title: 
          Center(
            child: SvgPicture.asset(
              'assets/images/groningerMuseumLogo.svg',
              semanticsLabel: 'Logo groninger museum',
            ),
          ),

          
      ),
    );
  }
}