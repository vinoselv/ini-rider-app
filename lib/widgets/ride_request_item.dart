import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/ride_request.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/ride_offer_details_screen.dart';
import 'package:riderapp/screens/track_ride_screen.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';

class RideRequestItem extends StatelessWidget {
  final RideRequest rr;
  final bool useTrackOption;
  final Function requestRide;
  final Function cancelRide;
  final Function reloadRide;

  RideRequestItem(this.rr, this.requestRide, this.cancelRide, this.reloadRide, this.useTrackOption);

  Future<void> updateRideRequestStatus(BuildContext context, String rideId,
      String rideOfferId, RideStatus rideStatus, int rating) async {
    bool result = await Provider.of<Rides>(context, listen: false)
        .updateRideRequestStatus(context, rideId, rideOfferId, rideStatus, rating);

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
                    id: rr.rideOfferId,
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
                        icon: rr.creator.iconKey != null
                            ? deserializeIcon(Utils.getIconFromKey(
                                rr.creator.iconKey))
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
                            )
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
                      SizedBox(
                        width: 20,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            if (rr.rideStatus == RideStatus.ride_ongoing) {
                              Navigator.of(context, rootNavigator: true)
                                  .push(
                                new MaterialPageRoute(
                                  builder: (context) =>
                                  new TrackRideScreen(rideOfferId: rr.rideOfferId),
                                ),
                              );
                            } else {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("iNi Rider", style: TextStyle(color: BrandColors.colorGreen),),
                                    content: Text(
                                        "A ride must be in ongoing state to track the location of the ride owner's car."),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Ok",
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Icon(
                            Icons.track_changes,
                            color: Colors.amber,
                            size: 25,
                          ),
                        ),
                        visible: useTrackOption,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("iNi Rider", style: TextStyle(color: BrandColors.colorGreen),),
                                  content: Text(
                                      "Do you wish to cancel your request for the ride?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        cancelRide(rr.id);
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
                        visible: !useTrackOption && rr.isCancellable ,
                      ),SizedBox(
                        width: 20,
                      ),
                      Visibility(
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true, // set to false if you want to force a rating
                              builder: (context) => RatingDialog(
                                initialRating: 1.0,
                                // your app's name?
                                title: Text(
                                  'Rate your ride',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // encourage your user to leave a high rating?
                                message: Text(
                                  'Tap a star to set your rating. Your feedback helps everyone to select a safe ride.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                // your app's logo?
                                image: Image(
                                  height: 150.0,
                                  width: 150.0,
                                  alignment: Alignment.center,
                                  image: AssetImage('assets/images/logo.png'),
                                ),
                                submitButtonText: 'Submit',
                                enableComment: false,
                                onCancelled: () {
                                  updateRideRequestStatus(context, rr.id, rr.rideOfferId,
                                    RideStatus.ride_completed, null);
                                },
                                onSubmitted: (response) {
                                  print('rating: ${response.rating}, comment: ${response.comment}');
                                  updateRideRequestStatus(context, rr.id, rr.rideOfferId,
                                    RideStatus.ride_completed, response.rating.toInt());

                                },
                              ),
                            );
                          },
                          child: Icon(
                            Icons.done_outline,
                            color: BrandColors.colorGreen,
                            size: 25,
                          ),
                        ),
                        visible: !useTrackOption && rr.isOngoing,
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
