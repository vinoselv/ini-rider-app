import 'package:riderapp/providers/ride_request.dart';

class SearchResultsScreenArguments {
  final RideRequest rideRequest;
  final Function goToRidesScreen;

  SearchResultsScreenArguments(this.rideRequest, this.goToRidesScreen);
}