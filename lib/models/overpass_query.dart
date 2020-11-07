class OverpassQuery {
  String output;
  int timeout;
  List<SetElement> elements;

  OverpassQuery({
    this.output,
    this.timeout,
    this.elements
  });

  Map<String, String> toMap() {
    String elementsString = '';

    for (SetElement element in elements) {
      elementsString += '$element;';
    }

    String data = '[out:$output][timeout:$timeout];($elementsString);out;';

    return <String, String> {
      'data': data
    };
  }
}

class SetElement {
  final Map<String, String> tags;
  final LocationArea area;

  SetElement({
    this.tags,
    this.area
  });

  @override
  String toString() {
    String tagString = '';

    tags.forEach((key, value) {
      tagString += '["$key"="$value"]';
    });

    String areaString = '(around:${area.radius},${area.latitude},${area.longitude})';

    return 'node$tagString$areaString';
  }
}

class LocationArea {
  final double longitude;
  final double latitude;
  final double radius;

  LocationArea({
    this.longitude,
    this.latitude,
    this.radius
  });
}

class ResponseLocation {
  double longitude;
  double latitude;
  String name;
  String city;
  String street;

  ResponseLocation({
    this.longitude,
    this.latitude,
    this.name,
    this.city,
    this.street,
  });

  ResponseLocation.fromJson(Map<dynamic, dynamic> json) {
    this.longitude = json['lon'];
    this.latitude = json['lat'];

    Map<String, dynamic> tags = json['tags'];

    if (tags == null) {
      return;
    }

    this.name = json['tags']['name'];
    this.city = json['tags']['addr:city'];
    this.street = json['tags']['addr:street'];
  }
}

class QueryLocation {
  final double longitude;
  final double latitude;

  QueryLocation({
    this.longitude,
    this.latitude,
  });
}