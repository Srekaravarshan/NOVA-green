import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/Models/AddressModel.dart';
import 'package:nova_green/main.dart';
import 'package:provider/provider.dart';

class Addresses extends StatefulWidget {
  @override
  _AddressesState createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  bool getForm = false;
  TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Address',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: addressRef.doc(_firebaseUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                AddressModel addresses =
                    AddressModel.fromDocument(snapshot.data);
                return Column(
                  children: [
                    addresses.addresses.isEmpty
                        ? Container()
                        : ListView.separated(
                            padding: EdgeInsets.all(25),
                            shrinkWrap: true,
                            itemCount: addresses.addresses.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFF4F0BB),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text(
                                          addresses.addresses.elementAt(index),
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                    Divider(height: 0, color: Colors.grey[500]),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Form(
                                                      key: _formKey,
                                                      child: AlertDialog(
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
                                                                addresses
                                                                    .addresses
                                                                    .removeAt(
                                                                        index);
                                                                await addressRef
                                                                    .doc(_firebaseUser
                                                                        .uid)
                                                                    .update({
                                                                  'addresses':
                                                                      addresses
                                                                          .addresses
                                                                });

                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'Delete')),
                                                        ],
                                                        title: Text(
                                                            'Delete address'),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Form(
                                                      key: _formKey,
                                                      child: AlertDialog(
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
                                                                if (_formKey
                                                                    .currentState
                                                                    .validate()) {
                                                                  addresses
                                                                      .addresses
                                                                      .replaceRange(
                                                                          index,
                                                                          index +
                                                                              1,
                                                                          [
                                                                        _addressController
                                                                            .text
                                                                            .trim()
                                                                      ]);
                                                                  await addressRef
                                                                      .doc(_firebaseUser
                                                                          .uid)
                                                                      .update({
                                                                    'addresses':
                                                                        addresses
                                                                            .addresses
                                                                  });

                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              child: Text(
                                                                  'Update')),
                                                        ],
                                                        title: Text(
                                                            'Edit address'),
                                                        content: TextFormField(
                                                          controller:
                                                              _addressController
                                                                ..text = addresses
                                                                    .addresses
                                                                    .elementAt(
                                                                        index),
                                                          maxLines: null,
                                                          decoration: InputDecoration(
                                                              isDense: true,
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey[200],
                                                              border:
                                                                  OutlineInputBorder()),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4),
                                              child: Center(
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(height: 20);
                            },
                          ),
                    getForm
                        ? Form(
                            key: _formKey,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF226F54),
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        fillColor: Colors.grey[100],
                                        filled: true,
                                        labelText: 'Address',
                                        isDense: true),
                                    maxLines: null,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            getForm = false;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[100],
                                                width: 2),
                                            color: Color(0xFF226F54),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                          ),
                                          child: Center(
                                            child: Text('Cancel',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                          ),
                                        ),
                                      )),
                                      SizedBox(width: 10),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            String address =
                                                _addressController.text.trim();
                                            setState(() {
                                              _addressController.clear();
                                              getForm = false;
                                            });
                                            addresses.addresses.add(address);
                                            await addressRef
                                                .doc(_firebaseUser.uid)
                                                .update({
                                              'addresses': addresses.addresses
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                          ),
                                          child: Center(
                                            child: Text('Add',
                                                style: TextStyle(fontSize: 18)),
                                          ),
                                        ),
                                      ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              setState(() {
                                getForm = true;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 25),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFF226F54),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Center(
                                child: Text('Add Address',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ),
                            ),
                          )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
