import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riderapp/providers/current_location.dart';
import 'package:riderapp/providers/rides.dart';
import 'package:riderapp/providers/route_data.dart';
import 'package:riderapp/screens/car_registration.dart';
import 'package:riderapp/screens/home.dart';
import 'package:riderapp/screens/ride_offer_details_screen.dart';
import 'package:riderapp/screens/rides_screen.dart';
import 'package:riderapp/screens/search_destination.dart';
import 'package:riderapp/screens/search_results_screen.dart';
import 'package:riderapp/screens/search_rides.dart';
import 'package:riderapp/screens/signin_screen.dart';
import 'package:riderapp/screens/signup_screen.dart';
import 'package:riderapp/screens/track_ride_screen.dart';
import 'package:riderapp/screens/track_screen.dart';
import 'package:provider/provider.dart';

import './helpers/custom_route.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: RouteData(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: CurrentLocation(),
        ),
        ChangeNotifierProxyProvider<Auth, Rides>(
          create: (_) => Rides('', null, ''),
          update: (_, auth, previousRideOffers) {
            return Rides(
              auth.token,
              auth.user,
              auth.awsBaseUrl
            );
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: MaterialApp(
            title: 'iNi Rider',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                },
              ),
            ),
            home: auth.isAuth
                ? HomeScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : SigninScreen(),
                  ),
            routes: {
              SearchDestinationScreen.routeName: (ctx) =>
                  SearchDestinationScreen(),
              SearchRidesScreen.routeName: (ctx) => SearchRidesScreen(),
              SigninScreen.routeName: (ctx) => SigninScreen(),
              SignupScreen.routeName: (ctx) => SignupScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              RidesScreen.routeName: (ctx) => RidesScreen(),
              SearchResultsScreen.routeName: (ctx) => SearchResultsScreen(),
              RideOfferDetailsScreen.routeName: (ctx) =>
                  RideOfferDetailsScreen(),
              CarRegistrationScreen.routeName: (ctx) => CarRegistrationScreen(),
              TrackScreen.routeName: (ctx) => TrackScreen(),
              TrackRideScreen.routeName: (ctx) => TrackRideScreen()
            },
          ),
        ),
      ),
    );
  }
}
