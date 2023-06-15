import 'package:elflix/firebaseAuth.dart';
import 'package:elflix/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({Key? key}) : super(key: key);

  @override
  State<forgotPassword> createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool validateEmail(String email) {
    final pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      try {
        final user =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (user.isNotEmpty) {
          final userCredential =
              await FirebaseAuth.instance.sendPasswordResetEmail(
            email: email,
            
          );
              Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
        } else {
          final snackBar = SnackBar(content: Text('Email not registered'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        final snackBar = SnackBar(content: Text('Check Email'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 200, left: 0),
                child: Text(
                  'EiFlix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade900),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Colors.grey.shade900,
                                filled: true,
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a email';
                                } else if (!validateEmail(value)) {
                                  return 'Please enter a valid email';
                                }
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: RaisedButton(
                                  child: Text('Reset Password'),
                                  onPressed: _resetPassword,
                                  // onPressed: () async {
                                  //    (_formKey.currentState!.validate());

                                  //   await FirebaseAuth.instance
                                  //       .signInWithEmailAndPassword(
                                  //           email: emailController.text
                                  //               .toLowerCase()
                                  //               .trim(),
                                  //           password:
                                  //               passwordController.text.trim());
                                  // },
                                  color: Colors.black,
                                  textColor: Colors.white,
                                ),
                              ),
                            ),
                            //                     if (_successMessage != null)
                            // Text(
                            //   _successMessage,
                            //   style: TextStyle(color: Colors.green),
                            // ),
                            // Error message
                            // if (_errorMessage != null)
                            //   Text(
                            //     _errorMessage,
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
