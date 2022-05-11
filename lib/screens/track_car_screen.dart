import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/globalvariable.dart';
import 'package:riderapp/helpers/mqttClientWrapper.dart';
import 'package:riderapp/providers/car.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TrackCarScreen extends StatefulWidget {
  final Car car;

  TrackCarScreen({this.car});

  static const routeName = '/track';

  @override
  _TrackCarScreenState createState() => _TrackCarScreenState();
}

class _TrackCarScreenState extends State<TrackCarScreen> {
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

  Completer<GoogleMapController> _googleMapCompleter = Completer();
  GoogleMapController _controller;

  double mapBottomPadding = 0;

  LocationData currentLocation;

  void setup(String topicName) {
    mqttClientWrapper = MQTTClientWrapper(
        topicName, (newLocationJson) => gotNewLocation(newLocationJson));
    mqttClientWrapper.prepareMqttClient(topicName);
  }

  void gotNewLocation(LocationData newLocationData) {
    setState(() {
      this.currentLocation = newLocationData;
    });
    animateCameraToNewLocation(newLocationData);
  }

  void animateCameraToNewLocation(LocationData newLocation) {
    _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(newLocation.latitude, newLocation.longitude),
        zoom: 15)));
  }

  @override
  void initState() {
    super.initState();

    setup(getTopicName(widget.car.thingy91ImeiNumber.toString()));
    this.currentLocation = widget.car.place != null ? LocationData.fromMap({
      'latitude': widget.car.place?.latitude,
      'longitude': widget.car.place?.longitude,
    }) : null;
  }

  @override
  void dispose() {
    super.dispose();

    mqttClientWrapper.closeMqttClient();
  }

  String getTopicName(String imeiNumber) {
    return "\$aws/things/${imeiNumber}/shadow/update";
  }

  BitmapDescriptor customIcon;

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
            ImageConfiguration(size: Size(12, 12)), 'assets/images/taxi.png')
        .then((d) {
      customIcon = d;
    });

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: currentLocation == null ? googlePlex : CameraPosition(
                target: LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 10) ,
            markers: currentLocation == null
                ? Set()
                : [
                    Marker(
                      markerId: MarkerId("1"),
                      position: LatLng(
                          currentLocation.latitude, currentLocation.longitude),
                      //icon: customIcon
                    )
                  ].toSet(),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                this._controller = controller;
              });
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
                      ),
                    ),
                  ],
                ),
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
}
