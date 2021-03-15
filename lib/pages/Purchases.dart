import 'package:flutter/material.dart';

class Purchases extends StatefulWidget {
  @override
  _PurchasesState createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Container(child: Center(child: Text('Not purchased any products.'))),
    );
  }
}
