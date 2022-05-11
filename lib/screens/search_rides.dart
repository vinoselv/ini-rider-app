
import 'dart:async';
import 'dart:io' as io;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/ride_request.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/search_results_screen.dart';
import 'package:riderapp/screens/search_results_screen_arguments.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import './search_destination.dart';
import '../brand_colors.dart';
import '../globalvariable.dart';
import '../helpers/utils.dart';
import '../models/directiondetails.dart';
import '../providers/route_data.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/custom_button.dart';

class SearchRidesScreen extends StatefulWidget {
  static const routeName = '/search-rides';
  static const String id = 'mainpage';

  final Position currentPosition;
  final Function goToRidesScreen;

  const SearchRidesScreen({Key key, this.currentPosition, this.goToRidesScreen}) : super(key: key);

  @override
  _SearchRidesScreenState createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = (io.Platform.isIOS) ? 200 : 175;
  double rideDetailsSheetHeight = 0; // (io.Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight = 0; // (io.Platform.isAndroid) ? 195 : 220
  double tripSheetHeight = 0; // (io.Platform.isAndroid) ? 275 : 300

  double searchBoxHeight = 50;
  double backButtonHeight = 0;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  var dateTimeController = TextEditingController();
  int numberOfSeats = 1;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  BitmapDescriptor nearbyIcon;

  var geoLocator = Geolocator();
  DirectionDetails tripDirectionDetails;

  String appState = 'NORMAL';
  bool nearbyDriversKeysLoaded = false;

  bool isRequestingLocationDetails = false;

