import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/ShowProduct.dart';

Widget featuredPlantCard(
    ProductModel product, String userId, BuildContext context) {
  return Column(
    children: [
      Stack(
        children: [
          Container(
            height: 230,
            width: 170,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              image: DecorationImage(
                image: NetworkImage(product.mediaUrl),
                fit: BoxFit.cover,
              ),
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          Positioned(
              bottom: 54,
              right: 10,
              child: InkWell(
                onTap: () async {
                  await likedRef
                      .doc(userId)
                      .collection('liked')
                      .doc(product.productId)
                      .set({'productId': product.productId});
                  final snackBar =
                      SnackBar(content: Text('Liked! Enjoy your shopping.'));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFDA2C38)),
                  child: Icon(Icons.favorite_border,
                      size: 20, color: Colors.white),
                ),
              )),
          Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: () async {
                  await cartRef
                      .doc(userId)
                      .collection('cart')
                      .doc(product.productId)
                      .set({'productId': product.productId});
                  final snackBar =
                      SnackBar(content: Text('Added! Enjoy your shopping.'));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF226F54)),
                  child: Icon(Icons.add_shopping_cart,
                      size: 20, color: Colors.white),
                ),
              ))
        ],
      ),
      Container(
        width: 170,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 2),
                Text(product.storeName,
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF226F54),
                        fontStyle: FontStyle.italic))
              ],
            ),
            Text(
              '₹ ${product.price}',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      )
    ],
  );
}

Widget plantCard(ProductModel product, String userId, BuildContext context,
    Color textColor, Color backgroundColor) {
  String tag = 'productImageHome';
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowProduct(
                    userId: userId,
                    productId: product.productId,
                    tag: tag,
                  )));
    },
    child: AspectRatio(
      aspectRatio: 170 / 288,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 170 / 230,
                  child: Container(
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        image: NetworkImage(product.mediaUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 54,
                    right: 10,
                    child: InkWell(
                      onTap: () async {
                        await likedRef
                            .doc(userId)
                            .collection('liked')
                            .doc(product.productId)
                            .set({'productId': product.productId});
                        final snackBar = SnackBar(
                            content: Text('Liked! Enjoy your shopping.'));

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFDA2C38)),
                        child: Icon(Icons.favorite_border,
                            size: 20, color: Colors.white),
                      ),
                    )),
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () async {
                        await cartRef
                            .doc(userId)
                            .collection('cart')
                            .doc(product.productId)
                            .set({'productId': product.productId});
                        final snackBar = SnackBar(
                            content: Text('Added! Enjoy your shopping.'));

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF226F54)),
                        child: Icon(Icons.add_shopping_cart,
                            size: 20, color: Colors.white),
                      ),
                    ))
              ],
            ),
            Container(
              width: 170,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor),
                      ),
                      SizedBox(height: 2),
                      Text(product.storeName,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: textColor))
                    ],
                  ),
                  Text(
                    '₹ ${product.price}',
                    style: TextStyle(fontSize: 18, color: textColor),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
