import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class SearchTypeService {
  List<SearchType> _cachedList;

  Future<List<SearchType>> getSearchTypes() async {
    if (_cachedList == null) {
      List<dynamic> json = await _getJsonFromFile('search_types');
      _cachedList = _jsonToSearchTypes(json);
    }

    return _cachedList;
  }

  Future<List<dynamic>> _getJsonFromFile(String fileName) async {
    String jsonString = await rootBundle.loadString('assets/$fileName.json');

    return jsonDecode(jsonString)['elements'];
  }

  List<SearchType> _jsonToSearchTypes(List<dynamic> json) {
    List<SearchType> searchTypes = [];

    for (var element in json) {
      searchTypes.add(
        SearchType.fromJson(element)
      );
    }

    return searchTypes;
  }
}

class SearchType {
  String singular;
  String plural;
  Map<String, String> tags;

  SearchType({
    this.singular,
    this.plural,
    this.tags
  });

  SearchType.fromJson(Map<dynamic, dynamic> json) {
    this.singular = json['name']['singular'];
    this.plural = json['name']['plural'];

    Map<String, String> tags = new Map();

    json['tags'].forEach((key, value) {
      tags[key] = value;
    });

    this.tags = tags;
  }
}