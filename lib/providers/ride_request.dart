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

class RideRequest with ChangeNotifier {
  String id;
  final Place from;
  final Place to;
  final DateTime rideRequestTime;
  final int distance;
  final int duration;
  final String rideOfferId;
  User creator;
  int passengersRequested;
  RideStatus rideStatus;

  RideRequest({
    this.id,
    @required this.rideOfferId,
    @required this.from,
    @required this.to,
    @required this.rideRequestTime,
    @required this.distance,
    @required this.duration,
    this.creator,
    @required this.passengersRequested,
    this.rideStatus
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "rideOfferId": rideOfferId,
    "from": from.toJson(),
    "to": to.toJson(),
    "rideRequestTime": rideRequestTime.toIso8601String(),
    "distance": distance,
    "duration": duration,
    "creator": creator == null ? null : creator.toJson()..removeWhere((key, value) => key == 'email'),
    "passengersRequested": passengersRequested,
    "rideStatus": rideStatus == null ? null : rideStatus.toString()
  }..removeWhere((key, value) => value == null);

  factory RideRequest.fromJson(Map<String, dynamic> data) {
    return RideRequest(
        id: data['id'],
        rideOfferId: data['rideOfferId'],
        from: Place.fromJson(data['from']),
        to: Place.fromJson(data['to']),
        creator: User.fromJson(data['creator']),
        rideRequestTime: DateTime.parse(data['rideRequestTime']),
        distance: data['distance'],
        duration: data['duration'],
        passengersRequested: data['passengersRequested'],
        rideStatus: RideStatus.values.firstWhere((e) => e.toString() == 'RideStatus.' + data['rideStatus']),
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  bool get isCancellable {
    return rideStatus == RideStatus.request_accepted || rideStatus == RideStatus.request_waiting;
  }

  bool get isOngoing {
    return rideStatus == RideStatus.ride_ongoing;
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

/*
  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-test-73645-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }*/
}
