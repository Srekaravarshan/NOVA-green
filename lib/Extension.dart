
import 'package:flutter/material.dart';

extension Extension on Widget{

  center() {
    return Center(child: this);
  }

  padding({double left = 0, double right = 0, double top = 0, double bottom = 0}){
    return Padding(padding: EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        child: this);
  }
}