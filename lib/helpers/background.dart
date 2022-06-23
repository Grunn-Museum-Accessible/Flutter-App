import 'package:flutter/material.dart';

Stack printClippedText(
  String text,
  TextStyle styleFront,
  TextStyle styleBack,
  double offset
) {
  return Stack(
    children: [
      /**
       * Only allow semantics once.
       */
      ExcludeSemantics(
        child: ClipPath(
          clipper: Clipper(inverted: false),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(height: offset),
                Text(text, style: styleFront, textAlign: TextAlign.center)
              ]
            )
          )
        ) 
      ),
      ClipPath(
        clipper: Clipper(inverted: true),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: offset),
              Text(text, style: styleBack, textAlign: TextAlign.center)
            ]
          )
        )
      )
    ],
  );
}

class Clipper extends CustomClipper<Path> {
  final bool inverted;
  const Clipper({
    required this.inverted
  });

  @override
  Path getClip(Size size) {
    if (inverted) {
      return getOuterPath(size);
    }

    return getPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

/**
 * BACKGROUND
 */
Path getPath(Size size) {
  return Path()
    ..moveTo(0, 150)
    ..lineTo(0, 150)
    ..quadraticBezierTo(
      size.width / 4,
      50,
      size.width,
      150
    )
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

Path getOuterPath(Size size) {
  return Path()
    ..lineTo(0, 150)
    ..quadraticBezierTo(
      size.width / 4,
      50,
      size.width,
      150
    )
    ..lineTo(size.width, 0)
    ..close();
}

class Header extends StatelessWidget {
  final Size size;

  const Header({
    Key? key,
    required this.size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Color(0xFFF4CC2D),
        shape: CustomShape(size: size)
      )
    );
  }
}

class CustomShape extends ShapeBorder {
  final Size size;

  const CustomShape({
    required this.size
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => null!;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getPath(size);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
