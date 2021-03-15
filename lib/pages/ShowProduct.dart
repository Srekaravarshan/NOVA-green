import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/Models/StoreModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/CreateProduct.dart';
import 'package:nova_green/pages/Reviews.dart';
import 'package:nova_green/pages/Store.dart';
import 'package:nova_green/widgets/FeaturedPlantCard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'PhotoViewer.dart';

class ShowProduct extends StatefulWidget {
  final String productId;
  final String userId;
  final String tag;

  const ShowProduct(
      {Key key,
      @required this.userId,
      @required this.productId,
      @required this.tag})
      : super(key: key);

  @override
  _ShowProductState createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  IconData shadeIcon;
  File file;
  String uuid = Uuid().v4();
  bool isImageUploading = false;
  bool isOwner;
  double rating = 3;
  final TextEditingController _reviewController = TextEditingController();

  handleTakePhoto() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    this.file = file;
    setState(() {});
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.file = file;
    setState(() {});
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Photo with Camera"),
                ),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Image from Gallery"),
                ),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Cancel"),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  compressImage(uuid) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$uuid.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile, uuid) async {
    UploadTask uploadTask =
        storageRef.child("photo_$uuid.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  addPhoto(ProductModel product, String productId) async {
    setState(() {
      isImageUploading = true;
    });
    await compressImage(uuid);
    String mediaUrl = await uploadImage(file, uuid);
    product.photos.add(mediaUrl);
    await productsRef.doc(productId).update({'photos': product.photos});
    setState(() {
      uuid = Uuid().v4();
      file = null;
      isImageUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();

    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
              stream: productsRef.doc(widget.productId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      child: Center(child: CircularProgressIndicator()));
                }
                ProductModel product = ProductModel.fromDocument(snapshot.data);
                isOwner = product.storeId == widget.userId;
                switch (product.shade) {
                  case 'Full sun':
                    shadeIcon = Icons.wb_sunny_rounded;
                    break;
                  case 'Partial sun':
                    shadeIcon = Icons.wb_sunny_outlined;
                    break;
                  case 'Full shade':
                  case 'Partial shade':
                  case 'Dappled shade':
                    shadeIcon = Icons.wb_shade;
                    break;
                }
                int userCommentedIndex = 0;
                if (product.reviewedUsers.containsKey(_firebaseUser.uid)) {
                  for (int i = 0; i < product.ratingMap.length; i++) {
                    if (product.ratingMap.elementAt(i)['userId'] ==
                        _firebaseUser.uid) {
                      break;
                    }
                    userCommentedIndex++;
                  }
                }
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SinglePhotoViewer(
                                        url: product.mediaUrl)));
                          },
                          child: Stack(
                            children: [
                              Hero(
                                tag: widget.tag,
                                child: Container(
                                  height: 320,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF4F0BB),
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.zero,
                                      image: DecorationImage(
                                          image: NetworkImage(product.mediaUrl),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                              Positioned(
                                  top: 15,
                                  right: 15,
                                  child: InkWell(
                                    onTap: () async {
                                      await likedRef
                                          .doc(widget.userId)
                                          .collection('liked')
                                          .doc(widget.productId)
                                          .set({'productId': widget.productId});
                                      final snackBar = SnackBar(
                                          content: Text(
                                              'Liked! Enjoy your shopping.'));

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.favorite_border,
                                            color: Colors.white)),
                                  )),
                              Positioned(
                                  top: 60,
                                  right: 15,
                                  child: InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateProduct(
                                                      product: product,
                                                      storeId:
                                                          product.storeId)));
                                    },
                                    child: product.storeId == widget.userId
                                        ? Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle),
                                            child: Icon(Icons.edit,
                                                color: Colors.white))
                                        : Container(),
                                  )),
                            ],
                          ),
                        ),
                        Divider(height: 0),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF43291F)),
                                      ),
                                      Text(
                                        '₹ ${product.price}',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDA2C38)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${product.plantType}, ${product.category}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF226F54)),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '(${product.ratingMap.length})',
                                            style: TextStyle(
                                                color: Colors.black45),
                                          ),
                                          SizedBox(width: 5),
                                          SizedBox(
                                            height: 20,
                                            child: ListView.builder(
                                              itemCount: 5,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) =>
                                                  Icon(Icons.star,
                                                      size: 20,
                                                      color: index <
                                                              product.rating
                                                          ? Color(0xFF226F54)
                                                          : Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 60),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Store(
                                            uid: product.storeId,
                                            userId: _firebaseUser.uid,
                                            isNetwork: true),
                                      ));
                                },
                                child: Text(product.storeName,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline)),
                              ),
                              product.description == ''
                                  ? Container()
                                  : SizedBox(height: 15),
                              product.description == ''
                                  ? Container()
                                  : Text(
                                      product.description,
                                      style: TextStyle(
                                          color: Color(0xFF226F54),
                                          fontSize: 18),
                                    ),
                              SizedBox(height: 60),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Temperature',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '${product.temperature}° C',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.shade,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(shadeIcon, size: 30),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Water',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        product.waterLevel,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        product.photos.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Text('Photos',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                        product.photos.isEmpty
                            ? Container()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  height: 200,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: product.photos.length,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PhotoViewer(
                                                          url: product.photos
                                                              .elementAt(index),
                                                          product: product,
                                                          index: index)));
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 200,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  image: DecorationImage(
                                                      image:
                                                          NetworkImage(
                                                              product.photos
                                                                  .elementAt(
                                                                      index)),
                                                      fit: BoxFit.cover)),
                                            ),
                                            isOwner
                                                ? Positioned(
                                                    bottom: 10,
                                                    right: 10,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title: Text(
                                                                          'Delete photo'),
                                                                      content: Text(
                                                                          'Do you want to delete photo permanently'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Text('Cancel')),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              product.photos.removeAt(index);
                                                                              await productsRef.doc(product.productId).update({
                                                                                'photos': product.photos
                                                                              });

                                                                              String filePath = product.photos.elementAt(index).replaceAll(new RegExp(r'https://firebasestorage.googleapis.com/v0/b/nova-green-999c8.appspot.com/o/'), '').split('?')[0];
                                                                              await FirebaseStorage.instance.ref().child(filePath).delete().then((_) => print('Successfully deleted $filePath storage item'));
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Text('Delete')),
                                                                      ],
                                                                    ));
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                        child: Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(width: 20);
                                    },
                                  ),
                                ),
                              ),
                        product.photos.isNotEmpty && isOwner
                            ? SizedBox(height: 20)
                            : Container(),
                        isOwner
                            ? (file == null && product.photos.length <= 8
                                ? InkWell(
                                    onTap: () async {
                                      await selectImage(context);
                                    },
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Center(
                                          child: Text(
                                        'Add Photo',
                                        style: TextStyle(color: Colors.grey),
                                      )),
                                    ))
                                : Container(
                                    padding: EdgeInsets.all(20),
                                    color: Color(0xFF87C38F),
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 250,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                image: DecorationImage(
                                                    image: FileImage(file),
                                                    fit: BoxFit.cover))),
                                        SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      file = null;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4)),
                                                        border: Border.all(
                                                            color: Color(
                                                                0xFF226F54),
                                                            width: 2)),
                                                    child: Center(
                                                        child: Text('Remove',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: isImageUploading
                                                      ? null
                                                      : () async {
                                                          await addPhoto(
                                                              product,
                                                              product
                                                                  .productId);
                                                          final snackBar = SnackBar(
                                                              content: Text(
                                                                  'Photo added. Enjoy!'));

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                        },
                                                  child: Container(
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4)),
                                                        color: isImageUploading
                                                            ? Color(0xFF226F54)
                                                                .withOpacity(
                                                                    0.5)
                                                            : Color(
                                                                0xFF226F54)),
                                                    child: Center(
                                                        child: Text(
                                                            isImageUploading
                                                                ? 'Uploading...'
                                                                : 'Upload',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: isImageUploading
                                                                    ? Colors
                                                                        .white54
                                                                    : Colors
                                                                        .white))),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                            : Container(),
                        SizedBox(height: 60),
                        Row(
                          children: [
                            SizedBox(width: 25),
                            InkWell(
                              onTap: () async {
                                await cartRef
                                    .doc(widget.userId)
                                    .collection('cart')
                                    .doc(product.productId)
                                    .set({'productId': product.productId});
                                final snackBar = SnackBar(
                                    content:
                                        Text('Added! Enjoy your shopping.'));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    border: Border.all(
                                        color: Color(0xFF226F54), width: 2)),
                                child: Center(
                                    child: Icon(Icons.add_shopping_cart_rounded,
                                        color: Color(0xFF226F54))),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Color(0xFF226F54),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Buy now',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                            SizedBox(width: 25),
                          ],
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: InkWell(
                              onTap: () async {
                                await likedRef
                                    .doc(widget.userId)
                                    .collection('liked')
                                    .doc(widget.productId)
                                    .set({'productId': widget.productId});
                                final snackBar = SnackBar(
                                    content:
                                        Text('Liked! Enjoy your shopping.'));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              child: Text('Add to wish list',
                                  style: TextStyle(
                                      color: Color(0xFF226F54), fontSize: 16))),
                        ),
                        SizedBox(height: 70),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Divider(
                            height: 0,
                            color: Color(0xFF707070),
                          ),
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: productsRef
                              .where('name', isNotEqualTo: product.name)
                              .where('plantType', isEqualTo: product.plantType)
                              .limit(10)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data.docs.isEmpty) {
                              return Container();
                            }
                            List<ProductModel> products = [];
                            snapshot.data.docs.forEach((doc) {
                              products.add(ProductModel.fromDocument(doc));
                            });
                            return Column(
                              children: [
                                SizedBox(height: 35),
                                Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Text('Similar products',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SingleChildScrollView(
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
                                            Color(0xFFF4F0BB));
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(width: 20);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, top: 25, bottom: 20),
                          child: Text('Review',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container()
                            : Center(
                                child: RatingBar.builder(
                                  initialRating: 3,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  // glow: false,
                                  updateOnDrag: true,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      this.rating = rating;
                                    });
                                  },
                                ),
                              ),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container()
                            : SizedBox(height: 15),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    labelText: 'Type something here...',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  controller: _reviewController,
                                  maxLines: null,
                                  minLines: 5,
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container()
                            : SizedBox(height: 15),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container()
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: InkWell(
                                    onTap: () async {
                                      int overallRating = (((product.rating *
                                                      product
                                                          .ratingMap.length) +
                                                  rating) /
                                              (product.ratingMap.length + 1))
                                          .round();
                                      product.ratingMap.add({
                                        'username': _firebaseUser.displayName,
                                        'userId': _firebaseUser.uid,
                                        'rating': rating.round(),
                                        'userProfile': _firebaseUser.photoURL,
                                        'comment':
                                            _reviewController.text.trim(),
                                        'timeStamp': DateTime.now()
                                      });
                                      product.reviewedUsers[_firebaseUser.uid] =
                                          true;
                                      await productsRef
                                          .doc(product.productId)
                                          .update({
                                        'rating': overallRating,
                                        'ratingMap': product.ratingMap,
                                        'reviewedUsers': product.reviewedUsers
                                      });
                                      setState(() {
                                        _reviewController.clear();
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        color: Color(0xFF226F54),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Review',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? SizedBox(height: 25)
                            : SizedBox(height: 50),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                color: Colors.grey[100],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Text('Highlighted comment',
                                          style:
                                              TextStyle(color: Colors.black38)),
                                    ),
                                    SizedBox(height: 12),
                                    product.reviewedUsers
                                            .containsKey(_firebaseUser.uid)
                                        ? reviewWidget(
                                            product, userCommentedIndex)
                                        : Container(),
                                  ],
                                ),
                              )
                            : Container(),
                        product.reviewedUsers.containsKey(_firebaseUser.uid)
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 15,
                              )
                            : Container(),
                        ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) =>
                                reviewWidget(product, index),
                            separatorBuilder: (context, index) => Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Divider(
                                      height: 30,
                                    ),
                                  ),
                                ),
                            itemCount: product.ratingMap.length > 5
                                ? 5
                                : product.ratingMap.length),
                        product.ratingMap.length > 5
                            ? SizedBox(height: 30)
                            : Container(),
                        product.ratingMap.length > 5
                            ? Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Reviews(
                                                productId: product.productId,
                                                userId: _firebaseUser.uid)));
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 130,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        border: Border.all(
                                            color: Color(0xFF226F54),
                                            width: 2)),
                                    child: Center(
                                      child: Text(
                                        'See more',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(height: 60),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, bottom: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NOVA green',
                                style: TextStyle(
                                    color: Color(0xFF226F54),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete Product'),
                                            content: Text(
                                                'Are you sure to delete product permanently?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel')),
                                              TextButton(
                                                  onPressed: () async {
                                                    String filePath = product
                                                        .mediaUrl
                                                        .replaceAll(
                                                            new RegExp(
                                                                r'https://firebasestorage.googleapis.com/v0/b/nova-green-999c8.appspot.com/o/'),
                                                            '')
                                                        .split('?')[0];
                                                    await FirebaseStorage
                                                        .instance
                                                        .ref()
                                                        .child(filePath)
                                                        .delete()
                                                        .then((_) => print(
                                                            'Successfully deleted $filePath storage item'));
                                                    product.photos
                                                        .forEach((url) async {
                                                      String filePath = url
                                                          .replaceAll(
                                                              new RegExp(
                                                                  r'https://firebasestorage.googleapis.com/v0/b/nova-green-999c8.appspot.com/o/'),
                                                              '')
                                                          .split('?')[0];
                                                      await FirebaseStorage
                                                          .instance
                                                          .ref()
                                                          .child(filePath)
                                                          .delete()
                                                          .then((_) => print(
                                                              'Successfully deleted $filePath storage item'));
                                                    });
                                                    StoreModel store =
                                                        StoreModel.fromDocument(
                                                            await sellersRef
                                                                .doc(product
                                                                    .storeId)
                                                                .get());
                                                    int index = 0;
                                                    for (int i = 0;
                                                        i <
                                                            store.products
                                                                .length;
                                                        i++) {
                                                      if (store.products
                                                                  .elementAt(i)[
                                                              'productId'] ==
                                                          widget.productId) {
                                                        break;
                                                      }
                                                      index++;
                                                    }
                                                    print(index);
                                                    store.products
                                                        .removeAt(index);
                                                    await sellersRef
                                                        .doc(product.storeId)
                                                        .update({
                                                      'products': store.products
                                                    });
                                                    await productsRef
                                                        .doc(widget.productId)
                                                        .delete();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Delete')),
                                            ],
                                          );
                                        });
                                  },
                                  child: Text('Delete product',
                                      style: TextStyle(color: Colors.red)))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
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

  Container reviewWidget(ProductModel product, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              backgroundImage: NetworkImage(
                  product.ratingMap.elementAt(index)['userProfile']),
              radius: 24),
          SizedBox(width: 8),
          Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.ratingMap.elementAt(index)['username'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 8),
                        product.ratingMap.elementAt(index)['comment'] == ''
                            ? Container()
                            : Container(
                                child: Text(
                                  product.ratingMap.elementAt(index)['comment'],
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                      ],
                    ),
                  ),
                  product.ratingMap.elementAt(index)['userId'] == widget.userId
                      ? PopupMenuButton(
                          itemBuilder: (BuildContext bc) => [
                            PopupMenuItem(child: Text("Edit"), value: "Edit"),
                            PopupMenuItem(
                                child: Text("Delete"), value: "Delete"),
                          ],
                          onSelected: (route) async {
                            if (route == 'Delete') {
                              product.ratingMap.removeAt(index);
                              product.reviewedUsers.remove(widget.userId);
                              await productsRef.doc(product.productId).update({
                                'ratingMap': product.ratingMap,
                                'reviewedUsers': product.reviewedUsers
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    double ratingStar = 3;
                                    _reviewController.text = product.ratingMap
                                        .elementAt(index)['comment'];
                                    return AlertDialog(
                                      title: Text('Edit Review'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: RatingBar.builder(
                                              initialRating: (product.ratingMap
                                                      .elementAt(
                                                          index)['rating'])
                                                  .toDouble(),
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: false,
                                              itemCount: 5,
                                              // glow: false,
                                              updateOnDrag: true,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                setState(() {
                                                  ratingStar = rating;
                                                  print(ratingStar);
                                                });
                                                print(ratingStar);
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText:
                                                  'Leave your review here...',
                                            ),
                                            maxLines: null,
                                            controller: _reviewController,
                                            keyboardType: TextInputType.name,
                                            minLines: 5,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel')),
                                        TextButton(
                                            onPressed: () async {
                                              product.ratingMap.elementAt(
                                                      index)['comment'] =
                                                  _reviewController.text.trim();
                                              product.ratingMap.elementAt(
                                                      index)['rating'] =
                                                  ratingStar.toDouble();
                                              await productsRef
                                                  .doc(product.productId)
                                                  .update({
                                                'ratingMap': product.ratingMap,
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text('Update'))
                                      ],
                                    );
                                  });
                            }
                          },
                        )
                      : Container(),
                ],
              ),
              product.ratingMap.elementAt(index)['comment'] == ''
                  ? Container()
                  : SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 14,
                    child: ListView.builder(
                      itemCount: 5,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, starI) => Icon(Icons.star,
                          size: 14,
                          color: starI <
                                  product.ratingMap.elementAt(index)['rating']
                              ? Color(0xFF226F54)
                              : Colors.grey),
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(product.ratingMap
                        .elementAt(index)['timeStamp']
                        .toDate()
                        .toString())),
                    style: TextStyle(fontSize: 12, color: Color(0xFF226F54)),
                  )
                ],
              )
            ]),
          ),
        ],
      ),
    );
  }
}
