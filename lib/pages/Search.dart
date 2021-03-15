import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/widgets/FeaturedPlantCard.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  setState(() {
                    query = _searchController.text.trim();
                  });
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFF87C38F),
                  filled: true,
                  isDense: true,
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        query = _searchController.text.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ),
            query.length == 0
                ? Container(
                    height: 500,
                    child: Center(
                      child: Text('❤ Enjoy shopping ❤'),
                    ),
                  )
                : FutureBuilder<QuerySnapshot>(
                    future: productsRef
                        .where('nameFS', isGreaterThanOrEqualTo: query)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          height: 600,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
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
    );
  }
}
