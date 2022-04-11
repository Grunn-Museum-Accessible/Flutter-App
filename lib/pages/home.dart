import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool paused = false;
  bool started = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: SvgPicture.asset('assets/images/groningerMuseumLogo.svg'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (started) Container(
                  child: buildButton(paused ? 'Hervatten' : 'Pauzeren', 0.30,
                    Colors.grey, () => setState(() => paused = !paused)),
                  margin: EdgeInsets.fromLTRB(0, 25, 10, 25),
                ),
                Container(
                  child: buildButton(
                    started ? 'Stop Route' : 'Start Route', 
                    started ? 0.50 : 0.85, 
                    started ? Colors.red : Colors.green,
                    () => setState(() {
                      started = !started;
                      paused = false;
                    }),
                  ),
                  margin: started 
                    ? EdgeInsets.fromLTRB(10, 25, 0, 25)
                    : EdgeInsets.all(25),
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              indent: 25,
              endIndent: 25,
            ),
            Container(
              child: buildButton('Terug naar start', 0.85, Colors.orange, () => setState(() {
                  started = true;
                  paused = false;
                }),
              ),
              margin: EdgeInsets.all(25),
            ),
          ],
        ),
      ),
    );
  }

  TextButton buildButton(
    String text, 
    double width,
    Color color,
    VoidCallback callback,
  ) {
    return TextButton(
      child: Text(text, textScaleFactor: 1.5),
      onPressed: callback,
      style: TextButton.styleFrom(
        minimumSize: Size(
          MediaQuery.of(context).size.width * width,
          MediaQuery.of(context).size.width * 0.30,
        ),
        backgroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
    );
  }
}
