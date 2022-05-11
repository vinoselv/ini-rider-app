import 'package:flutter/material.dart';
import 'package:riderapp/screens/car_registration.dart';
import 'package:riderapp/widgets/profile_widget.dart';

class AddCarItem extends StatelessWidget {

  AddCarItem();

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Card(
       child: InkWell(
        onTap: () {
      Navigator.of(context, rootNavigator: true).push(new MaterialPageRoute(
          builder: (context) =>
          new CarRegistrationScreen())
      );
    },
    child:  Padding(
          padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
            Column(
              //width: 100,
              children: <Widget>[
                ProfileWidget(
                  icon: Icons.add,
                  onClicked: () {},
                  isEdit: false,
                  size: 30,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "ABC-123",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(left: 16.0)),
                Expanded(
                  child:
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Add your car to track it live :)",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),
          ]),
        ]
      ),
    )));
  }
}
