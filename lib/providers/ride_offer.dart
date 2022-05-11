import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/models/place.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/models/user.dart';
import 'package:riderapp/providers/ride_request_metadata.dart';
import 'package:http/http.dart' as http;

class RideOffer with ChangeNotifier {
  String id;
  final Place from;
  final Place to;
  final DateTime rideStartTime;
  final int distance;
  final int duration;
  final User creator;
  final int passengersAllowed;
  int passengersAccepted;
  RideStatus rideStatus;
  List<RideRequestMetaData> rideRequests;

  RideOffer({
    this.id,
    @required this.from,
    @required this.to,
    @required this.rideStartTime,
    @required this.distance,
    @required this.duration,
    @required this.creator,
    @required this.passengersAllowed,
    this.passengersAccepted,
    this.rideStatus,
    this.rideRequests
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "from": from.toJson(),
    "to": to.toJson(),
    "rideStartTime": rideStartTime.toIso8601String(),
    "distance": distance,
    "duration": duration,
    "creator": creator.toJson()..removeWhere((key, value) => key == 'email'),
    "passengersAllowed": passengersAllowed,
    "passengersAccepted": passengersAccepted,
    "rideStatus": rideStatus == null ? null : rideStatus.toString(),
    "rideRequests": rideRequests
  }..removeWhere((key, value) => value == null);

  factory RideOffer.fromJson(Map<String, dynamic> data) {
    return RideOffer(
        id: data['id'],
        from: Place.fromJson(data['from']),
        to: Place.fromJson(data['to']),
        creator: User.fromJson(data['creator']),
        rideStartTime: DateTime.parse(data['rideStartTime']),
        distance: data['distance'],
        duration: data['duration'],
        passengersAllowed: data['passengersAllowed'],
        passengersAccepted: data['passengersAccepted'],
        rideStatus: RideStatus.values.firstWhere((e) => e.toString() == 'RideStatus.' + data['rideStatus']),
        //RideStatus.values.byName(data['rideStatus']),
        rideRequests: data["rideRequests"] == null ? null : List<RideRequestMetaData>.from(data["rideRequests"].map((x) => RideRequestMetaData.fromJson(x))),
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  bool get isCancellable {
    return rideStatus == RideStatus.ride_active;
  }

  bool get isNotCompleted {
    return rideStatus != RideStatus.ride_completed;
  }

  bool get isNotOnGoing {
    return rideStatus != RideStatus.ride_ongoing;
  }

  String get status {
    return rideStatus.toString().split('.')[1].split('_')[1];
  }

  IconData get statusIcon {
    switch (rideStatus) {
      case RideStatus.request_waiting:
        return Icons.hourglass_top;
        break;
      case RideStatus.request_accepted:
        return Icons.done_all;
        break;
      case RideStatus.request_rejected:
        return Icons.clear;
        break;
      case RideStatus.ride_completed:
        return Icons.favorite;
        break;
      case RideStatus.ride_active:
        return Icons.waving_hand;
        break;
      case RideStatus.ride_ongoing:
        return Icons.incomplete_circle;
        break;
      default:
        return Icons.star;
    }
  }

  Color get statusColor {
    switch (rideStatus) {
      case RideStatus.request_waiting:
        return Colors.amber;
        break;
      case RideStatus.request_accepted:
        return BrandColors.colorGreen;
        break;
      case RideStatus.request_rejected:
        return Colors.red;
        break;
      case RideStatus.ride_completed:
        return BrandColors.colorGreen;
        break;
      case RideStatus.ride_active:
        return BrandColors.colorGreen;
        break;
      case RideStatus.ride_ongoing:
        return BrandColors.colorGreen;
        break;
      default:
        return BrandColors.colorGreen;
    }
  }

}
