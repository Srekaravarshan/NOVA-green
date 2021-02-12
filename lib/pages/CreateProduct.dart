import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_green/Extension.dart';
import 'package:nova_green/Models/StoreModel.dart';
import 'package:nova_green/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateProduct extends StatefulWidget {
  final StoreModel store;

  const CreateProduct({Key key, this.store}) : super(key: key);
  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _temperatureController = TextEditingController();
  File file;
  bool isUploading = false;
  String _shade = 'Full sun';
  String _waterLevel = 'Moderate';
  String _plantType = 'Herb';
  String _productType = 'Plant';
  String _category = 'Indoor';
  bool fileError = false;
  String uuid = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
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

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage(userId) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$userId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile, userId) async {
    UploadTask uploadTask =
        storageRef.child("product_$userId.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({
    @required String mediaUrl,
    @required String productType,
    @required String name,
    @required String price,
    @required String weight,
    @required String description,
    @required String temperature,
    @required String shade,
    @required String waterLevel,
    @required String plantType,
    @required List photos,
    @required String productId,
    @required String storeId,
    @required List ratingMap,
    @required int rating,
    @required String storeName,
    @required String category,
  }) async {
    widget.store.products.add({
      'mediaUrl': mediaUrl,
      'productType': productType,
      'name': name,
      'price': price,
      'weight': weight,
      'description': description,
      'temperature': temperature,
      'shade': shade,
      'waterLevel': waterLevel,
      'plantType': plantType,
      'photos': photos,
      'productId': productId,
      'storeId': storeId,
      'ratingMap': ratingMap,
      'rating': rating,
      'storeName': storeName,
      'category': category
    });
    await sellersRef.doc(storeId).update({'products': widget.store.products});
    await productsRef.doc(productId).set({
      'mediaUrl': mediaUrl,
      'productType': productType,
      'name': name,
      'price': price,
      'weight': weight,
      'description': description,
      'temperature': temperature,
      'shade': shade,
      'waterLevel': waterLevel,
      'plantType': plantType,
      'photos': photos,
      'productId': productId,
      'storeId': storeId,
      'ratingMap': ratingMap,
      'rating': rating,
      'storeName': storeName
    });
  }

  handleSubmit(String uuid) async {
    setState(() {
      isUploading = true;
    });
    await compressImage(uuid);
    String mediaUrl = await uploadImage(file, uuid);
    createPostInFirestore(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        mediaUrl: mediaUrl,
        productType: _productType,
        price: _priceController.text.trim(),
        weight: _weightController.text.trim(),
        temperature: _temperatureController.text.trim(),
        shade: _shade,
        waterLevel: _waterLevel,
        plantType: _plantType,
        photos: [],
        productId: uuid,
        storeId: widget.store.userId,
        rating: 0,
        ratingMap: [],
        storeName: widget.store.name,
        category: _category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                file == null
                    ? SafeArea(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 250,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[200],
                                  child: InkWell(
                                    onTap: () => selectImage(context),
                                    child: Container(
                                      height: 45,
                                      width: 250,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: Text('Upload product photo',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white))
                                          .center(),
                                    ),
                                  ).center(),
                                ),
                                fileError
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 25),
                                        child: Text(
                                            'Please upload product photo',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      )
                                    : Container()
                              ],
                            ),
                            Positioned(
                                top: 15,
                                right: 15,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 25),
                                                  Text('Info',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 25),
                                                  Text(
                                                    'If your product photo is this',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Container(
                                                    height: 150,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                  //TODO: product card to be added
                                                  SizedBox(height: 25),
                                                ],
                                              ),
                                            ));
                                  },
                                  child: Container(
                                    // padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: Colors.teal,
                                    ),
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.teal,
                                      size: 32,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      )
                    : SafeArea(
                        child: Stack(
                          children: [
                            Container(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.contain)),
                            ),
                            Positioned(
                                top: 15,
                                right: 15,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 25),
                                                  Text('Info',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 25),
                                                  Text(
                                                    'If your product photo is this',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Container(
                                                    height: 150,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                  //TODO: product card to be added
                                                  SizedBox(height: 25),
                                                ],
                                              ),
                                            ));
                                  },
                                  child: Container(
                                    // padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: Colors.teal,
                                    ),
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.teal,
                                      size: 32,
                                    ),
                                  ),
                                )),
                            Positioned(
                              bottom: 15,
                              right: 15,
                              child: InkWell(
                                onTap: () => clearImage(),
                                child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child:
                                        Icon(Icons.delete, color: Colors.red)),
                              ),
                            )
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Text('Product type',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.grey[200],
                        ),
                        child: DropdownButton<String>(
                          value: _productType,
                          onChanged: (String newValue) {
                            setState(() {
                              _productType = newValue;
                            });
                          },
                          underline: Container(),
                          isExpanded: true,
                          items: <String>['Plant', 'Seeds']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 50),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.grey[100],
                            filled: true,
                            labelText: 'Product name*',
                            isDense: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your product name';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.grey[100],
                            filled: true,
                            labelText: 'Price (in Rupees)*',
                            isDense: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your product price';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.grey[100],
                            filled: true,
                            labelText: _productType == 'Plant'
                                ? 'Weight (in kg)*'
                                : 'Weight (in g)*',
                            isDense: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter weight of product';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.grey[100],
                            filled: true,
                            labelText: 'Description',
                            isDense: true),
                        maxLines: null,
                        minLines: 5,
                      ),
                      SizedBox(height: 50),
                      Text('On placing plant how much temperature is better?',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      TextFormField(
                          controller: _temperatureController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey[100],
                              filled: true,
                              labelText: 'Temperature (in Celsius)*',
                              isDense: true),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter temperature';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number),
                      SizedBox(height: 15),
                      Text('Sun or shade',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.grey[200],
                        ),
                        child: DropdownButton<String>(
                          value: _shade,
                          onChanged: (String newValue) {
                            setState(() {
                              _shade = newValue;
                            });
                          },
                          underline: Container(),
                          isExpanded: true,
                          items: <String>[
                            'Full sun',
                            'Partial sun',
                            'Full shade',
                            'Partial shade',
                            'Dappled shade'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text('Use of water',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.grey[200],
                        ),
                        child: DropdownButton<String>(
                          value: _waterLevel,
                          onChanged: (String newValue) {
                            setState(() {
                              _waterLevel = newValue;
                            });
                          },
                          underline: Container(),
                          isExpanded: true,
                          items: <String>[
                            'Very low',
                            'Low',
                            'Moderate',
                            'High',
                            'Very high'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text('Plant type',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.grey[200],
                        ),
                        child: DropdownButton<String>(
                          value: _plantType,
                          onChanged: (String newValue) {
                            setState(() {
                              _plantType = newValue;
                            });
                          },
                          underline: Container(),
                          isExpanded: true,
                          items: <String>[
                            'Herb',
                            'Shrub',
                            'Tree',
                            'Climber',
                            'Creeper'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text('Category',
                          style:
                              TextStyle(color: Colors.black87, fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.grey[200],
                        ),
                        child: DropdownButton<String>(
                          value: _category,
                          onChanged: (String newValue) {
                            setState(() {
                              _category = newValue;
                            });
                          },
                          underline: Container(),
                          isExpanded: true,
                          items: <String>[
                            'Indoor',
                            'Outdoor',
                            'Garden',
                            'Decoration',
                            'Aquatic'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 50),
                      InkWell(
                        //TODO: build preview sheet
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFF226F54), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Center(
                            child: Text('Preview',
                                style: TextStyle(
                                    color: Color(0xFF226F54), fontSize: 24)),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          if (file == null) {
                            setState(() {
                              fileError = true;
                            });
                            return;
                          } else if (fileError) {
                            setState(() {
                              fileError = false;
                            });
                          }
                          if (_formKey.currentState.validate()) {
                            handleSubmit(uuid);
                            Navigator.pop(context);
                          }
                          setState(() {
                            isUploading = false;
                          });
                        },
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: isUploading
                                ? Color(0xFF226F54).withOpacity(0.5)
                                : Color(0xFF226F54),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: isUploading
                              ? Center(
                                  child: Text('Uploading...',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24)),
                                )
                              : Center(
                                  child: Text('Upload',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24)),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 45,
            left: 10,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white70, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.black87)),
            ))
      ],
    ));
  }
}
