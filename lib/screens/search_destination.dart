import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';
import '../globalvariable.dart';
import '../helpers/requesthelper.dart';
import '../models/prediction.dart';
import '../providers/route_data.dart';
import '../widgets/BrandDivier.dart';
import '../widgets/PredictionTile.dart';

class SearchDestinationScreen extends StatefulWidget {
  static const routeName = '/search-destination';
  final Position position;

  const SearchDestinationScreen({Key key, this.position}) : super(key: key);

  @override
  _SearchDestinationScreenState createState() => _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {

  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();
  //var focusOrigin = FocusNode();

  bool focused = false;

  /*
  @override
  void initState() {
    super.initState();
    focusOrigin.addListener(_onOriginFocusChange);
    focusDestination.addListener(_onDestinationFocusChange);
  }

  /*
  @override
  void dispose() {
    super.dispose();
    focusOrigin.removeListener(_onOriginFocusChange);
    //focusOrigin.dispose();

    focusDestination.removeListener(_onDestinationFocusChange);
    //focusDestination.dispose();
  }*/

  void _onOriginFocusChange() {

    if (focusOrigin.hasFocus) {

    } else {

    }

    setState(() {
      //pickupController.text =  Provider.of<RouteData>(context, listen: false).pickupAddress?.address ?? '';
    });
    debugPrint("Focus: ${focusOrigin.hasFocus.toString()}");
  }

  void _onDestinationFocusChange() {

      placesPredictionList.clear();

    debugPrint("Focus: ${focusOrigin.hasFocus.toString()}");
  }

  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }
*/
  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }
  List<Prediction> placesPredictionList = [];

  void searchPlace(String placeName, Function onSelect) async {

    if(placeName.length > 1){
      String position = widget.position.latitude.toString() + '%2C' + widget.position.longitude.toString();

      String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&location=$position&sessiontoken=123254251';
      print("Search URL : " + url);
      var response = await RequestHelper.getRequest(url);

      if(response == 'failed'){
        return;
      }

      if(response['status'] == 'OK'){
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List).map((e) => Prediction.fromJson(e, onSelect)).toList();
        setState(() {
          placesPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    setFocus();

    String address = Provider.of<RouteData>(context).pickupAddress?.displayName ?? '';
    //pickupController.text = address;

    //pickupController.text = Provider.of<RouteData>(context).pickupAddress;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ]
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 24, top: 63, right: 24, bottom: 20),
              child: Column(
                children: <Widget>[

                  SizedBox(height: 5,),
                  Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap:(){
                          Navigator.pop(context);
                      },
                          child: Icon(Icons.arrow_back)
                      ),
                      Center(
                        child: Text('Search destination',
                          style: TextStyle(fontSize: 20,fontFamily: 'Brand-Bold' ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18,),

                  Row(
                    children: <Widget>[
                      Image.asset('assets/images/pickicon.png', height: 16, width: 16,),

                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value){
                                searchPlace(value, (place) {
                                  Provider.of<RouteData>(context, listen: false).updatePickupAddress(place);
                                  setState(() {
                                    pickupController.text =  Provider.of<RouteData>(context, listen: false).pickupAddress?.displayName ?? '';
                                    pickupController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
                                  });
                                });
                              },
                              //focusNode: focusOrigin,
                              controller: pickupController,
                              decoration: InputDecoration(
                                hintText: address,
                                fillColor: BrandColors.colorLightGrayFair,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10,),

                  Row(
                    children: <Widget>[
                      Image.asset('assets/images/desticon.png', height: 16, width: 16,),

                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(2.0),
                            child: TextField(
                              onTap: () {
                                setState(() {
                                  placesPredictionList = [];
                                });
                              },
                              onChanged: (value){
                                searchPlace(value, (place) {
                                  Provider.of<RouteData>(context, listen: false).updateDestinationAddress(place);
                                  setState(() {
                                    destinationController.text =  Provider.of<RouteData>(context, listen: false).destinationAddress?.displayName ?? '';
                                  });
                                  Navigator.pop(context, 'getDirection');
                                });
                              },
                              focusNode: focusDestination,
                              controller: destinationController,
                              decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10, top: 8, bottom: 8)
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          (placesPredictionList.length > 0) ?
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.all(0),
                itemBuilder: (context, index){
                  return PredictionTile(
                    prediction: placesPredictionList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => BrandDivider(),
                itemCount: placesPredictionList.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ),
          )
              : Container(),

        ],
      ),
    );
  }
}


