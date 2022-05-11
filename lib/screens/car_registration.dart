import 'dart:convert';

import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/providers/car.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/screens/home.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';
import '../screens/signin_screen.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/custom_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarRegistrationScreen extends StatefulWidget {
  static const routeName = '/carreg';

  final Car car;

  const CarRegistrationScreen({Key key, this.car}) : super(key: key);

  @override
  _CarRegistrationScreenState createState() => _CarRegistrationScreenState();
}

class _CarRegistrationScreenState extends State<CarRegistrationScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  var makeController = TextEditingController();
  var modelController = TextEditingController();
  var yearController = TextEditingController();
  var regNumberController = TextEditingController();

  var thingyImeiNumberController = TextEditingController();

  void updateCar() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Updating your car...',
      ),
    );

    Car car = new Car(
        make: makeController.text,
        model: modelController.text,
        year: int.parse(yearController.text),
        registrationNumber: regNumberController.text,
        thingy91ImeiNumber: int.parse(thingyImeiNumberController.text));

    // Sign user up
    await Provider.of<Rides>(context, listen: false).updateCar(car).then((value) {
      print("--> COMING HERE :(");
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((ex) {
      print("--> " + ex);
      //check error and display message
      Navigator.pop(context);
      showSnackBar(ex);
    });
  }

  void registerCar() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering your car...',
      ),
    );

    Car car = new Car(
        make: makeController.text,
        model: modelController.text,
        year: int.parse(yearController.text),
        registrationNumber: regNumberController.text,
        thingy91ImeiNumber: int.parse(thingyImeiNumberController.text));

    // Sign user up
    await Provider.of<Rides>(context, listen: false).postCar(car).then((value) {
      print("--> COMING HERE :(");
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((ex) {
      print("--> " + ex);
      //check error and display message
      Navigator.pop(context);
      showSnackBar(ex);
    });
  }

  @override
  Widget build(BuildContext context) {
    Car _car = widget.car;

    if (_car != null) {
      makeController.text = _car.make;
      modelController.text = _car.model;
      yearController.text = _car.year.toString();
      regNumberController.text = _car.registrationNumber;
      thingyImeiNumberController.text = _car.thingy91ImeiNumber.toString();
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
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
                    _car == null ? 'Register Your Car' : "Update Your Car",
                    style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                ProfileWidget(
                    icon: Icons.directions_car,
                    onClicked: () {
                      /*
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );*/
                    },
                    isEdit: true),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      // Fullname
                      TextField(
                        controller: makeController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Make',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      // Email Address
                      TextField(
                        controller: modelController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Model',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      // Password
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Year',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      // Password
                      TextField(
                        controller: regNumberController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Registration number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Image(
                        height: 150.0,
                        alignment: Alignment.center,
                        image: AssetImage('assets/images/thingy91.png'),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      // Password
                      TextField(
                        controller: thingyImeiNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Thingy 91 IMEI Number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(
                        height: 40,
                      ),

                      CustomButton(
                        title: _car == null ? 'REGISTER' : 'SAVE',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          //check network availability

                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No internet connectivity');
                            return;
                          }
/*
                          if(makeController.text.isEmpty){
                            showSnackBar('Please provide a car make');
                            return;
                          }

                          if(modelController.text.isEmpty){
                            showSnackBar('Please provide a car model');
                            return;
                          }
*/
                          if (yearController.text.isEmpty) {
                            showSnackBar(
                                'Please provide a car manufacturing year');
                            return;
                          } else {
                            RegExp _numeric = RegExp(r'^-?[0-9]{4}$');
                            if (!_numeric.hasMatch(yearController.text)) {
                              showSnackBar('Please enter a valid year');
                              return;
                            }
                          }

                          if (regNumberController.text.isEmpty) {
                            showSnackBar(
                                'Please provide a car registration number');
                            return;
                          } else {
                            RegExp _numeric = RegExp(r'^[A-Za-z]{3}-[0-9]{3}$');
                            if (!_numeric.hasMatch(regNumberController.text)) {
                              showSnackBar(
                                  'Please enter a valid car registration number');
                              return;
                            }
                          }

                          if (thingyImeiNumberController.text.isEmpty) {
                            showSnackBar(
                                'Please provide a Nordic thingy 91 IMEI number');
                            return;
                          } else {
                            RegExp _numeric = RegExp(r'^-?[0-9]{15}$');
                            if (!_numeric
                                .hasMatch(thingyImeiNumberController.text)) {
                              showSnackBar('Please enter a valid IMEI number');
                              return;
                            }
                          }

                          if (_car != null) {
                            updateCar();
                          } else {
                            registerCar();
                          }

                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
