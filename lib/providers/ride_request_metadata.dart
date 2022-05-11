import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/models/place.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/models/user.dart';
import 'package:http/http.dart' as http;

class RideRequestMetaData with ChangeNotifier {
  final String id;
  final Place from;
  final Place to;
  final DateTime rideRequestTime;
  final int distance;
  final int duration;
  final User creator;
  final int passengersRequested;
  final RideStatus rideStatus;

  RideRequestMetaData({
    @required this.id,
    @required this.from,
    @required this.to,
    @required this.rideRequestTime,
    @required this.distance,
    @required this.duration,
    @required this.creator,
    @required this.passengersRequested,
    @required this.rideStatus
  });

  String get status {
    return rideStatus.toString().split('.')[1].split('_')[1];
  }

  bool get isModifiable {
    return rideStatus == RideStatus.request_accepted || rideStatus == RideStatus.request_waiting;
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

  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "from": from.toJson(),
    "to": to.toJson(),
    "rideRequestTime": rideRequestTime.toIso8601String(),
    "distance": distance,
    "duration": duration,
    "passengersRequested": passengersRequested,
    "creator": creator.toJson(),
    "rideStatus": rideStatus == null ? null : rideStatus.toString(),
  }..removeWhere((key, value) => value == null);

  factory RideRequestMetaData.fromJson(Map<String, dynamic> data) {
    return RideRequestMetaData(
      id: data['id'],
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
