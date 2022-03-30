import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget to crate a auto generated sidebar
///
/// this widget creates a sidebar for naviagtion with indented levels based on
/// the object passed in the pages variable
class Sidebar extends StatefulWidget {
  final Map<String, dynamic> pages;
  Sidebar({required this.pages});

  /// var for kepping track which sublinks are shown
  final Map<String, bool> _navbarVisibility = {};

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  /// genereer de sidebar
  List<Widget> _genWidgets(
    Map<String, dynamic> pages, {
    int level = 0,
    String routePrefix = '/',
  }) {
    // start of function
    List<Widget> widgets = [];

    pages.forEach((key, value) {
      if (pages[key]!.containsKey('hide')) {
        // add the key hide to routes object to hide them from the sidebar
        if (pages[key]!['hide']) {
          return;
        }
      }

      if (pages[key]!.containsKey('children')) {
        dynamic children = pages[key]!['children'];
        String childPrefix = routePrefix;
        childPrefix += '${key.replaceAll(RegExp('\\s+'), '_').toLowerCase()}/';

        String widgetVisibilityKey = childPrefix.replaceAll(RegExp('/'), '_');

        if (!widget._navbarVisibility.containsKey(widgetVisibilityKey)) {
          widget._navbarVisibility.addAll({widgetVisibilityKey: false});
        }

        Widget listTile = ListTile(
          trailing: IconButton(
            onPressed: () {
              setState(() {
                widget._navbarVisibility[widgetVisibilityKey] =
                    !(widget._navbarVisibility[widgetVisibilityKey] ?? true);
              });
            },
            icon: Icon(widget._navbarVisibility[widgetVisibilityKey] == true
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down),
          ),
          title: Padding(
            padding: EdgeInsets.only(left: 18.0 * level),
            child: Text(
              key,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          onTap: () {
            if (pages[key]!.containsKey('route')) {
              String route = routePrefix +
                  key.replaceAll(RegExp('\\s+'), '_').toLowerCase();
              Navigator.pushNamed(context, route);
            } else {
              setState(() {
                widget._navbarVisibility[widgetVisibilityKey] =
                    !(widget._navbarVisibility[widgetVisibilityKey] ?? true);
              });
            }
          },
        );

        widgets.add(
          Column(
            children: [
              listTile,
              Visibility(
                visible: widget._navbarVisibility[widgetVisibilityKey] == true,
                child: Column(
                  children: _genWidgets(
                    children,
                    level: level + 1,
                    routePrefix: childPrefix,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      if (pages[key]!.containsKey('route')) {
        // print('has route: ' + key);
        String route =
            routePrefix + key.replaceAll(RegExp('\\s+'), '_').toLowerCase();
        widgets.add(
          ListTile(
            title: Padding(
              padding: EdgeInsets.only(left: 18.0 * level),
              child: Text(
                key,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, route);
            },
          ),
        );
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              child: SvgPicture.asset('assets/images/groningerMuseumLogo.svg')),
          ..._genWidgets(widget.pages)
        ],
      ),
    );
  }
}
