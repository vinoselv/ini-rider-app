import 'dart:convert';

import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/providers/auth.dart';
import 'package:riderapp/screens/home.dart';
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

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Icon _icon;

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context,
        showSearchBar: false,
        iconPackModes: [],
        iconColor: BrandColors.colorGreen,
        customIconPack: initialiseIconMap());

    if (icon != null) {
      debugPrint('Resetting _icon');
      _icon = Icon(
        icon,
        color: Colors.white,
        size: 40,
      );
    }
    setState(() {});

    debugPrint('Picked Icon:  $icon');
  }

  Map<String, IconData> initialiseIconMap() {
    return {
      "cat": FontAwesomeIcons.cat,
      //"cow" : FontAwesomeIcons.cow,
      "crow": FontAwesomeIcons.crow,
      "dog": FontAwesomeIcons.dog,
      "dove": FontAwesomeIcons.dove,
      "dragon": FontAwesomeIcons.dragon,
      "fish": FontAwesomeIcons.fish,
      "frog": FontAwesomeIcons.frog,
      "hippo": FontAwesomeIcons.hippo,
      "horse": FontAwesomeIcons.horse,
      //"locust" : FontAwesomeIcons.locust,
      //"mosquito" : FontAwesomeIcons.mosquito,
      "otter": FontAwesomeIcons.otter,
      "paw": FontAwesomeIcons.paw,
      //"shrimp" : FontAwesomeIcons.shrimp,
      "spider": FontAwesomeIcons.spider,
      //"worm" : FontAwesomeIcons.worm
    };
  }

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

  var userNameController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering you...',
      ),
    );

    String iconKey = Utils.getIconKey(serializeIcon(_icon.icon));

    // Sign user up
    bool signupResult = await Provider.of<Auth>(context, listen: false)
        .signup(emailController.text, userNameController.text,
            passwordController.text, iconKey)
        .catchError((ex) {
      //check error and display message
      Navigator.pop(context);
      showSnackBar(ex.toString());
    });

    // check if user registration is successful
    if (signupResult != null && signupResult) {
      Navigator.pop(context);
      //Take the user to the mainPage
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Image border
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(78), // Image radius
                    child: Image(
                      height: 150.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      image: AssetImage('assets/images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _pickIcon,
                  child: _icon ??
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: BrandColors.colorGreen, // <-- Button color
                    onPrimary: Colors.blue, // <-- Splash color
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Select your profile Icon'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      // Fullname
                      TextField(
                        controller: userNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'User name',
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email',
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
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
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
                        title: 'REGISTER',
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

                          debugPrint("_icon : $_icon");
                          if (_icon == null) {
                            showSnackBar('Please select a profile icon');
                            return;
                          }

                          if (userNameController.text.length < 5) {
                            showSnackBar('Please provide a valid fullname');
                            return;
                          }

                          if (!emailController.text.contains('@')) {
                            showSnackBar(
                                'Please provide a valid email address');
                            return;
                          }

                          if (passwordController.text.length < 5) {
                            showSnackBar(
                                'password must be at least 8 characters');
                            return;
                          }

                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, SigninScreen.routeName, (route) => false);
                    },
                    child: Text('Already have a account? Log in')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
