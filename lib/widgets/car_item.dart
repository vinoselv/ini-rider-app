import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/models/ride_status.dart';
import 'package:riderapp/providers/car.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/car_registration.dart';
import 'package:riderapp/screens/track_car_screen.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CarItem extends StatelessWidget {
  final Car car;
  final Function reloadCar;

  CarItem(this.car, this.reloadCar);

  Future<void> updateRideRequestStatus(BuildContext context, String rideId,
      String rideOfferId, RideStatus rideStatus) async {
    bool result = await Provider.of<Rides>(context, listen: false)
        .updateRideRequestStatus(context, rideId, rideOfferId, rideStatus, null);

    if (result) {
      //reloadRide();
    }
  }

  Future<void> deleteCar(BuildContext context) async {
    bool result =
        await Provider.of<Rides>(context, listen: false).deleteCar(context);
    if (result) reloadCar();
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
                      icon: Icons.directions_car,
                      onClicked: () {},
                      isEdit: false,
                      size: 30,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      car.registrationNumber,
                      //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("Make: " + car.make + ", Model: " + car.model),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Year: " + car.year.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: BrandColors.colorGreen,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              car.place == null
                                  ? "Not available yet"
                                  : car.place.displayName,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE d MMM hh:mm a').format(
                                car.place == null
                                    ? DateTime.now()
                                    : car.place.lastReportedTime),
                            style: TextStyle(color: Colors.grey),
                          ),
                          Row(
                            children: [
                              InkWell(
                                  customBorder: new CircleBorder(),
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      new MaterialPageRoute(
                                        builder: (context) =>
                                            new CarRegistrationScreen(car: car),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: BrandColors.colorGreen,
                                    size: 25,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  customBorder: new CircleBorder(),
                                  onTap: () {
                                    deleteCar(context);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: BrandColors.colorGreen,
                                    size: 25,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  customBorder: new CircleBorder(),
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      new MaterialPageRoute(
                                        builder: (context) =>
                                        new TrackCarScreen(car: car),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.track_changes,
                                    color: Colors.amber,
                                    size: 25,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      /*Row(
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
                                      .rideRequestTime) //Returns Sat 20 Junro.rideStartTime.toIso8601String(),
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
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
