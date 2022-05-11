import '../models/place.dart';
import 'package:flutter/cupertino.dart';

class RouteData extends ChangeNotifier{

  Place pickupAddress;
  Place destinationAddress;

  void updatePickupAddress(Place pickup){
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress (Place destination){
    destinationAddress = destination;
    notifyListeners();
  }

}