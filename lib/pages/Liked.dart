import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nova_green/Models/LikedModel.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:provider/provider.dart';

class Liked extends StatefulWidget {
  @override
  _LikedState createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  double totalPrice = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future getCartItems(LikedModel liked, String uid) async {
    DocumentSnapshot doc =
        await productsRef.doc(liked.productId).get().then((doc) async {
      if (doc.exists) {
        return doc;
      } else {
        await likedRef
            .doc(uid)
            .collection('liked')
            .doc(liked.productId)
            .delete();
        return null;
      }
    });
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                  stream: likedRef
                      .doc(_firebaseUser.uid)
                      .collection('liked')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    SchedulerBinding.instance
                        .addPostFrameCallback((_) => setState(() {
                              totalPrice = 0;
                            }));
                    return Column(
                      children: [
                        Container(
                          height: 55,
                          child: Center(
                            child: Text(
                              'Wish list',
                              style: TextStyle(
                                  color: Color(0xFF226F54),
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        Container(
                          height: 244,
                          width: 244,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/cart_image.png'),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(height: 25),
                        snapshot.data.docs.isEmpty
                            ? Text('No liked products')
                            : ListView.separated(
                                itemCount: snapshot.data.docs.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  LikedModel liked = LikedModel.fromDocument(
                                      snapshot.data.docs.elementAt(index));
                                  return FutureBuilder(
                                      future: getCartItems(
                                          liked, _firebaseUser.uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.data == null) {
                                          return Container(
                                            height: 300,
                                            child: Center(
                                                child:
                                                    Text('No liked products')),
                                          );
                                        }
                                        if (!snapshot.hasData) {
                                          return Container(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()));
                                        }
                                        ProductModel product =
                                            ProductModel.fromDocument(
                                                snapshot.data);

                                        SchedulerBinding.instance
                                            .addPostFrameCallback(
                                                (_) => setState(() {
                                                      totalPrice +=
                                                          double.parse(
                                                              product.price);
                                                    }));
                                        return itemCard(
                                            product.mediaUrl,
                                            product.name,
                                            product.storeName,
                                            product.price,
                                            _firebaseUser.uid,
                                            product.productId);
                                      });
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(height: 20);
                                },
                              ),
                      ],
                    );
                  }),
            ),
          ),
          Positioned(
              top: 40,
              left: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 6)
                    ], color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87)),
              )),
        ],
      ),
    );
  }

  Widget itemCard(String url, String name, String storeName, String price,
      String userId, String productId) {
    return Stack(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            height: 91,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 3),
                      blurRadius: 10)
                ]),
            child: Row(
              children: [
                Container(
                  height: 91,
                  width: 91,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFCAF),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    image: DecorationImage(
                        image: NetworkImage(url), fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 90,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text('₹ $price',
                                style: TextStyle(
                                    color: Color(0xFF226F54),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          storeName,
                          style: TextStyle(
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 10,
            right: 35,
            child: InkWell(
              onTap: () async {
                await likedRef
                    .doc(userId)
                    .collection('liked')
                    .doc(productId)
                    .delete();
                final snackBar =
                    SnackBar(content: Text('Successfully deleted.'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 3),
                        blurRadius: 6),
                  ],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete, size: 20, color: Colors.red),
              ),
            )),
        Positioned(
            bottom: 10,
            right: 35,
            child: InkWell(
              onTap: () async {
                await cartRef
                    .doc(userId)
                    .collection('cart')
                    .doc(productId)
                    .set({'productId': productId});
                final snackBar =
                    SnackBar(content: Text('Added! Enjoy your shopping.'));

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                padding: EdgeInsets.all(4),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            )),
      ],
    );
  }
}
