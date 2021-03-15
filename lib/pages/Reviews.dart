import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/Models/StoreModel.dart';
import 'package:nova_green/main.dart';
import 'package:timeago/timeago.dart' as timeago;

class Reviews extends StatefulWidget {
  final String storeId;
  final String productId;
  final String userId;

  const Reviews({Key key, this.storeId, this.productId, @required this.userId})
      : super(key: key);

  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: widget.storeId != null
            ? sellersRef.doc(widget.storeId).snapshots()
            : productsRef.doc(widget.productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                height: MediaQuery.of(context).size.height,
                child: Center(child: CircularProgressIndicator()));
          }
          StoreModel sModel;
          ProductModel pModel;
          if (widget.storeId != null) {
            sModel = StoreModel.fromDocument(snapshot.data);
          } else {
            pModel = ProductModel.fromDocument(snapshot.data);
          }
          List ratingMap;
          Map reviewedUsers;
          if (sModel != null) {
            ratingMap = sModel.ratingMap;
            reviewedUsers = sModel.reviewedUsers;
          } else {
            ratingMap = pModel.ratingMap;
            reviewedUsers = pModel.reviewedUsers;
          }
          return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 25),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            backgroundImage: NetworkImage(
                                ratingMap.elementAt(index)['userProfile']),
                            radius: 24),
                        SizedBox(width: 8),
                        Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              ratingMap
                                                  .elementAt(index)['username'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                          SizedBox(height: 8),
                                          ratingMap.elementAt(
                                                      index)['comment'] ==
                                                  ''
                                              ? Container()
                                              : Container(
                                                  child: Text(
                                                    ratingMap.elementAt(
                                                        index)['comment'],
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    ratingMap.elementAt(index)['userId'] ==
                                            widget.userId
                                        ? PopupMenuButton(
                                            itemBuilder: (BuildContext bc) => [
                                              PopupMenuItem(
                                                  child: Text("Edit"),
                                                  value: "Edit"),
                                              PopupMenuItem(
                                                  child: Text("Delete"),
                                                  value: "Delete"),
                                            ],
                                            onSelected: (route) async {
                                              if (route == 'Delete') {
                                                ratingMap.removeAt(index);
                                                reviewedUsers
                                                    .remove(widget.userId);
                                                if (widget.storeId != null) {
                                                  await sellersRef
                                                      .doc(sModel.userId)
                                                      .update({
                                                    'ratingMap': ratingMap,
                                                    'reviewedUsers':
                                                        reviewedUsers
                                                  });
                                                } else {
                                                  await productsRef
                                                      .doc(pModel.productId)
                                                      .update({
                                                    'ratingMap': ratingMap,
                                                    'reviewedUsers':
                                                        reviewedUsers
                                                  });
                                                }
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      double ratingStar = 3;
                                                      _reviewController.text =
                                                          ratingMap.elementAt(
                                                              index)['comment'];
                                                      return AlertDialog(
                                                        title:
                                                            Text('Edit Review'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Center(
                                                              child: RatingBar
                                                                  .builder(
                                                                initialRating: (ratingMap
                                                                        .elementAt(
                                                                            index)['rating'])
                                                                    .toDouble(),
                                                                minRating: 1,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    false,
                                                                itemCount: 5,
                                                                // glow: false,
                                                                updateOnDrag:
                                                                    true,
                                                                itemBuilder:
                                                                    (context,
                                                                            _) =>
                                                                        Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                                onRatingUpdate:
                                                                    (rating) {
                                                                  setState(() {
                                                                    ratingStar =
                                                                        rating;
                                                                    print(
                                                                        ratingStar);
                                                                  });
                                                                  print(
                                                                      ratingStar);
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15),
                                                            TextFormField(
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                border:
                                                                    OutlineInputBorder(),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors.grey[
                                                                        200],
                                                                hintText:
                                                                    'Type here something...',
                                                              ),
                                                              maxLines: null,
                                                              controller:
                                                                  _reviewController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .name,
                                                              minLines: 5,
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'Cancel')),
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                ratingMap.elementAt(
                                                                            index)[
                                                                        'comment'] =
                                                                    _reviewController
                                                                        .text
                                                                        .trim();
                                                                ratingMap.elementAt(
                                                                            index)[
                                                                        'rating'] =
                                                                    ratingStar
                                                                        .toDouble();
                                                                if (widget
                                                                        .storeId !=
                                                                    null) {
                                                                  await sellersRef
                                                                      .doc(sModel
                                                                          .userId)
                                                                      .update({
                                                                    'ratingMap':
                                                                        ratingMap
                                                                  });
                                                                } else {
                                                                  await productsRef
                                                                      .doc(pModel
                                                                          .productId)
                                                                      .update({
                                                                    'ratingMap':
                                                                        ratingMap,
                                                                  });
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'Update'))
                                                        ],
                                                      );
                                                    });
                                              }
                                            },
                                          )
                                        : Container(),
                                  ],
                                ),
                                ratingMap.elementAt(index)['comment'] == ''
                                    ? Container()
                                    : SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 14,
                                      child: ListView.builder(
                                        itemCount: 5,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (context, starI) => Icon(
                                            Icons.star,
                                            size: 14,
                                            color: starI <
                                                    ratingMap.elementAt(
                                                        index)['rating']
                                                ? Color(0xFF226F54)
                                                : Colors.grey),
                                      ),
                                    ),
                                    Text(
                                      timeago.format(DateTime.parse(ratingMap
                                          .elementAt(index)['timeStamp']
                                          .toDate()
                                          .toString())),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF226F54)),
                                    )
                                  ],
                                )
                              ]),
                        ),
                      ],
                    ),
                  ),
              separatorBuilder: (context, index) => Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Divider(
                        height: 30,
                      ),
                    ),
                  ),
              itemCount: ratingMap.length);
        },
      ),
    );
  }
}
