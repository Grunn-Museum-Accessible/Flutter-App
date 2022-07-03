import 'package:app/helpers/globals.dart';
import 'package:app/helpers/restApi.dart';
import 'package:app/libs/positioning/positioning.dart';
import 'package:app/pages/nfc.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_svg/flutter_svg.dart';

/**
 * Coords
 * [60, 75],
 * [60, 185],
 * [135, 315],
 * [300, 315],
 * [300, 460],
 * [190, 600],
 * [60, 600]
 */

// Route testRoute = Route(
//     name: 'JR Chronicles',
//     description:
//         'Ontdek de iconische projecten van de internationale bekende franse kunstenaar JR',
//     thumbnail:
//         'https://www.groningermuseum.nl/media/2/Tentoonstellingen/2021/JR/_1200x670_crop_center-center_95_none/JR.-GIANTS-Kikito-and-the-Border-Patrol-Tecate-Mexico-U.S.A.-2017.jpg',
//     parts: [
//       Line(
//           Point(60, 75),
//           Point(60, 185,
//               soundRange: 30,
//               soundFile: '/storage/emulated/0/Download/jr-1.mp3'),
//           50),
//       Line(
//           Point(60, 185,
//               soundRange: 30,
//               soundFile: '/storage/emulated/0/Download/jr-1.mp3'),
//           Point(135, 315),
//           30),
//       Line(Point(135, 315), Point(300, 315), 30),
//       Line(
//           Point(300, 315),
//           Point(300, 460,
//               soundRange: 30,
//               soundFile: '/storage/emulated/0/Download/jr-2.mp3'),
//           40),
//       Line(
//           Point(300, 460,
//               soundRange: 30,
//               soundFile: '/storage/emulated/0/Download/jr-2.mp3'),
//           Point(190, 600),
//           40),
//       Line(Point(190, 600), Point(60, 600), 30)
//     ]);

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);

    return FutureBuilder<List<Route>>(
        builder: (context, snapshot) {
          return Scaffold(
              body: Column(children: [
            Header(size: size),
            Padding(
                padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                child: Column(children: [
                  Text(
                    'Huidige Routes',
                    style: themeData.textTheme.headline1,
                    textAlign: TextAlign.center,
                  )
                ])),
            // Routes([testRoute], () async {
            //   setState(() {});
            // })
            Routes(snapshot.data ?? [], () async {
              setState(() {});
            })
          ]));
        },
        future: restAPI.getAll());
  }
}

class Routes extends StatelessWidget {
  final List<Route> routes;
  final Future<void> Function() refresh;

  const Routes(this.routes, this.refresh);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Flexible(
        child: RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            String description = (routes[index].description ?? '').trim();

            return SizedBox(
              height: 99,
              child: ListTile(
                  visualDensity: VisualDensity(vertical: 4.0),
                  minVerticalPadding: 25,
                  leading: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Image.network(
                          RestClient.baseUrl + routes[index].thumbnail)),
                  title: Text(routes[index].name,
                      style: themeData.textTheme.headline6),
                  subtitle: routes[index].description != ''
                      ? Text(
                          description,
                          style: themeData.textTheme.subtitle2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        )
                      : null,
                  isThreeLine: false,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NFCScreen(route: routes[index])));
                  }),
            );
          },
          padding: EdgeInsets.zero),
    ));
  }
}

class Header extends StatelessWidget {
  final Size size;

  const Header({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: ShapeDecoration(
            color: Color(0xFFF4CC2D), shape: CustomShape(size: size)),
        height: size.height * 0.23,
        child: Center(
            child: Container(
                child: SvgPicture.asset('assets/images/groningerMuseumLogo.svg',
                    color: Color(0xFF0F595B), width: size.width * 0.8))));
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
    double height = size.height * 0.23;
    return Path()
      ..lineTo(0, height - 50)
      ..quadraticBezierTo(size.width / 4, height + 50, size.width, height - 50)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
