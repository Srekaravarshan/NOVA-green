import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/widgets/FeaturedPlantCard.dart';
import 'package:provider/provider.dart';

import 'Search.dart';

class CategoryPage extends StatefulWidget {
  final String title;
  final String productType;
  final bool isCategory;

  const CategoryPage(
      {Key key,
      @required this.title,
      @required this.productType,
      this.isCategory = false})
      : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
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
              SizedBox(height: 30),
              FutureBuilder<QuerySnapshot>(
                future: widget.isCategory
                    ? productsRef
                        .where('category', isEqualTo: widget.productType)
                        .get()
                    : productsRef
                        .where('plantType', isEqualTo: widget.productType)
                        .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                        height: 600,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  List<ProductModel> products = [];
                  snapshot.data.docs.forEach((doc) {
                    products.add(ProductModel.fromDocument(doc));
                  });
                  return GridView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return plantCard(
                          products.elementAt(index),
                          _firebaseUser.uid,
                          context,
                          Colors.black,
                          Color(0xFFF4F0BB));
                    },
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(25),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.59,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
