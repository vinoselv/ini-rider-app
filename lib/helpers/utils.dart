
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as logd;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../models/place.dart';
import '../models/directiondetails.dart';
import '../models/user.dart';
import '../providers/route_data.dart';
import '../globalvariable.dart';
import '../helpers/requesthelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class Utils{

  static final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  static void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Utils._();

  static String getCoordinates(Place place) {
    return place.latitude.toString() + "," + place.longitude.toString();
  }

  static String getWayPoint(Place from, Place to) {
    return getCoordinates(from) + "|" + getCoordinates(to);
  }

  static Future<void> openMapForRide({RideOffer rideOffer, String optionalWaypoint}) async {
      String source = getCoordinates(rideOffer.from);
      String destination = getCoordinates(rideOffer.to);

      List<String> wayPointsList = rideOffer.rideRequests
          .where((r) => r.rideStatus == RideStatus.request_accepted || r.rideStatus == RideStatus.ride_ongoing)
          .map((r) => getWayPoint(r.from, r.to))
          .toList();

      if (optionalWaypoint != null) {
        wayPointsList.add(optionalWaypoint);
      }

      if(wayPointsList.isNotEmpty) {
        // waypoint optimization is not supported in the launch url
        //wayPointsList.insert(0, "optimize:true");
      }

      String wayPoints = wayPointsList.join('|');

      print("source : $source");
      print("destination : $destination");
      print("wayPoints : $wayPoints");

      openMap(source, destination, wayPoints);

  }

  static Future<void> openMap(String source, String destination, String wayPoints) async {
    //String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$source&destination=$destination&waypoints=$wayPoints&travelmode=driving&dir_action=navigate';
    if (await canLaunchUrl(Uri.parse(Uri.encodeFull(googleUrl)))) {
      print(Uri.encodeFull(googleUrl));
      await launchUrl(Uri.parse(Uri.encodeFull(googleUrl)));
    } else {
      throw 'Could not open the map.';
    }
  }

 static Future<String> findCordinateAddress(Position position, context) async {

   String placeAddress = '';

   var connectivityResult = await Connectivity().checkConnectivity();
   if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
     return placeAddress;
   }

   String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
   print(url);

   var response = await RequestHelper.getRequest(url);

   if(response != 'failed'){
     placeAddress = response['results'][0]['formatted_address'];

     Place pickupAddress = new Place();

     pickupAddress.id = response['results'][0]['place_id'];
     pickupAddress.longitude = position.longitude;
     pickupAddress.latitude = position.latitude;
     pickupAddress.name = response['results'][0]['name'] ?? placeAddress;
     pickupAddress.address = placeAddress;

     print("---> pickup address name  : $placeAddress");

     Provider.of<RouteData>(context, listen: false).updatePickupAddress(pickupAddress);

   }

   return placeAddress;

  }

  static Future<DirectionDetails> getDirectionDetailsWithWayPoints(LatLng startPosition, LatLng endPosition, String wayPoints) async {

    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&waypoints=$wayPoints&driving&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    print("With WayPoints : " + url);
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    // convert the distance and duration to kms and minutes
    directionDetails.durationValue = (directionDetails.durationValue / 60).round();
    directionDetails.distanceValue = (directionDetails.distanceValue / 1000).round();

    return directionDetails;
  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {

   String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';

   var response = await RequestHelper.getRequest(url);

   if(response == 'failed'){
     return null;
   }

   print("WO WayPoints : " + url);
   DirectionDetails directionDetails = DirectionDetails();

   directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
   directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

   directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
   directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

   directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

   // convert the distance and duration to kms and minutes
   directionDetails.durationValue = (directionDetails.durationValue / 60).round();
   directionDetails.distanceValue = (directionDetails.distanceValue / 1000).round();

   return directionDetails;
  }

  static int estimateFares (DirectionDetails details){
   // per km = $0.3,
    // per minute = $0.2,
    // base fare = $3,

    double baseFare = 3;
    double distanceFare = (details.distanceValue/1000) * 0.3;
    double timeFare = (details.durationValue / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }

  static double generateRandomNumber(int max){

    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }

  final CameraPosition defaultMapLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static String getIconKey(var json) {
    return json['key'];
  }

 static Map<String, dynamic> getIconFromKey(String key) {
   return {
     'pack': "fontAwesomeIcons",
     'key': key,
   };
 }
}