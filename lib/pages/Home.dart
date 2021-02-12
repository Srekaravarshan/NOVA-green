import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 55,
            child: Center(
              child: Text(
                'NOVA green',
                style: TextStyle(
                    color: Color(0xFF226F54),
                    fontSize: 20,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          SizedBox(height: 60),
          Text('Hi, ${_firebaseUser.displayName}!')
        ],
      ),
    );
  }
}
