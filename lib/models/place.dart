import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Place {
  static DateFormat format = new DateFormat("yyyy.MM.dd HH:mm:ss.SSS z");

  String name;
  double latitude;
  double longitude;
  String id;
  String address;
  DateTime lastReportedTime;

  Place({
    this.id,
    this.latitude,
    this.longitude,
    this.name,
    this.address,
    this.lastReportedTime
  });

  String get displayName {
    if(name == address) {
      return name;
    }
    return name + ', ' + address;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "lastReportedTime": lastReportedTime != null ? lastReportedTime.toIso8601String() : null
      };

  factory Place.fromJson(Map<String, dynamic> data) {
    return Place(
      id: data['id'],
      name: data['name'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      address: data['address'],
      lastReportedTime: data['lastReportedTime'] != null ? format.parse(data['lastReportedTime']) : null,
    );
  }
}
