import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/widgets/ride_offer_item.dart';
import 'package:riderapp/widgets/ride_request_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class RidesScreen extends StatefulWidget {
  static const routeName = '/rides';
  final TabController tabController;

  const RidesScreen({Key key, this.tabController}) : super(key: key);

  @override
  _RidesScreenState createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  Future<void> _refreshRides(BuildContext context) async {
    await Provider.of<Rides>(context, listen: false).fetchRides(true);
  }

  void cancelRide(String rideRequestId) async {
    print("this is called with : " + rideRequestId);
    await Provider.of<Rides>(context, listen: false)
        .deleteRide(context, rideRequestId);
    setState(() {

    });
    //Navigator.pop(context);
  }

  void reloadRide() {
    setState(() {

    });
  }

  String loggedInUserId;

  @override
  Widget build(BuildContext context) {
    print("build called again :) " + widget.tabController.length.toString());
    setFocus();
    loggedInUserId = Provider.of<Auth>(context, listen: false).user.id;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: ColoredBox(
          color: BrandColors.colorGreen,
          child: TabBar(
            controller: widget.tabController,
            unselectedLabelColor: Colors.white,
            unselectedLabelStyle: TextStyle(
                fontSize: 16, color: Color.fromRGBO(142, 142, 142, 1)),
            labelColor: Colors.black,
            labelPadding: EdgeInsets.fromLTRB(0, 20, 0, 8),
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.black, width: 3.0)),
            tabs: [
              Tab(
                  child: Text(
                'Offered',
              )),
              Tab(
                  child: Text(
                'Requested',
              )),
            ],
          ),),
      ),
      body: TabBarView(
        controller: widget.tabController,
        children: [
          FutureBuilder(
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
                        )
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () => _refreshRides(context),
                      child: Consumer<Rides>(
                          builder: (ctx, ridesData, _) {
                            if (ridesData.itemsOffered
                                .length > 0) {
                              return Padding(
                                padding: EdgeInsets.all(8),
                                child: ListView.builder(
                                  itemCount: ridesData.itemsOffered
                                      .length,
                                  itemBuilder: (_, i) =>
                                      Column(
                                        children: [
                                          RideOfferItem(
                                              ridesData.itemsOffered[i],
                                              null,
                                              cancelRide,
                                              reloadRide,
                                             loggedInUserId
                                          ),
                                          //Divider(),
                                        ],
                                      ),
                                ),
                              );
                            } else {
                              return Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.carAlt,
                                        color: BrandColors.colorGreen,
                                        size: 48,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Hmmm... We couldn't find any rides offered by you",
                                        style: TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  )
                              );
                            }
                          }
                      ),
                    );
                  }
                }
              }),
          FutureBuilder(
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
                        )
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () => _refreshRides(context),
                      child: Consumer<Rides>(
                          builder: (ctx, offersData, _) {
                            if (offersData.itemsRequested
                                .length > 0) {
                              return Padding(
                                padding: EdgeInsets.all(8),
                                child: ListView.builder(
                                  itemCount: offersData.itemsRequested
                                      .length,
                                  itemBuilder: (_, i) =>
                                      Column(
                                        children: [
                                          RideRequestItem(
                                              offersData.itemsRequested[i],
                                              null,
                                              cancelRide,
                                              reloadRide,
                                              false
                                          ),
                                          //Divider(),
                                        ],
                                      ),
                                ),
                              );
                            } else {
                              return Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.carAlt,
                                        color: BrandColors.colorGreen,
                                        size: 48,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Hmmm... We couldn't find any rides requested by you",
                                        style: TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  )
                              );
                            }
                          }
                      ),
                    );
                  }
                }
              }),
        ],
      ),
    );
  }
}
