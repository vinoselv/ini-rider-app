import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riderapp/brand_colors.dart';

class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final bool isEdit;
  final double size;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key key,
    this.icon,
    this.isEdit = false,
    this.onClicked,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: isEdit ? buildEditIcon(color) : new Container(),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {

    return ElevatedButton(
      onPressed: () => {},
      child: Icon(icon, color: Colors.white, size: size,),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(size-10),
        primary: BrandColors.colorGreen, // <-- Button color
        onPrimary: Colors.blue, // <-- Splash color
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: BrandColors.colorGreen,
          all: 8,
          child: Icon(
            //isEdit ? Icons.add_a_photo : Icons.edit,
            Icons.star,
            color: Colors.white,
            size: size-30,
          ),
        ),
      );

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
