import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/pages/ShowProduct.dart';

Widget productCard(ProductModel product, BuildContext context, String userId) {
  String tag = 'productImageCart';
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowProduct(
                    productId: product.productId,
                    userId: userId,
                    tag: tag,
                  )));
    },
    child: Container(
      height: 250,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: [
          Hero(
            tag: tag,
            child: Container(
              height: 120,
              width: 180,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Color(0xFFF4F0BB),
                  border: Border.all(color: Colors.grey[200]),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(product.mediaUrl),
                      fit: BoxFit.cover)),
            ),
          ),
          Container(
            height: 120,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF43291F),
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('₹ ${product.price}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF226F54),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.storeName,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF226F54),
                                  fontStyle: FontStyle.italic)),
                          SizedBox(
                            height: 18,
                            child: ListView.builder(
                              itemCount: 5,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Icon(Icons.star,
                                  size: 18,
                                  color: index < product.rating
                                      ? Color(0xFF226F54)
                                      : Colors.grey),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 90,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF226F54),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.add_shopping_cart_rounded,
                          size: 22, color: Colors.white),
                      Icon(Icons.favorite_border, size: 22, color: Colors.white)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
