import 'package:flutter/material.dart';

class YourOrder extends StatefulWidget {
  @override
  _YourOrderState createState() => _YourOrderState();
}

class _YourOrderState extends State<YourOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blog posts',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        child: Center(child: Text('No orders yet.')),
      ),
    );
  }
}