  void showDetailSheet() async {
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      mapBottomPadding = (io.Platform.isAndroid) ? 240 : 230;
      rideDetailsSheetHeight = (io.Platform.isAndroid) ? 260 : 250;
      searchBoxHeight = 0;
      backButtonHeight = 40;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (io.Platform.isAndroid) ? 220 : 220;
      mapBottomPadding = (io.Platform.isAndroid) ? 200 : 190;

    });
  }

  showTripSheet() {
    setState(() {
      requestingSheetHeight = 0;
      tripSheetHeight = (io.Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (io.Platform.isAndroid) ? 280 : 270;
    });
  }

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (io.Platform.isIOS)
                  ? 'images/car_ios.png'
                  : 'images/car_android.png')
          .then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: googlePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polylines,
              markers: _Markers,
              circles: _Circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapBottomPadding = (io.Platform.isAndroid) ? 280 : 270;
                });

                zoomMapToCurrentPosition();
              },
            ),

            /// SearchSheet
            Positioned(
              left: 5,
              right: 5,
              top: 60,
              height: searchBoxHeight,
              //bottom: 10,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchDestinationScreen(
                                position: widget.currentPosition)));

                    if (response == 'getDirection') {
                      showDetailSheet();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(
                                0.7,
                                0.7,
                              ))
                        ]),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Search Destination'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 34,
              left: 20,
              height: backButtonHeight,
              child: GestureDetector(
                onTap: (){
                    resetApp();
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
                            )
                        )
                      ]
                  ),
                  child: Visibility (
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(Icons.arrow_back, color: Colors.black87,),
                    ),
                    visible: backButtonHeight > 0,
                ),

                ),
              ),
            ),

            /// RideDetails Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 0.5, //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                          0.7, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                  ),
                  height: rideDetailsSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10,),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 18,),
                            Image.asset('assets/images/pickicon.png', height: 16, width: 16,),
                            SizedBox(width: 18,),
                            Flexible(
                              child: Text(
                                Provider.of<RouteData>(context, listen: false).pickupAddress?.displayName ?? '',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(width: 18,)
                          ]
                        ),
                        SizedBox(height: 20,),
                        Row(
                            children: <Widget>[
                              SizedBox(width: 18,),
                              Image.asset('assets/images/desticon.png', height: 16, width: 16,),
                              SizedBox(width: 18,),
                              Flexible(
                                child: Text(
                                  Provider.of<RouteData>(context, listen: false).destinationAddress?.displayName ?? '',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(width: 18,)
                            ]
                        ),
                        SizedBox(height: 20,),
                        Container(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.timer),

                                SizedBox(width: 5,),

                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: BrandColors.colorLightGrayFair,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.all(2.0),
                                      child: TextField(
                                        onTap: () {
                                          DatePicker.showDateTimePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime.now(),
                                              maxTime: DateTime.now().add(Duration(days: 365)),
                                              onChanged: (date) {
                                                print('change $date');
                                              }, onConfirm: (date) {
                                                print('confirm $date');
                                                setState(() {
                                                  dateTimeController.text = DateFormat('dd/MM/yyyy hh:mm a').format(date);
                                                });
                                              },
                                              currentTime: DateTime.now());
                                        },
                                        readOnly: true,
                                        controller: dateTimeController,
                                        decoration: InputDecoration(
                                            hintText: 'When?',
                                            fillColor: BrandColors.colorLightGrayFair,
                                            filled: true,
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5,),

                                Icon(Icons.airline_seat_recline_normal_sharp),

                                SizedBox(width: 5,),

                                Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: BrandColors.colorLightGrayFair,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.all(2.0),
                                      child: DropdownButton<int>(
                                        value: numberOfSeats,
                                        elevation: 16,
                                        style: const TextStyle(color: Colors.deepPurple),
                                        onChanged: (int newValue) {
                                          setState(() {
                                            numberOfSeats = newValue;
                                          });
                                        },
                                        items: <int>[1, 2, 3, 4, 5]
                                            .map<DropdownMenuItem<int>>((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      )
                                    ),
                                  ),
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          width: double.infinity,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: <Widget>[
                                Expanded(

                                  child: CustomButton(
                                    title: 'Search',
                                    color: BrandColors.colorGreen,
                                    onPressed: () {

                                      try {
                                        DateFormat('dd/MM/yyyy hh:mm a').parse(dateTimeController.text);
                                      } catch(error) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Select a valid date and time!", textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
                                        ));
                                        return;
                                      }

                                      setState(() {
                                        appState = 'REQUESTING';
                                      });
                                      showRequestingSheet();

                                      RideRequest rideRequest = new RideRequest(
                                          from: Provider.of<RouteData>(context, listen: false).pickupAddress,
                                          to: Provider.of<RouteData>(context, listen: false).destinationAddress,
                                          rideRequestTime: DateFormat('dd/MM/yyyy hh:mm a').parse(dateTimeController.text),
                                          distance: tripDirectionDetails.distanceValue,
                                          duration: tripDirectionDetails.durationValue,
                                          creator: Provider.of<Auth>(context, listen: false).user,
                                          passengersRequested: numberOfSeats);

                                      print(rideRequest);
                                      Navigator.of(context).pushNamed(
                                          SearchResultsScreen.routeName,
                                          arguments: SearchResultsScreenArguments(rideRequest, widget.goToRidesScreen),
                                      );
                                      resetApp();

                                      //postRideOffer(co);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: CustomButton(
                                    title: 'Offer',
                                    color: BrandColors.colorGreen,
                                    onPressed: () {

                                      try {
                                        DateFormat('dd/MM/yyyy hh:mm a').parse(dateTimeController.text);
                                      } catch(error) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Select a valid date and time!", textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
                                        ));
                                        return;
                                      }

                                      setState(() {
                                        appState = 'OFFERING';
                                      });
                                      showRequestingSheet();

                                      RideOffer rideOffer= new RideOffer(
                                          from: Provider.of<RouteData>(context, listen: false).pickupAddress,
                                          to: Provider.of<RouteData>(context, listen: false).destinationAddress,
                                          rideStartTime: DateFormat('dd/MM/yyyy hh:mm a').parse(dateTimeController.text),
                                          distance: tripDirectionDetails.distanceValue,
                                          duration: tripDirectionDetails.durationValue,
                                          creator: Provider.of<Auth>(context, listen: false).user,
                                          passengersAllowed: numberOfSeats);

                                      postRideOffer(context, rideOffer, widget.goToRidesScreen);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// Request Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 0.5, //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                          0.7, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                  ),
                  height: requestingSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextLiquidFill(
                            text: 'Working on it...',
                            waveColor: BrandColors.colorTextSemiLight,
                            boxBackgroundColor: Colors.white,
                            textStyle: TextStyle(
                                color: BrandColors.colorText,
                                fontSize: 22.0,
                                fontFamily: 'Brand-Bold'),
                            boxHeight: 40.0,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            cancelRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  width: 1.0,
                                  color: BrandColors.colorLightGrayFair),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Cancel ride',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void zoomMapToCurrentPosition() {
    LatLng pos = LatLng(widget.currentPosition?.latitude,
        widget.currentPosition?.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);

    //setupPositionLocator();
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<RouteData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<RouteData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));

    var thisDetails =
        await Utils.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

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

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.name, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.name, snippet: 'Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
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

  void removeGeofireMarkers() {
    setState(() {
      _Markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }


  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var destination =
          Provider.of<RouteData>(context, listen: false).destinationAddress;

      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetails = await Utils.getDirectionDetails(
          driverLocation, destinationLatLng);

      if (thisDetails == null) {
        return;
      }

      isRequestingLocationDetails = false;
    }
  }

  void cancelRequest() {
    setState(() {
      appState = 'NORMAL';
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = (io.Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (io.Platform.isAndroid) ? 280 : 270;
      searchBoxHeight = 40;
      backButtonHeight = 0;
      dateTimeController.clear();
      numberOfSeats = 1;

      zoomMapToCurrentPosition();
      Utils.findCordinateAddress(widget.currentPosition, context);

    });

    //setupPositionLocator();
  }

  Future<void>  postRideOffer(BuildContext context, RideOffer offer, Function goToRidesScreen) async {
    Provider.of<Rides>(context, listen: false)
        .postRideOffer(offer)
        .then((value) {
            //Navigator.of(context).pushNamed(RidesScreen.routeName);

            resetApp();
            goToRidesScreen(0);

         })
        .catchError((error, stackTrace) {
            showSnackBar(error.toString());
            resetApp();
    });
  }

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
