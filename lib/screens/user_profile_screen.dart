
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:riderapp/models/user.dart';
import 'package:riderapp/providers/route_data.dart';
import 'package:riderapp/providers/auth.dart';
//import 'package:riderapp/screens/edit_user_profile_screen.dart';
import 'package:riderapp/widgets/custom_button.dart';
import 'package:riderapp/widgets/user_carbon_stats_widget.dart';
import 'package:riderapp/widgets/user_ride_stats_widget.dart';
import 'package:riderapp/widgets/profile_widget.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    return Scaffold(
          body: FutureBuilder<User>(
            future: Provider.of<Auth>(context).getLoggedInUser(),
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              if (!snapshot.hasData) {
                // while data is loading:
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // data loaded:
                final user = snapshot.data;
                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 24),
                    ProfileWidget(
                      icon: user.iconKey != null ? deserializeIcon(Utils.getIconFromKey(user.iconKey)) : Icons.add,
                      onClicked: () {
                        /*
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );*/
                      },
                      isEdit: true,
                    ),
                    const SizedBox(height: 24),
                    buildName(user),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                      padding: EdgeInsets.only(
                        bottom: 5, // Space between underline and text
                      ),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: BrandColors.colorGreen,
                            width: 1.0, // Underline thickness
                          ))
                      ),
                      child: Text(
                        "Ride Score",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal, fontSize: 20
                        ),
                      ),
                    )
                    ),
                    const SizedBox(height: 24),
                    UserRideStatsWidget(user: user,),
                    const SizedBox(height: 24),
                    Center(
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: 5, // Space between underline and text
                          ),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(
                                color: BrandColors.colorGreen,
                                width: 1.0, // Underline thickness
                              ))
                          ),
                          child: Text(
                            "Carbon Score",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal, fontSize: 20
                            ),
                          ),
                        )
                    ),
                    const SizedBox(height: 34),
                    UserCarbonStatsWidget(user: user,),
                    const SizedBox(height: 34),
                    Image(
                      height: 150.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      image: AssetImage('assets/images/save.png'),
                    ),
                    const SizedBox(height: 34),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomButton(
                        title: 'Logout',
                        color: BrandColors.colorGreen,
                        onPressed: () {
                          //Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/');

                          // Navigator.of(context)
                          //     .pushReplacementNamed(UserProductsScreen.routeName);
                          Provider.of<Auth>(context, listen: false).logout();

                        },
                      ),
                    ),
                    
                  ],
                );
              }
            },
          ),


        );
  }

  Widget buildName(User user) => Column(
    children: [
      Text(
        user.name != null ? user.name : '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      const SizedBox(height: 4),
      Text(
        user.email != null ? user.email : '',
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

}
