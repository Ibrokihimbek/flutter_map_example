class GetCompanyLogoResponse {
  GetCompanyLogoResponse({
    this.count,
    this.results,
  });

  GetCompanyLogoResponse.fromJson(Map json) {
    count = json['count'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
  }

  num? count;
  List<Results>? results;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Results {
  Results({
    this.id,
    this.logo,
    this.latitude,
    this.longitude,
  });

  Results.fromJson(Map json) {
    id = json['id'];
    logo = json['logo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  String? id;
  String? logo;
  double? latitude;
  double? longitude;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['logo'] = logo;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    return map;
  }
}
