import 'package:flutter/material.dart';

Color backgroundColor = Color(0xFFFFFFFF);
Color secondaryColor = Color(0xFFFF7357);
Color secondaryDark = Color(0xFFFC5956);
Color iconColor = Color(0xFFE62622);
Color yellowColor = Color(0xFFFFE957);
Color blueColor = Color(0xFF004CFF);
Color sheetColor = Color(0xFF2A2A2A);

CircularProgressIndicator circularProgressIndicator() {
  return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor));
}

LinearProgressIndicator linearProgressIndicator() {
  return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor));
}