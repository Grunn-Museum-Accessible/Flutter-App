// ignore_for_file: lines_longer_than_80_chars

import 'package:app/helpers/globals.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> generateRoutesMap(
    Map<String, Map<dynamic, dynamic>> pages,
    {String routePrefix = '/'}) {
  //start of function
  Map<String, Widget Function(BuildContext)> routesMap = {};

  pages.forEach((key, value) {
    if (pages[key]!.containsKey('route')) {
      if (pages[key]!['route'] != Null) {
        String routeKey = key.replaceAll(RegExp('\\s+'), '_').toLowerCase();
        routesMap.addAll({
          routePrefix + routeKey: (context) =>
              pages[key]!['route'](globalsPages)
        });
      }
    }

    if (pages[key]!.containsKey('children')) {
      String childPrefix = routePrefix;
      childPrefix += '${key.replaceAll(RegExp('\\s+'), '_').toLowerCase()}/';

      routesMap.addAll(
          generateRoutesMap(pages[key]!['children'], routePrefix: childPrefix));
    }
  });
  return routesMap;
}
