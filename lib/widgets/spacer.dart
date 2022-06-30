import 'package:flutter/cupertino.dart';

class Spacer extends StatelessWidget {
  final double size;

  const Spacer(this.size, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
    );
  }
}
