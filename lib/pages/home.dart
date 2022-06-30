import 'dart:developer';

import 'package:app/helpers/globals.dart';
import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';
import 'package:app/libs/theme.dart';
import 'package:app/pages/EditRoute.dart';
import 'package:app/pages/newRoute.dart';
import 'package:flutter/material.dart' hide Theme, Route;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ColorTheme theme;
  List<Route>? routes;

  @override
  void initState() {
    super.initState();

    theme = Theme.dark;
    getAllRoutes();
  }

  getAllRoutes([String path = '/']) {
    get(Uri.http(serverUrl, path)).then((res) {
      if (res.statusCode == 200) {
        setState(() {
          routes = Route.routeListFromString(res.body);
        });
      }
    });
  }

  ListTile buildRouteItem(Route route) {
    return ListTile(
      textColor: theme.text,
      iconColor: theme.text,
      title: Text(route.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditRoute(route)));
            },
            icon: Icon(
              Icons.edit,
            ),
          ),
          IconButton(
            onPressed: () {
              deleteRoute(route.name);
              log('[DEBUG] : DELETE ROUTE');
            },
            icon: Icon(Icons.delete_forever),
          ),
        ],
      ),
    );
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewRoute()));
        },
        label: Text('Nieuwe route'),
        icon: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 20, 0, 0),
            child: Text(
              'Huidige routes',
              style: TextStyle(color: theme.text, fontSize: 24),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                getAllRoutes();
              },
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: (routes ?? []).length,
                itemBuilder: (context, index) {
                  return buildRouteItem(routes![index]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void deleteRoute(String name, [String path = '/delete']) {
    Map<String, dynamic> body = Map();

    body['name'] = name;

    post(Uri.http(serverUrl, path), body: body).then((res) {
      if (res.statusCode == 410) {
        getAllRoutes();
      }
    });
  }
}
