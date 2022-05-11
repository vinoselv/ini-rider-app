import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/widgets/custom_button.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:riderapp/widgets/ride_request_metadata_item.dart';
import 'package:riderapp/widgets/user_ride_stats_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RideOfferDetailsScreen extends StatefulWidget {
  final String id;
  final Function requestRide;
  final Function cancelRide;

  RideOfferDetailsScreen({this.id, this.requestRide, this.cancelRide});

  static const routeName = '/rideoffer';

  @override
  _RideOfferDetailsScreenState createState() => _RideOfferDetailsScreenState();
}

class _RideOfferDetailsScreenState extends State<RideOfferDetailsScreen> {
  var focusDestination = FocusNode();

  bool focused = false;

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

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  double mapBottomPadding = 0;

  String loggedInUserId;

  Future<void> _getRideOffer(BuildContext context, String rideOfferId) async {
    await Provider.of<Rides>(context, listen: false)
        .getRideOfferById(rideOfferId);
  }

  void reloadRide() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    loggedInUserId = Provider.of<Auth>(context, listen: false).user.id;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: Container(
          decoration: BoxDecoration(color: BrandColors.colorGreen, boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 0.5,
              offset: Offset(
                0.7,
                0.7,
              ),
            ),
          ]),
          child: Padding(
            padding: EdgeInsets.only(left: 24, top: 38, right: 24, bottom: 10),
            child: Row(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                    )),
                SizedBox(
                  width: 10,
                ),
                Center(
                  child: Text(
                    'Ride details',
                    style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getRideOffer(context, widget.id),
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
                onRefresh: () => _getRideOffer(context, widget.id),
                child: Consumer<Rides>(
                  builder: (ctx, offerData, _) {
                    RideOffer ro = offerData.rideOffer;
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
                                "Creator",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            //width: 100,
                            children: <Widget>[
                              ProfileWidget(
                                icon: ro.creator.iconKey != null
                                    ? deserializeIcon(
                                        Utils.getIconFromKey(
                                            ro.creator.iconKey))
                                    : Icons.person,
                                onClicked: () {},
                                isEdit: false,
                                size: 30,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                ro.creator.name,
                                //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          UserRideStatsWidget(
                            user: ro.creator,
                            includeRequests: false,
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                                "Route",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  ro.from.address,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Icon(
                                FontAwesomeIcons.angleDoubleDown,
                                color: BrandColors.colorGreen,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                ro.to.address,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .airline_seat_recline_normal_sharp,
                                              color: BrandColors.colorGreen,
                                              size: 24,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                (ro.passengersAllowed -
                                                            ro
                                                                .passengersAccepted)
                                                        .toString() +
                                                    "/" +
                                                    ro.passengersAllowed
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.date_range,
                                              color: BrandColors.colorGreen,
                                              size: 24,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                DateFormat('EEE d MMM hh:mm a')
                                                    .format(ro.rideStartTime
                                                        .toLocal()),
                                                style: TextStyle(
                                                    color: Colors
                                                        .grey) //Returns Sat 20 Junro.rideStartTime.toIso8601String(),
                                                ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        InkWell(
                                            customBorder: new CircleBorder(),
                                            onTap: () {
                                              Utils.openMapForRide(
                                                  rideOffer: ro);
                                            },
                                            child: Icon(
                                              Icons.directions,
                                              color: BrandColors.colorGreen,
                                              size: 35,
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          ro.distance.toInt().toString() +
                                              " kms / " +
                                              ro.duration.toInt().toString() +
                                              " mins",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                      ],
                                    ),
                                  ]),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                                "Requests",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              child: ro.rideRequests.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: ro.rideRequests.length,
                                      itemBuilder: (_, i) => Column(
                                        children: [
                                          RideRequestMetaDataItem(
                                              ro,
                                              ro.rideRequests[i],
                                              reloadRide,
                                              loggedInUserId),
                                          //Divider(),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                          "There are no requests for this ride yet."))),
                          if (isNotCreatorButCanRequest(loggedInUserId, ro))
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: CustomButton(
                                  title: 'Request Ride',
                                  color: BrandColors.colorGreen,
                                  onPressed: () {
                                    widget.requestRide(ro.id);
                                  },
                                )),
                          if (isNotCreatorButCanOnlyCancel(loggedInUserId, ro))
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: CustomButton(
                                  title: 'Cancel Request',
                                  color: BrandColors.colorGreen,
                                  onPressed: () {
                                    widget.cancelRide(getUserRideRequestId(
                                        loggedInUserId, ro));
                                  },
                                )),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
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
    } else if (ro.rideRequests
        .where((r) => r.creator.id == userId && r.isModifiable)
        .isEmpty) {
      return false;
    }
    return true;
  }

  String getUserRideRequestId(String userId, RideOffer ro) {
    return ro.rideRequests.where((r) => r.creator.id == userId).first.id;
  }
}
