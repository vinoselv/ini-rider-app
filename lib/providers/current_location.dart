import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/helpers/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CurrentLocation with ChangeNotifier {
  Position position;

  Future<void> checkPermissionAndFindLocation(context) async {
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {

      var status = await Permission.location.status;

      if(status.isGranted) {
        await getCurrentPosition(context);
      } else if (status.isDenied) {
         await [Permission.location].request();
        checkPermissionAndFindLocation(context);
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      throw Exception("Permission to access Location is denied");
    }
  }

  Future<void> getCurrentPosition(context) async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    // confirm location
    await Utils.findCordinateAddress(position, context);
    notifyListeners();
  }
}
