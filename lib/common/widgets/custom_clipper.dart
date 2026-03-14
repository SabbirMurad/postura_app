
import 'package:flutter/material.dart';

class AppCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 100);

    Offset firstPointCurve1 = Offset(400, size.height);
    Offset secondPointCurve1 = Offset(size.width, size.height);

    path.quadraticBezierTo(firstPointCurve1.dx, firstPointCurve1.dy, secondPointCurve1.dx, secondPointCurve1.dy);

    Offset firstPointCurve2 = Offset(size.width, size.height);
    Offset secondPointCurve2 = Offset(size.width, size.height);

    path.quadraticBezierTo(firstPointCurve2.dx, firstPointCurve2.dy, secondPointCurve2.dx, secondPointCurve2.dy);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}