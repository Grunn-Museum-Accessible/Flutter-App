import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:flutter/material.dart' hide Route;

class RoutePreview extends StatelessWidget {
  final Color routeColour;
  final Route route;

  const RoutePreview({
    Key? key,
    this.routeColour = Colors.white,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Point> routeBounds = route.bounds;
    if (routeBounds.isNotEmpty) {
      num routeW = routeBounds.last.x - routeBounds.first.x;
      num routeH = routeBounds.last.y - routeBounds.first.y;
      if (routeW > 0 && routeH > 0) {
        return AspectRatio(
          aspectRatio: routeW / routeH,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomPaint(
              painter: RoutePreviewPainter(
                route,
                routeColour,
                repaint: route.routePartNotifier,
              ),
            ),
          ),
        );
      }
    }
    return Text('Geen route gevonden', style: TextStyle(color: Colors.white));
  }
}

class RoutePreviewPainter extends CustomPainter {
  Route route;
  late List<Line> routeParts;
  Color color;

  late List<Point> routeCorners;

  RoutePreviewPainter(this.route, this.color, {required Listenable repaint})
      : super(repaint: repaint) {
    routeParts = route.parts;
    routeCorners = route.bounds;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (routeParts.isEmpty) {
      return;
    }
    Scaler xscaler =
        Scaler(0, routeCorners.last.x - routeCorners.first.x, 0, size.width);
    Scaler yscaler =
        Scaler(0, routeCorners.last.y - routeCorners.first.y, 0, size.height);

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // create the path
    Path path = Path()
      ..moveTo(
        yscaler.scale(routeParts.first.start.y - routeCorners.first.y),
        xscaler.scale(routeParts.first.start.x - routeCorners.first.x),
      );

    routeParts.forEach((element) {
      path.lineTo(
        xscaler.scale(element.end.x - routeCorners.first.x),
        yscaler.scale(element.end.y - routeCorners.first.y),
      );
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Scaler {
  num minN;
  num maxN;
  num max;
  num min;
  Scaler(this.minN, this.maxN, this.min, this.max);

  double scale(n) {
    return (((n - minN) / maxN) * (max - min)) + min;
  }

  static double staticScale(n, minN, maxN, min, max) {
    return (((n - minN) / maxN) * (max - min)) + min;
  }
}
