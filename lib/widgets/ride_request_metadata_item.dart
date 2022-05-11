import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/ride_request_metadata.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RideRequestMetaDataItem extends StatelessWidget {
  final RideRequestMetaData rr;
  final RideOffer ro;
  final Function reloadRide;
  final String loggedInUserId;

  RideRequestMetaDataItem(
      this.ro, this.rr, this.reloadRide, this.loggedInUserId);

  Future<void> updateRideRequestStatus(BuildContext context, String rideId,
      String rideOfferId, RideStatus rideStatus) async {
    bool result = await Provider.of<Rides>(context, listen: false)
        .updateRideRequestStatus(context, rideId, rideOfferId, rideStatus, null);

    if (result) {
      reloadRide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  //width: 100,
                  children: <Widget>[
                    ProfileWidget(
                      icon: rr.creator.iconKey != null
                          ? deserializeIcon(
                              Utils.getIconFromKey(rr.creator.iconKey))
                          : Icons.person,
                      onClicked: () {},
                      isEdit: false,
                      size: 30,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      rr.creator.name,
                      //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          rr.from.address,
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.angleDoubleDown,
                            color: BrandColors.colorGreen,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            rr.distance.toInt().toString() +
                                " kms / " +
                                rr.duration.toInt().toString() +
                                " mins",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        rr.to.address,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: BrandColors.colorGreen,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(DateFormat('EEE d MMM hh:mm a').format(rr
                                      .rideRequestTime.toLocal()) //Returns Sat 20 Junro.rideStartTime.toIso8601String(),
                                  ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.airline_seat_recline_normal_sharp,
                                color: BrandColors.colorGreen,
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(rr.passengersRequested.toString())
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      rr.statusIcon,
                      color: rr.statusColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      rr.status,
                      style: TextStyle(color: rr.statusColor),
                    ) //Returns Sat 20 Junro.rideStartTime.toIso8601String(),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                        customBorder: new CircleBorder(),
                        onTap: () {
                          Utils.openMapForRide(
                              rideOffer: ro,
                              optionalWaypoint:
                                  Utils.getWayPoint(rr.from, rr.to));
                        },
                        child: Icon(
                          Icons.directions,
                          color: BrandColors.colorGreen,
                          size: 35,
                        )),
                    Visibility(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              customBorder: new CircleBorder(),
                              onTap: () {
                                updateRideRequestStatus(context, rr.id, ro.id,
                                    RideStatus.request_accepted);
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: BrandColors.colorGreen,
                                size: 35,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              customBorder: new CircleBorder(),
                              onTap: () {
                                updateRideRequestStatus(context, rr.id, ro.id,
                                    RideStatus.request_rejected);
                              },
                              child: Icon(
                                Icons.highlight_off,
                                color: Colors.red,
                                size: 35,
                              )),
                        ],
                      ),
                      visible: ro.creator.id == loggedInUserId && rr.isModifiable,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
