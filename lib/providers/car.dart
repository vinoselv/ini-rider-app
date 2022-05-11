import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riderapp/models/place.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/models/user.dart';
import 'package:riderapp/providers/ride_request_metadata.dart';
import 'package:http/http.dart' as http;

class Car with ChangeNotifier {
  String id;
  final String make;
  final String model;
  final int year;
  final String registrationNumber;
  final int thingy91ImeiNumber;
  String ownerId;
  Place place;

  Car(
      {this.id,
      @required this.make,
      @required this.model,
      @required this.year,
      @required this.registrationNumber,
      @required this.thingy91ImeiNumber,
      this.ownerId,
      this.place}
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "make": make,
        "model": model,
        "year": year,
        "registrationNumber": registrationNumber,
        "thingy91ImeiNumber": thingy91ImeiNumber,
        "ownerId": ownerId,
        "place": place != null ? place.toJson() : null,
      }..removeWhere((key, value) => value == null);

  factory Car.fromJson(Map<String, dynamic> data) {
    return Car(
      id: data['id'],
      make: data['make'],
      model: data['model'],
      year: data['year'],
      registrationNumber: data['registrationNumber'],
      thingy91ImeiNumber: data['thingy91ImeiNumber'],
      ownerId: data['ownerId'],
      place: data['place'] != null ? Place.fromJson(data['place']) : null,
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

}
