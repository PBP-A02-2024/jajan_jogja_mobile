import 'package:flutter/material.dart';

AppBar headerApp(context){
  return AppBar(
    backgroundColor: Color(0xFFEBE9E1),
    title: Container(
      height: 65,
      padding: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(6.0), // Add padding to the image
        child: Image.asset(
          'assets/images/logo.png',
          height: 18,
          fit: BoxFit.fitHeight,
        ),
      ),
    ),
    centerTitle: true,
  );
}