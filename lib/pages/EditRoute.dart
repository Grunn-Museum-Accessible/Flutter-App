import 'dart:developer';

import 'package:app/helpers/globals.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/libs/theme.dart';
import 'package:flutter/material.dart' hide Theme, Route;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';

class EditRoute extends StatefulWidget {
  Route route;

  EditRoute(this.route, {Key? key}) : super(key: key);
  @override
  EditRouteState createState() => EditRouteState();
}

class EditRouteState extends State<EditRoute> {
  List<Route>? routes;

  @override
  void initState() {
    super.initState();
  }

  String name = "";
  String desc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.text,
        elevation: 0,
        title: Center(
          child: SvgPicture.asset(
            'assets/images/groningerMuseumLogo.svg',
            color: theme.text,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.route.name,
                  style: TextStyle(color: theme.text),
                  onChanged: (String val) {
                    setState(() {
                      name = val;
                    });
                  },
                ),

                TextFormField(
                  initialValue: widget.route.description,
                  style: TextStyle(color: theme.text),
                  maxLines: 12,
                  onChanged: (String val) {
                    setState(() {
                      desc = val;
                    });
                  },
                )
                // Text(widget.route.name)
              ],
            ),
          ),
          Visibility(
            visible: (widget.route.name != name) ||
                (widget.route.description != desc),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                // color: Colors.blue,
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.save),
                    ),
                    Text('opslaan'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
