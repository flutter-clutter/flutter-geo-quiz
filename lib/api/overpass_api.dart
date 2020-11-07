import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:http/http.dart';

import '../models/overpass_query.dart';


class OverpassApi {
  static String _apiUrl = 'overpass-api.de';
  static String _path = '/api/interpreter';

  Future<List<ResponseLocation>> fetchLocationsAroundCenter(QueryLocation center, Map<String, String> filter, double radius) async {
    Request request = Request('GET', Uri.https(_apiUrl, _path));
    request.bodyFields = _buildRequestBody(center, filter, radius);

    String responseText;

    try {
      StreamedResponse response = await Client()
          .send(request)
          .timeout(const Duration(seconds: 5));

      responseText = await response.stream.bytesToString();
    }
    catch (exception) {
      print(exception);
      return Future.error(exception);
    }

    var responseJson;

    try {
      responseJson = jsonDecode(responseText);
    }
    catch (exception) {
      String error = '';
      final document = XmlDocument.parse(responseText);
      final paragraphs = document.findAllElements("p");

      paragraphs.forEach((element) {
        if (element.text.trim() == '') {
          return;
        }

        error += '${element.text.trim()}';
      });

      return Future.error(error);
    }

    if (responseJson['elements'] == null) {
      return [];
    }

    List<ResponseLocation> resultList = [];

    for (var location in responseJson['elements']) {
      resultList.add(ResponseLocation.fromJson(location));
    }

    return resultList;
  }

  Map<String, String> _buildRequestBody(QueryLocation center, Map<String, String> filter, double radius) {
    OverpassQuery query = new OverpassQuery(
      output: 'json',
      timeout: 25,
      elements: [
        SetElement(
          tags: filter,
          area: LocationArea(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: radius
          )
        )
      ],
    );

    return query.toMap();
  }
}