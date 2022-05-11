import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/globalvariable.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/helpers/mqttClientWrapper.dart';
import 'package:riderapp/models/directiondetails.dart';
import 'package:riderapp/models/place.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/widgets/ProgressDialog.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class TrackRideScreen extends StatefulWidget {
  final String rideOfferId;

  TrackRideScreen({this.rideOfferId});

  static const routeName = '/trackride';

  @override
  _TrackRideScreenState createState() => _TrackRideScreenState();
}

class _TrackRideScreenState extends State<TrackRideScreen> {
  var focusDestination = FocusNode();

  bool focused = false;
  MQTTClientWrapper mqttClientWrapper;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};
  DirectionDetails tripDirectionDetails;

  Completer<GoogleMapController> _googleMapCompleter = Completer();
  GoogleMapController _controller;

  double mapBottomPadding = 0;

  LocationData currentLocation;
  RideOffer rideOffer;
  Marker pickupMarker;


  void setup(String topicName) {
    mqttClientWrapper = MQTTClientWrapper(
        topicName, (newLocationJson) => gotNewLocation(newLocationJson));
    mqttClientWrapper.prepareMqttClient(topicName);
  }

  void gotNewLocation(LocationData newLocationData) {
    setState(() {
      this.currentLocation = newLocationData;
    });
    updateMarker("current");
    animateCameraToNewLocation(newLocationData);
  }

  void animateCameraToNewLocation(LocationData newLocation) {
    _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(newLocation.latitude, newLocation.longitude),
        zoom: 15)));
  }

  updateMarker(id){

    final marker = _Markers.toList().firstWhere((item) => item.markerId.value == id);

    Marker _marker = Marker(
      markerId: marker.markerId,
      position: LatLng(currentLocation.latitude, currentLocation.longitude),
      icon: marker.icon,
      infoWindow: marker.infoWindow,
    );

    setState(() {
      //the marker is identified by the markerId and not with the index of the list
      _Markers.remove(marker);
      _Markers.add(_marker);
    });
  }

  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {
    super.dispose();

    mqttClientWrapper.closeMqttClient();
  }

  String getTopicName(String rideOfferId) {
    return "rides/${rideOfferId}/shadow/update";
  }

  BitmapDescriptor customIcon;

  Future<void> _getRideOffer(BuildContext context, String rideOfferId) async {
    rideOffer = await Provider.of<Rides>(context, listen: false)
        .getRideOfferById(rideOfferId);

    if (mqttClientWrapper == null) {
      //TODO: FIx this please before releasing the application
      setup(getTopicName(rideOfferId));
    }

    /*
    tripDirectionDetails = await HelperMethods.getDirectionDetails(
        LatLng(rideOffer.from.latitude, rideOffer.from.longitude),
        LatLng(rideOffer.to.latitude, rideOffer.to.longitude));

    print(tripDirectionDetails);
*/
  }

  @override
  Widget build(BuildContext context) {


    /*
    currentLocation = LocationData.fromMap({
      'latitude': widget.car.place.latitude,
      'longitude': widget.car.place.longitude,
    });
*/
    // make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(5, 5)), 'assets/images/taxi.png')
        .then((d) {
      customIcon = d;
    });

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            /*
            initialCameraPosition: CameraPosition(
                target:
                    LatLng(rideOffer.from.latitude, rideOffer.from.longitude),
                zoom: 10),*/
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _Markers,
            circles: _Circles,
            onMapCreated: (GoogleMapController controller) async {
              _googleMapCompleter.complete(controller);
              _controller = controller;

              await _getRideOffer(context, widget.rideOfferId);

              getDirection(rideOffer);

            },
          ),
          Positioned(
            top: 34,
            left: 20,
            height: 40,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection(RideOffer ro) async {

    Place from = ro.from;
    Place to = ro.to;

    currentLocation = LocationData.fromMap({
      'latitude': from.latitude,
      'longitude': from.longitude,
    });

    var pickLatLng = LatLng(from.latitude, from.longitude);
    var destinationLatLng = LatLng(to.latitude, to.longitude);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));

    List<String> wayPointsList = rideOffer.rideRequests
        .where((r) => r.rideStatus == RideStatus.request_accepted || r.rideStatus == RideStatus.ride_ongoing)
        .map((r) => Utils.getWayPoint(r.from, r.to))
        .toList();

    var thisDetails;

    if (wayPointsList.isNotEmpty) {
      wayPointsList.insert(0, "optimize:true");
      String wayPoints = wayPointsList.join('|');
      thisDetails = await Utils.getDirectionDetailsWithWayPoints(pickLatLng, destinationLatLng, wayPoints);
    } else {
      thisDetails = await Utils.getDirectionDetails(pickLatLng, destinationLatLng);
    }

    setState(() {
     tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(tripDirectionDetails.encodedPoints);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {
    Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color: Color.fromARGB(255, 95, 109, 237),
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    _polylines.add(polyline);
    });

    // make polyline to fit into the map

    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
        northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: from.displayName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: to.displayName, snippet: 'Destination'),
    );


    Marker currentLocationMarker = Marker(
      markerId: MarkerId('current'),
      position: LatLng(currentLocation.latitude, currentLocation.longitude),
      icon: customIcon,
      infoWindow: InfoWindow(title: from.displayName, snippet: 'Current'),
    );

    setState(() {
    //_Markers.add(currentLocationMarker);
    _Markers.add(pickupMarker);
    _Markers.add(destinationMarker);
    _Markers.add(currentLocationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
    _Circles.add(pickupCircle);
    _Circles.add(destinationCircle);
    });
  }
}
