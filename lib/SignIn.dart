import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_green/AuthService.dart';
import 'package:nova_green/Extension.dart';
import 'package:nova_green/constants.dart';
import 'package:nova_green/main.dart';
import 'package:provider/provider.dart';

// final TextEditingController _emailController = new TextEditingController();
// final TextEditingController _passwordController = new TextEditingController();

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3E9E9),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/login_bg.png'),
                    alignment: Alignment.topCenter)),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width > 0
                  ? MediaQuery.of(context).size.width - 50
                  : 0,
              margin: EdgeInsets.all(25),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6))
                ],
                color: backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 45),
                            Text('NOVA green',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text('Create account',
                                style: TextStyle(fontSize: 20)),
                            SizedBox(height: 20),
                            // TextFormField(
                            //   decoration: InputDecoration(
                            //     border: OutlineInputBorder(),
                            //     fillColor: Colors.grey[100],
                            //     filled: true,
                            //     labelText: 'Email address',
                            //   ),
                            //   keyboardType: TextInputType.emailAddress,
                            // ),
                            // SizedBox(height: 10),
                            // TextFormField(
                            //   obscureText: true,
                            //   decoration: InputDecoration(
                            //     border: OutlineInputBorder(),
                            //     fillColor: Colors.grey[100],
                            //     filled: true,
                            //     labelText: 'Password',
                            //   ),
                            // ),
                            // SizedBox(height: 20),
                            // InkWell(
                            //   onTap: () async {},
                            //   child: Container(
                            //     height: 50,
                            //     decoration: BoxDecoration(
                            //         color: Color(0xFFFF7357),
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(4))),
                            //     child: Text(
                            //       'Sign up',
                            //       style: TextStyle(
                            //           color: Colors.white,
                            //           fontFamily: 'Ubuntu',
                            //           fontSize: 14),
                            //     ).center(),
                            //   ),
                            // ),
                            // SizedBox(height: 15),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //         child: Divider(thickness: 1.5, height: 0)
                            //             .center()),
                            //     SizedBox(width: 7),
                            //     Text('or', style: TextStyle(fontSize: 14)),
                            //     SizedBox(width: 7),
                            //     Expanded(
                            //         child: Divider(thickness: 1.5, height: 0)
                            //             .center())
                            //   ],
                            // ),
                            // SizedBox(height: 15),
                            InkWell(
                              onTap: () async {
                                await context
                                    .read<AuthService>()
                                    .signUpWithGoogle();
                                final User _firebaseUser =
                                    Provider.of<User>(context, listen: false);
                                await addressRef.doc(_firebaseUser.uid).set({
                                  'addresses': [],
                                  'userId': _firebaseUser.uid
                                });
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Color(0xFF004CFF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Text(
                                  'Sign up with google',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ).center(),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: 'Sign in',
                            style: TextStyle(color: Colors.blue)),
                      ]),
                    ).center(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// final User _firebaseUser = context.watch<User>();
// final User _firebaseUser =
//     Provider.of<User>(context, listen: false);
// await usersRef.doc(_firebaseUser.uid).set({
//   'displayName': _firebaseUser.displayName != null
//       ? _firebaseUser.displayName
//       : 'Anonymous',
//   'uid': _firebaseUser.uid,
//   'email': _firebaseUser.email,
//   'photoURL': _firebaseUser.photoURL,
// });
