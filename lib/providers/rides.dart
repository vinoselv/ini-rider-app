import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/models/user.dart';
import 'package:riderapp/providers/car.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/ride_request.dart';

class Rides with ChangeNotifier {
  RideOffer _rideOffer;

  List<RideOffer> _itemsSearched = [];

  List<RideRequest> _itemsRequested = [];

  List<RideOffer> _itemsOffered = [];

  final String authToken;
  final User user;
  final String awsBaseUrl;

  Car _car;
  Car get userCar {
    return _car;
  }

  //RideOffers(this.authToken, this.userId, this._items);
  Rides(this.authToken, this.user, this.awsBaseUrl);

  List<RideOffer> get itemsOffered {
    return [..._itemsOffered];
  }

  List<RideRequest> get itemsRequested {
    return [..._itemsRequested];
  }

  List<RideOffer> get itemsSearched {
    return [..._itemsSearched];
  }

  RideOffer get rideOffer {
    return _rideOffer;
  }

  List<RideOffer> get favoriteItems {
    return _itemsOffered.where((prodItem) => prodItem.rideStatus != RideStatus.ride_completed).toList();
  }

  RideOffer findById(String id) {
    return _itemsOffered.firstWhere((ride) => ride.id == id);
  }

  Future<void> postRideOffer(RideOffer offer) async {
    final url = awsBaseUrl + "/ride-offer";
    print(offer);
    print("-----------------");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode(offer.toJson()),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      }
      final newRideOffer = RideOffer.fromJson(extractedData);
      //_items.add(newProduct);
      print("length before : " + _itemsOffered.length.toString());
      //_itemsOffered.insert(0, newRideOffer); // at the start of the list
      print("length after : " + _itemsOffered.length.toString());
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> postRideRequest(String rideOfferId, RideRequest request) async {
    final url = awsBaseUrl + "/rides/$rideOfferId/request";
    print(request);
    print("-----------------");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode(request.toJson()),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      }
      //final newRideOffer = RideOffer.fromJson(extractedData);
      //_items.add(newProduct);
      print("length before : " + _itemsOffered.length.toString());
      //_itemsOffered.insert(0, newRideOffer); // at the start of the list
      print("length after : " + _itemsOffered.length.toString());
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<RideOffer> getRideOfferById(String rideOfferId) async {
    var url = awsBaseUrl + "/rides/$rideOfferId";
    try {
      print(rideOfferId);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return Future.error("Something went wrong!");;
      }
      if (response.statusCode != 200) {
        return Future.error(List<String>.from(extractedData["message"]).join(', '));
      }
      print(extractedData);
      _rideOffer = RideOffer.fromJson(extractedData);
      notifyListeners();
      return _rideOffer;
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> searchRides(RideRequest request) async {
    var url = awsBaseUrl + "/search-rides";
    try {
      print(request.toJson()..removeWhere((key, value) => key == 'creator'));
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode(request.toJson()..removeWhere((key, value) => key == 'creator')),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      }
      print(extractedData);
      _itemsSearched = List<RideOffer>.from(extractedData["offers"].map((x) => RideOffer.fromJson(x)));
      print(_itemsSearched);
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> fetchRides([bool filterByUser = false]) async {
    var url = awsBaseUrl + "/rides";
    try {
      final response = await http.get(
          Uri.parse(url),
          headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      _itemsOffered = List<RideOffer>.from(extractedData["offers"].map((x) => RideOffer.fromJson(x)));
      _itemsRequested = List<RideRequest>.from(extractedData["requests"].map((x) => RideRequest.fromJson(x)));
      print(_itemsOffered);
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<bool> deleteRide(context, String rideId) async {
    final url =
        awsBaseUrl + "/rides/$rideId";
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
      );
      print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        print(response.body);
        final extractedData = json.decode(response.body) as Map<String, dynamic>;

        String error;
        if (extractedData == null) {
          error = "something went wrong";
        } else {
          error = List<String>.from(extractedData["message"]).join(', ');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
        ));
        //return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
        return false;
      }
      print("Deletion successful");
      //_items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
      return true;
    } catch (error, stacktrace) {
      print(stacktrace);
      throw error;
    }
  }

  Future<bool> updateRideOfferStatus(context, String rideOfferId, RideStatus rideStatus) async {
    final url =
        awsBaseUrl + "/ride-status";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode({
          'id': rideOfferId,
          'type': 'ride_offer',
          'rideStatus': rideStatus.toString().split('.')[1],
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        String error;
        if (extractedData == null) {
          error = "something went wrong";
        } else {
          error = List<String>.from(extractedData["message"]).join(', ');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
        ));
        //return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
        return false;
      }
      //_items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> updateRideRequestStatus(context, String rideId, String rideOfferId, RideStatus rideStatus, int rating) async {
    final url =
        awsBaseUrl + "/ride-status";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode({
          'id': rideId,
          'rideOfferId': rideOfferId,
          'type': 'ride_request',
          'rideStatus': rideStatus.toString().split('.')[1],
          'rating': rating ?? 0
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        String error;
        if (extractedData == null) {
          error = "something went wrong";
        } else {
          error = List<String>.from(extractedData["message"]).join(', ');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
        ));
        //return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
        return false;
      }
      //_items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> deleteCar(BuildContext context) async {
    final url = awsBaseUrl + "/car";
    print("-----------------");
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        String error;
        if (extractedData == null) {
          error = "something went wrong";
        } else {
          error = List<String>.from(extractedData["message"]).join(', ');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
        ));
        //return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
        return false;
      }
      notifyListeners();
      return true;
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> postCar(Car car) async {
    final url = awsBaseUrl + "/car";
    print(car);
    print("-----------------");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode(car.toJson()),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      }
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> updateCar(Car car) async {
    final url = awsBaseUrl + "/car";
    print(car);
    print("-----------------");
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
        body: json.encode(car.toJson()),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      }
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }

  Future<void> getCar() async {
    final url = awsBaseUrl + "/car";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': authToken
        },
      );
      if (response.statusCode == 404) {
        _car = null;
        notifyListeners();
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return null;
      }

      print(response.body);
      if (response.statusCode != 200) {
        return Future.error(extractedData["type"] + " -> " + List<String>.from(extractedData["message"]).join(', '));
      } else {
        _car = Car.fromJson(extractedData);
        print("---> car : " + _car.toString());
      }
      notifyListeners();
    } catch (error, stacktrace) {
      print(stacktrace);
      return Future.error(error.toString());
    }
  }
}
