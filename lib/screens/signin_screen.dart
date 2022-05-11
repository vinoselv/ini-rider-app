import 'package:riderapp/providers/auth.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';
import '../screens/home.dart';
import '../screens/signup_screen.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/custom_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SigninScreen extends StatefulWidget {
  static const routeName = '/signin';

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  var userNameController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Logging you in',),
    );

    bool authResult = await Provider.of<Auth>(context, listen: false).login(
      userNameController.text,
      passwordController.text,
    ).catchError((ex) {
        //check error and display message
        Navigator.pop(context);
        showSnackBar(ex.toString());
    });
    if(authResult != null && authResult){
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
     };
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
                SizedBox(height: 70,),
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

                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      TextField(
                        controller: userNameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'User name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 40,),

                      CustomButton(
                        title: 'LOGIN',
                        color: BrandColors.colorGreen,
                        onPressed: () async {

                          //check network availability

                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No internet connectivity');
                            return;
                          }

                          login();

                        },
                      ),

                    ],
                  ),
                ),

                FlatButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, SignupScreen.routeName, (route) => false);
                  },
                    child: Text('Don\'t have an account, sign up here')
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

