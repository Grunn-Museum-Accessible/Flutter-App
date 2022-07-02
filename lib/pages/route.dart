import 'package:app/helpers/globals.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:app/pages/positioning.dart';
import 'package:app/libs/positioning/positioning.dart';
import 'package:flutter_blue/flutter_blue.dart';

class RouteScreen extends StatefulWidget {
  final BluetoothDevice device;
  final Route route;

  RouteScreen({Key? key, required this.device, required this.route})
      : super(key: key);

  @override
  RouteScreenState createState() => RouteScreenState();
}

class RouteScreenState extends State<RouteScreen> {
  bool started = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    String description =
        widget.route.description ?? 'No description available...';

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
        body: Stack(children: [
          Image.network(makeValidIMageUrl(widget.route.thumbnail),
              height: 300, fit: BoxFit.cover),
          Header(size: size),
          Align(
              alignment: Alignment.center,
              child: Column(children: [
                SizedBox(height: 300.0),
                Text(
                  widget.route.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Eurostile',
                      fontSize: 22),
                ),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      description,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ))
              ])),
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: TextButton.icon(
                    label: Text(started ? 'STOP' : 'START',
                        style: themeData.textTheme.headline2),
                    icon: Icon(
                      started ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 50.0,
                      color: Colors.black,
                    ),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => setState(() {
                          // started = !started;
                          // if (started) {
                          //   Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => PositioningScreen(
                          //       device: widget.device,
                          //       route: widget.route
                          //     ))
                          //   );
                          // }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PositioningScreen(
                                      device: widget.device,
                                      route: widget.route)));
                        })),
              ))
        ]));
  }
}

class Header extends StatelessWidget {
  final Size size;

  const Header({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: ShapeDecoration(
            color: Color(0xFF9747FF), shape: CustomShape(size: size)));
  }
}

class CustomShape extends ShapeBorder {
  final Size size;

  const CustomShape({required this.size});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => null!;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(0, 300)
      ..lineTo(0, 300)
      ..quadraticBezierTo(size.width / 4, 200, size.width, 300)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
