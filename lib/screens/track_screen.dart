import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/car.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/widgets/add_car_item.dart';
import 'package:riderapp/widgets/car_item.dart';
import 'package:riderapp/widgets/ride_request_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TrackScreen extends StatefulWidget {
  final String id;
  final Function requestRide;
  final Function cancelRide;

  TrackScreen({this.id, this.requestRide, this.cancelRide});

  static const routeName = '/track';

  @override
  _TrackScreenState createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<LatLng> polylineCoordinates = [];

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  double mapBottomPadding = 0;

  String loggedInUserId;
  Car _car;

  Future<void> _refreshRides(BuildContext context) async {
    //Future
    //.wait([Provider.of<Rides>(context, listen: false).getCar(), Provider.of<Rides>(context, listen: false).fetchRides(true)]);
    await Provider.of<Rides>(context, listen: false).getCar();
    await Provider.of<Rides>(context, listen: false).fetchRides(true);
  }

  void reloadCar() {
    setState(() {});
  }

  void cancelRide(String rideRequestId) async {
    print("this is called with : " + rideRequestId);
    await Provider.of<Rides>(context, listen: false)
        .deleteRide(context, rideRequestId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    loggedInUserId = Provider.of<Auth>(context, listen: false).user.id;

    return Scaffold(
      body: FutureBuilder(
          future: _refreshRides(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.sadCry,
                        color: BrandColors.colorGreen,
                        size: 48,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Ah... Something went wrong",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refreshRides(context),
                  child: Consumer<Rides>(
                    builder: (ctx, ridesData, _) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView(
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.only(
                                  bottom: 5, // Space between underline and text
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: BrandColors.colorGreen,
                                      width: 1.0, // Underline thickness
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Your Car",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ridesData.userCar == null
                                ? AddCarItem()
                                : CarItem(ridesData.userCar, reloadCar),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: ridesData.itemsRequested.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount:
                                          ridesData.itemsRequested.length,
                                      itemBuilder: (_, i) {
                                        if (i == 0) {
                                          return Column(
                                            children: [
                                              Center(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        5, // Space between underline and text
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: BrandColors
                                                            .colorGreen,
                                                        width:
                                                            1.0, // Underline thickness
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Rides",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              RideRequestItem(
                                                  ridesData.itemsRequested[i],
                                                  null,
                                                  cancelRide,
                                                  null,
                                                  true),
                                            ],
                                          );
                                        } else {
                                          return RideRequestItem(
                                              ridesData.itemsRequested[i],
                                              null,
                                              null,
                                              cancelRide,
                                              true);
                                        }
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                          "There are no ride requests from you yet."),
                                    ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            }
          }),
    );
  }

  bool isNotCreatorButCanRequest(String userId, RideOffer ro) {
    if (ro.creator.id == userId) {
      return false;
    } else if (ro.rideRequests
        .where((r) => r.creator.id == userId)
        .isNotEmpty) {
      return false;
    }
    return true;
  }

  bool isNotCreatorButCanOnlyCancel(String userId, RideOffer ro) {
    if (ro.creator.id == userId) {
      return false;
    } else if (ro.rideRequests.where((r) => r.creator.id == userId).isEmpty) {
      return false;
    }
    return true;
  }

  String getUserRideRequestId(String userId, RideOffer ro) {
    return ro.rideRequests.where((r) => r.creator.id == userId).first.id;
  }
}
