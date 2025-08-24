import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lighttheme = ThemeData(
  useMaterial3: false,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    titleSpacing: 20.0,
    iconTheme: IconThemeData(
        color: Colors.blueGrey
    ),
    systemOverlayStyle:  SystemUiOverlayStyle(
      statusBarColor:HexColor('333739'),
      statusBarIconBrightness:Brightness.light,

    ),
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),

  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blueGrey,
    unselectedItemColor: Colors.grey,
    elevation: 20.0,
    backgroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white, // Set card background to black in light mode
  dialogBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontFamily: 'roboto',
        height: 1.3
    ),
    titleLarge: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontFamily: 'roboto',
      height: 1.3,
    ),

    bodyLarge: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
    )

  ),
  fontFamily: 'roboto',
);
ThemeData darktheme = ThemeData(
  useMaterial3: false,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    titleSpacing: 20.0,
    iconTheme: IconThemeData(
      color: Colors.blueGrey,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.grey[900],
      statusBarIconBrightness: Brightness.light,
    ),
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blueGrey[200],
    unselectedItemColor: Colors.grey,
    elevation: 20.0,
    backgroundColor: Colors.grey[900],
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  cardColor: Colors.grey[850],
  dialogBackgroundColor: Colors.grey[850],
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
    ),

    titleMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontFamily: 'roboto',
      height: 1.3,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontFamily: 'roboto',
      height: 1.3,
    )
  ),
  fontFamily: 'roboto', dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
);