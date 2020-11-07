import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_geo_guesser/services/search_type_service.dart';

import '../api/overpass_api.dart';
import '../models/overpass_query.dart';


class GeoService {
  GeoService({
    @required this.overpassApi,
    this.fileName = 'cities_de'
  }): assert(overpassApi != null);

  final OverpassApi overpassApi;
  final String fileName;

  List<Location> _cachedList;

  Future<List<Location>> getLocations() async {
    if (_cachedList == null) {
      Map<dynamic, dynamic> json = await _getJsonFromFile(fileName);
      _cachedList = _jsonToLocations(json);
    }

    return _cachedList;
  }

  Future<List<Location>> getEntitiesInArea({
    Location center, SearchType type, double radiusInMetres = 5000
  }) async {
    List<ResponseLocation> fetchResult = await this.overpassApi.fetchLocationsAroundCenter(
      QueryLocation(
        longitude: center.longitude,
        latitude: center.latitude
      ),
      type.tags,
      radiusInMetres
    );

    List<Location> result = [];

    fetchResult.forEach((element) {
      result.add(
        Location(
          longitude: element.longitude,
          latitude: element.latitude,
          name: element.name
        )
      );
    });

    return result;
  }

  Future<Map<dynamic, dynamic>> _getJsonFromFile(String fileName) async {
    String jsonString = await rootBundle.loadString('assets/locations/$fileName.json');

    return jsonDecode(jsonString);
  }

  List<Location> _jsonToLocations(Map<dynamic, dynamic> json) {
    List<Location> locations = [];

    // TODO: Or validate here? Or both?

    for (var element in json["elements"]) {
      locations.add(
        Location.fromJson(element)
      );
    }

    return locations;
  }
}

class Location {
  final double longitude;
  final double latitude;
  final String name;

  Location({
    this.longitude,
    this.latitude,
    this.name,
  });

  Location.fromJson(Map<dynamic, dynamic> json) :
    longitude = json['lon'],
    latitude = json['lat'],
    name = json['tags']['name'];
}