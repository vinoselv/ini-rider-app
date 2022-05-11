import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/ride_offer.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/ride_offer_details_screen.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RideOfferItem extends StatelessWidget {
  final RideOffer ro;
  final Function requestRide;
  final Function cancelRide;
  final Function reloadRide;
  final String loggedInUserId;

  RideOfferItem(this.ro, this.requestRide, this.cancelRide, this.reloadRide,
      this.loggedInUserId);

  Future<void> updateRideOfferStatus(
      BuildContext context, String rideOfferId, RideStatus rideStatus) async {
    bool result = await Provider.of<Rides>(context, listen: false)
        .updateRideOfferStatus(context, rideOfferId, rideStatus);

    if (result) {
      reloadRide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(new MaterialPageRoute(
              builder: (context) => new RideOfferDetailsScreen(
                    id: ro.id,
                    requestRide: requestRide,
                    cancelRide: cancelRide,
                  )));
        },
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
                        icon: ro.creator.iconKey != null
                            ? deserializeIcon(Utils.getIconFromKey(
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
                            ro.from.address,
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
                              ro.distance.toInt().toString() +
                                  " kms / " +
                                  ro.duration.toInt().toString() +
                                  " mins",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
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
                                Text(DateFormat('EEE d MMM hh:mm a')
                                    .format(ro.rideStartTime.toLocal())),
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
                                Text((ro.passengersAllowed -
                                            ro.passengersAccepted)
                                        .toString() +
                                    "/" +
                                    ro.passengersAllowed.toString())
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
                        ro.statusIcon,
                        color: ro.statusColor,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        ro.status,
                        style: TextStyle(color: ro.statusColor),
                      ) //Returns Sat 20 Junro.rideStartTime.toIso8601String(),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("iNi Rider"),
                                  content: Text(
                                      "Starting the ride will share your car's location with the approved riders, until you mark the ride as completed. Do you wish to continue?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        updateRideOfferStatus(context, ro.id,
                                            RideStatus.ride_ongoing);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Continue"),
                                    ),
                                    FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.start_rounded,
                            color: BrandColors.colorGreen,
                            size: 25,
                          ),
                        ),
                        visible: ro.creator.id == loggedInUserId &&
                            ro.isNotOnGoing &&
                            ro.isNotCompleted,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            updateRideOfferStatus(context, ro.id,
                                RideStatus.ride_completed);
                          },
                          child: Icon(
                            Icons.done_outline,
                            color: BrandColors.colorGreen,
                            size: 25,
                          ),
                        ),
                        visible: ro.creator.id == loggedInUserId &&
                            ro.isNotCompleted,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "iNi Rider",
                                    style: TextStyle(
                                        color: BrandColors.colorGreen),
                                  ),
                                  content: Text(
                                      "Do you wish to cancel your offer for the ride? The associated requests for the offer also will be deleted."),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        cancelRide(ro.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Continue"),
                                    ),
                                    FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                        visible:
                            ro.creator.id == loggedInUserId && ro.isCancellable,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
