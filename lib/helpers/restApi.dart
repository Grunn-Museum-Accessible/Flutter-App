import 'dart:convert';

import 'package:app/libs/positioning/positioning.dart';
import 'package:http/http.dart' as http;

class RestClient {
  static String baseUrl = 'http://192.168.1.53/';

  Future<List<Route>> getAll() async {
    Uri url = Uri.parse(baseUrl);
    var response = await http.get(url);
    var decoded = jsonDecode(response.body);

    return List<Route>.from(
      decoded
          .map<Route?>(
            (item) => Route.fromString(
              jsonEncode(item),
            ),
          )
          .toList()
          .where((elem) => elem != null),
    ).toList();
  }

  Future<Route> getOne(String name) async {
    Uri url = Uri.parse(baseUrl + '/one');
    var response = await http.post(url, body: jsonEncode({name}));
    var decoded = jsonDecode(response.body);

    return Route.fromList(
        name: decoded['name'],
        description: decoded['description'],
        thumbnail: decoded['image'],
        list: decoded['parts']);
  }
}