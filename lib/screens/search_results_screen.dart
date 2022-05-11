import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/ride_request.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/search_results_screen_arguments.dart';
import 'package:riderapp/widgets/ride_offer_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  Future<void> _searchRides(
      BuildContext context, RideRequest rideRequest) async {
    await Provider.of<Rides>(context, listen: false).searchRides(rideRequest);
  }

  RideRequest rideRequest;
  Function goToRidesScreen;
  String loggedInUserId;

  void requestRide(String offerId) async {
    print("this is called with offerId : " + offerId);
    Provider.of<Rides>(context, listen: false)
        .postRideRequest(offerId, rideRequest)
        .then((value) {
      print("COMING HERE :::::::::::::::::::::");
      //Navigator.of(context).pushNamed(RidesScreen.routeName);
      Navigator.pop(context);
      Navigator.pop(context);
      goToRidesScreen(1);
    }).catchError((error, stackTrace) {
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      ));
    });
    //Navigator.pop(context);
  }

  void cancelRide(String rideRequestId) async {
    print("this is called with : " + rideRequestId);
    await Provider.of<Rides>(context, listen: false)
        .deleteRide(context, rideRequestId);
    Navigator.pop(context);
  }

  void reloadRide() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    SearchResultsScreenArguments arg = ModalRoute.of(context).settings.arguments
        as SearchResultsScreenArguments;

    rideRequest = arg.rideRequest;
    goToRidesScreen = arg.goToRidesScreen;
    loggedInUserId = Provider.of<Auth>(context, listen: false).user.id;


    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: Container(
              decoration:
                  BoxDecoration(color: BrandColors.colorGreen, boxShadow: [
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
                padding:
                    EdgeInsets.only(left: 24, top: 38, right: 24, bottom: 10),
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
                        'Search results',
                        style:
                            TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                      ),
                    ),
                  ],
                ),
              ))),
      body: FutureBuilder(
          future: _searchRides(context, rideRequest),
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
                ));
              } else {
                return RefreshIndicator(
                  onRefresh: () => _searchRides(context, rideRequest),
                  child: Consumer<Rides>(builder: (ctx, offersData, _) {
                    if (offersData.itemsSearched.length > 0) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: offersData.itemsSearched.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              RideOfferItem(
                                  offersData.itemsSearched[i],
                                  requestRide,
                                  cancelRide,
                                  reloadRide,
                                  loggedInUserId),
                              //Divider(),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.sadTear,
                            color: BrandColors.colorGreen,
                            size: 48,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Hmmm... We couldn't find any rides matching your criteria",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ));
                    }
                  }),
                );
              }
            }
          }),
    );
  }
}
