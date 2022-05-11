import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../brand_colors.dart';
import '../globalvariable.dart';
import '../helpers/requesthelper.dart';
import '../models/place.dart';
import '../models/prediction.dart';
import '../widgets/ProgressDialog.dart';

class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(Prediction prediction, context) async {
    String placeId = prediction.placeId;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$mapKey';
    print(url);
    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if(response == 'failed'){
      return;
    }

    if(response['status'] == 'OK') {
      Place thisPlace = Place();
      thisPlace.name = response['result']['name'];
      thisPlace.id = placeId;
      thisPlace.latitude = response ['result']['geometry']['location']['lat'];
      thisPlace.longitude = response ['result']['geometry']['location']['lng'];
      thisPlace.address = response['result']['formatted_address'];

      print(thisPlace.name);
      prediction.onSelect(thisPlace);
/*
      if (prediction.origin) {
        Provider.of<RouteData>(context, listen: false).updatePickupAddress(thisPlace);
      } else {
        Provider.of<RouteData>(context, listen: false).updateDestinationAddress(thisPlace);
        Navigator.pop(context, 'getDirection');
      }
    }

 */
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children: <Widget>[
                Icon(OMIcons.locationOn, color: BrandColors.colorDimText,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(prediction.mainText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16),),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: BrandColors.colorDimText),),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),

          ],
        ),
      ),
    );
  }
}