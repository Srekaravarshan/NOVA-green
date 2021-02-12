import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:nova_green/main.dart';
import 'package:nova_green/pages/Store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ShowProduct extends StatefulWidget {
  final String productId;
  final String userId;

  const ShowProduct({Key key, @required this.userId, this.productId})
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
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Hero(
                              tag: 'productImage',
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
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 3),
                                                blurRadius: 6)
                                          ],
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.favorite_border,
                                          color: Colors.white)),
                                ))
                          ],
                        ),
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
                                            userId: _firebaseUser.uid),
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
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Text('Photos',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                                      return Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            image: DecorationImage(
                                                image: NetworkImage(product
                                                    .photos
                                                    .elementAt(index)),
                                                fit: BoxFit.cover)),
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
                        file == null && product.photos.length <= 8 && isOwner
                            ? InkWell(
                                onTap: () async {
                                  await selectImage(context);
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: Colors.grey)),
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
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                            Radius.circular(4)),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF226F54),
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
                                                      await addPhoto(product,
                                                          product.productId);
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
                                                            Radius.circular(4)),
                                                    color: isImageUploading
                                                        ? Color(0xFF226F54)
                                                            .withOpacity(0.5)
                                                        : Color(0xFF226F54)),
                                                child: Center(
                                                    child: Text(
                                                        isImageUploading
                                                            ? 'Uploading...'
                                                            : 'Upload',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                isImageUploading
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
                              ),
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
                              child: Text('Add to wishlist',
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
                        //TODO: build similiar products section
                        SizedBox(height: 60),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, bottom: 50),
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
}
