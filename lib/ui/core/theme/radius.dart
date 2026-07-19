import 'package:flutter/material.dart';

class RadiusConstants {
  RadiusConstants._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  static BorderRadius only({
    double tl = 0,
    double tr = 0,
    double bl = 0,
    double br = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(tl),
        topRight: Radius.circular(tr),
        bottomLeft: Radius.circular(bl),
        bottomRight: Radius.circular(br),
      );
}
