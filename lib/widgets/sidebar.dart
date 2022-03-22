import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends StatefulWidget {
  final Map<String, dynamic> pages;
  NavBar({required this.pages});

  final Map<String, bool>navbarVisibility = {};

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {


  List<Widget> _genWidgets(
    Map<String,dynamic> pages, 
    {
      int level=0,
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

          if (!widget.navbarVisibility.containsKey(widgetVisibilityKey)) {
            widget.navbarVisibility.addAll({widgetVisibilityKey: false});
          }

          widgets.add(
            Column(
              children: [
                ListTile(
                  trailing: Icon(widget.navbarVisibility[widgetVisibilityKey] == true ? Icons.arrow_drop_up: Icons.arrow_drop_down),
                  title: Padding(
                    padding: EdgeInsets.only(left: 18.0*level),
                    child: Text(
                      key,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                        widget.navbarVisibility[widgetVisibilityKey] = !(widget.navbarVisibility[widgetVisibilityKey] ?? true);
                           
                    });
                  },
                ),
                Visibility(
                  visible: widget.navbarVisibility[widgetVisibilityKey] == true ,
                  child: Column(
                    
                    children: _genWidgets(
                      children, 
                      level: level+1, 
                      routePrefix: childPrefix,
                    ),
                  ),
                ),
              ],
            ),
          );

        }

        if(pages[key]!.containsKey('route')) {
          // print('has route: ' + key);
          String route = routePrefix + key.replaceAll(RegExp('\\s+'), '_').toLowerCase();
          widgets.add(
            ListTile(
              title: Padding(
                padding: EdgeInsets.only(left: 18.0*level),
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
          DrawerHeader(child: SvgPicture.asset('assets/images/groningerMuseumLogo.svg')),
          ..._genWidgets(widget.pages)]
      )

    );
  }
}

