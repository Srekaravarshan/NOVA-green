import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/Search.dart';
import 'package:nova_green/pages/categoryPage.dart';
import 'package:nova_green/widgets/FeaturedPlantCard.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NOVA green',
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(fontFamily: 'Ubuntu'),
                      children: [
                        TextSpan(
                            text: 'You are going to\n',
                            style:
                                TextStyle(fontSize: 32, color: Colors.black)),
                        TextSpan(
                            text: 'ENJOY ',
                            style: TextStyle(
                                fontSize: 50,
                                color: Color(0xFFFFCC00),
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'this!',
                            style: TextStyle(fontSize: 32, color: Colors.black))
                      ]),
                ),
              ),
              SizedBox(height: 40),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Search()));
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                      color: Color(0xFF87C38F),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        Icon(Icons.search, color: Colors.white70)
                      ]),
                ),
              ),
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text('Shop by category',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 30),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 20,
                    runSpacing: 28,
                    children: [
                      categoryWidget(
                          'assets/images/herbs.png', 'Herbs', 'Herb', false),
                      categoryWidget(
                          'assets/images/shrubs.png', 'Shrubs', 'Shrub', false),
                      categoryWidget(
                          'assets/images/trees.png', 'Trees', 'Tree', false),
                      categoryWidget('assets/images/climbers.png', 'Climbers',
                          'Climber', false),
                      categoryWidget('assets/images/creepers.png', 'Creepers',
                          'Creeper', false),
                      categoryWidget(
                          'assets/images/indoor.png', 'Indoor', 'Indoor', true),
                      categoryWidget('assets/images/outdoor.png', 'Outdoor',
                          'Outdoor', true),
                      categoryWidget(
                          'assets/images/garden.png', 'Garden', 'Garden', true),
                      categoryWidget('assets/images/decoration.png',
                          'Decorations', 'Decoration', true),
                      categoryWidget('assets/images/aquatic.png', 'Aquatics',
                          'Aquatic', true),
                    ],
                    direction: Axis.horizontal,
                  )),

              // featured Plants

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Featured plants',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .orderBy('rating', descending: true)
                        .orderBy('ratingMap', descending: true)
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.white,
                                  Color(0xFFDA2C38));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // seeds

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Seeds',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('productType', isEqualTo: 'Seed')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.white,
                                  Color(0xFFDA2C38));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // herbs Plants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Herbs',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('plantType', isEqualTo: 'Herb')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.black,
                                  Color(0xFFF4F0BB).withOpacity(0.30));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // shrubs Plants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Shrubs',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('plantType', isEqualTo: 'Shrub')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.black,
                                  Color(0xFFF4F0BB).withOpacity(0.30));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // trees Plants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Trees',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('plantType', isEqualTo: 'Tree')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.black,
                                  Color(0xFFF4F0BB).withOpacity(0.30));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // climbers Plants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Climbers',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('plantType', isEqualTo: 'Climber')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.black,
                                  Color(0xFFF4F0BB).withOpacity(0.30));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // creepers Plants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Creepers',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('plantType', isEqualTo: 'Creeper')
                        .limit(10)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                              Container(
                                height: 288,
                                width: 170,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 25),
                            ],
                          ),
                        );
                      }
                      List<ProductModel> products = [];
                      snapshot.data.docs.forEach((doc) {
                        products.add(ProductModel.fromDocument(doc));
                      });
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 288,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return plantCard(
                                  products.elementAt(index),
                                  _firebaseUser.uid,
                                  context,
                                  Colors.black,
                                  Color(0xFFF4F0BB).withOpacity(0.30));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(width: 20);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // bottom

              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, bottom: 50),
                child: Text(
                  'NOVA green',
                  style: TextStyle(
                      color: Color(0xFF226F54),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryWidget(
      String url, String title, String productType, bool isCategory) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CategoryPage(title: title, productType: productType)));
      },
      child: Column(
        children: [
          CircleAvatar(
              backgroundImage: AssetImage(url),
              radius: 35,
              backgroundColor: Colors.grey[200]),
          SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 15))
        ],
      ),
    );
  }
}
