import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:nova_green/Extension.dart';
import 'package:nova_green/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class BusinessForm extends StatefulWidget {
  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  File file;
  bool isUploading = false;
  bool accept = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String phoneNumber;
  bool isValidNumber = false;

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
        storageRef.child("cover_$userId.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl,
      String name,
      String description,
      String address,
      String phoneNumber,
      String userId}) {
    sellersRef.doc(userId).set({
      'name': name,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'cover': mediaUrl,
      'userId': userId,
      'ratingMap': [],
      'rating': 0,
      'products': [],
      'photos': [],
      'reviewedUsers': {}
    });
  }

  handleSubmit(String userId) async {
    setState(() {
      isUploading = true;
    });
    if (file != null) {
      await compressImage(userId);
    }
    String mediaUrl = file == null ? '' : await uploadImage(file, userId);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        phoneNumber: phoneNumber,
        userId: userId);
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  file == null
                      ? Container(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              child: Text('Upload cover photo',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white))
                                  .center(),
                            ),
                          ).center(),
                        )
                      : Stack(
                          children: [
                            Container(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover)),
                            ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        SizedBox(height: 25),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey[100],
                              filled: true,
                              labelText: 'Store name*',
                              isDense: true),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your store name';
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
                        SizedBox(height: 25),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey[100],
                              filled: true,
                              labelText: 'Address*',
                              isDense: true),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your store address';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.streetAddress,
                        ),
                        SizedBox(height: 25),
                        InternationalPhoneNumberInput(
                          inputDecoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey[100],
                              filled: true,
                              labelText: 'Phone number*',
                              isDense: true),
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              phoneNumber = number.phoneNumber;
                            });
                          },
                          validator: (value) {
                            if (!isValidNumber) {
                              return 'Please enter valid number';
                            }
                            return null;
                          },
                          onInputValidated: (bool value) {
                            setState(() {
                              isValidNumber = value;
                            });
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          initialValue: number,
                          textFieldController: _numberController,
                          formatInput: false,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(),
                          // onSaved: (PhoneNumber number) {
                          //   print('On Saved: $number');
                          // },
                        ),
                        SizedBox(height: 50),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text(
                            "These terms and conditions outline the rules and regulations for the use of NOVA green's Website, located at https://www.novagreen.com/.\n\nBy accessing this website we assume you accept these terms and conditions. Do not continue to use novagreen if you do not agree to take all of the terms and conditions stated on this page.",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                          ),
                        ),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => TOC()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                color: Color(0xFFF4F0BB),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                border: Border.all(color: Colors.black12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 6)
                                ]),
                            child: Text('Read Terms and condition',
                                    style: TextStyle())
                                .center(),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                                value: accept,
                                onChanged: (value) {
                                  setState(() {
                                    accept = value;
                                  });
                                }),
                            Text('Accept Terms and condition')
                          ],
                        ),
                        SizedBox(height: 50),
                        InkWell(
                          onTap: (accept && !isUploading)
                              ? () async {
                                  if (_formKey.currentState.validate()) {
                                    await handleSubmit(_firebaseUser.uid);
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                color: (accept && !isUploading && isValidNumber)
                                    ? Color(0xFF226F54)
                                    : Color(0xFF226F54).withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 10)
                                ]),
                            child: Text(
                              isUploading ? 'Creating...' : 'Create Store',
                              style: TextStyle(
                                  color: isUploading
                                      ? Colors.white60
                                      : Colors.white,
                                  fontSize: 16),
                            ).center(),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ],
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
                          color: Colors.white38, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.black87)),
                ))
          ],
        ),
      ),
    );
  }
}

class TOC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
                child: Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      EdgeInsets.only(left: 5, right: 25, top: 25, bottom: 25),
                  child: Text(
                    "Terms and Conditions\n\nWelcome to novagreen!\n\nThese terms and conditions outline the rules and regulations for the use of NOVA green's Website, located at https://www.novagreen.com/.\n\nBy accessing this website we assume you accept these terms and conditions. Do not continue to use novagreen if you do not agree to take all of the terms and conditions stated on this page.\n\nThe following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: \"Client\", \"You\" and \"Your\" refers to you, the person log on this website and compliant to the Company’s terms and conditions. \"The Company\", \"Ourselves\", \"We\", \"Our\" and \"Us\", refers to our Company. \"Party\", \"Parties\", or \"Us\", refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client’s needs in respect of provision of the Company’s stated services, in accordance with and subject to, prevailing law of Netherlands. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.\n\nCookies\n\nWe employ the use of cookies. By accessing novagreen, you agreed to use cookies in agreement with the NOVA green's Privacy Policy.\n\nMost interactive websites use cookies to let us retrieve the user’s details for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier for people visiting our website. Some of our affiliate/advertising partners may also use cookies\n\nLicense\n\nUnless otherwise stated, NOVA green and/or its licensors own the intellectual property rights for all material on novagreen. All intellectual property rights are reserved. You may access this from novagreen for your own personal use subjected to restrictions set in these terms and conditions.\n\nParts of this website offer an opportunity for users to post and exchange opinions and information in certain areas of the website. NOVA green does not filter, edit, publish or review Comments prior to their presence on the website. Comments do not reflect the views and opinions of NOVA green,its agents and/or affiliates. Comments reflect the views and opinions of the person who post their views and opinions. To the extent permitted by applicable laws, NOVA green shall not be liable for the Comments or for any liability, damages or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this website.\n\nNOVA green reserves the right to monitor all Comments and to remove any Comments which can be considered inappropriate, offensive or causes breach of these Terms and Conditions.\n\nAs long as the website and the information and services on the website are provided free of charge, we will not be liable for any loss or damage of any nature.",
                    style: TextStyle(height: 1.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
