import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/AuthService.dart';
import 'package:nova_green/pages/Addresses.dart';
import 'package:nova_green/pages/AgreeForSell.dart';
import 'package:nova_green/pages/Cart.dart';
import 'package:nova_green/pages/Liked.dart';
import 'package:nova_green/pages/News.dart';
import 'package:nova_green/pages/SavedBlogs.dart';
import 'package:nova_green/pages/YourOrder.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final User _user = context.watch<User>();

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/profile_bg.png'),
                  alignment: Alignment.topCenter)),
        ),
        SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        children: [
                          SizedBox(height: 70),
                          Text(
                            _user.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 50),
                          profileDivider(),
                          profileTile(
                              title: 'Your Orders',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => YourOrder()));
                              }),
                          profileDivider(),
                          profileTile(
                              title: 'Addresses',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Addresses()));
                              }),
                          profileTile(title: 'Purchases', onPressed: () {}),
                          profileDivider(),
                          profileTile(
                              title: 'My store',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Agree()));
                              }),
                          profileDivider(),
                          profileTile(
                              title: 'My posts',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            News(userId: _user.uid)));
                              }),
                          profileTile(
                              title: 'Saved posts',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SavedBlogs(userId: _user.uid)));
                              }),
                          profileDivider(),
                          profileTile(
                              title: 'Wish List',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Liked()));
                              }),
                          profileTile(
                              title: 'Cart',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Cart()));
                              }),
                          profileDivider(),
                          profileTile(
                              title: 'Logout',
                              onPressed: () async {
                                await context.read<AuthService>().signOut();
                              }),
                          profileDivider(),
                          SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 140,
                child: Stack(
                  children: [
                    Container(
                      height: 115,
                      width: 115,
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey[100],
                          image: DecorationImage(
                              image: NetworkImage(_user.photoURL),
                              fit: BoxFit.cover),
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    Positioned(
                        bottom: -6,
                        child:
                            Image.asset('assets/images/profile_leaf_left.png')),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                            'assets/images/profile_leaf_right.png')),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Divider profileDivider() {
    return Divider(color: Colors.black38, height: 12);
  }

  InkWell profileTile({String title, Function onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(maxWidth: 250),
        child: Column(
          children: [
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 18)),
                Icon(Icons.navigate_next_rounded)
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
