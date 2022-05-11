import 'package:flutter/material.dart';
import 'package:riderapp/models/user.dart';

class UserRideStatsWidget extends StatelessWidget {
  final User user;
  bool includeRequests;

  UserRideStatsWidget({Key key, this.user, this.includeRequests = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, '4.8', 'average rating', true),
          buildDivider(),
          buildButton(context, '35', 'rides offered', false),
          includeRequests ? buildDivider() : new Container(),
          includeRequests
              ? buildButton(context, '50', 'rides requested',false)
              : new Container(),
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text, bool includeStar) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              if (includeStar) Icon(
                Icons.star,
                color: Colors.amber,
                size: 30,
              )
            ]),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}
