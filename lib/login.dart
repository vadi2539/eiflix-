import 'package:elflix/forgotPassword.dart';
import 'package:elflix/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String _email;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late bool passtoggle = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    final pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void Login() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      try {
        final user =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (user.isNotEmpty) {
          final userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          final snackBar = SnackBar(content: Text('Email not registered'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          final snackBar = SnackBar(content: Text('Incorrect password'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar =
              SnackBar(content: Text('An error occurred while logging in'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
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
                                  borderSide:BorderSide(color: Colors.grey.shade900),
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
                            SizedBox(height: 10.0),
                            TextFormField(
                              controller: passwordController,
                              obscureText: passtoggle,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade900),
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Colors.grey.shade900,
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passtoggle = !passtoggle;
                                    });
                                  },
                                  icon: Icon(
                                    passtoggle
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white38,
                                  )
                                )
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Password';
                                } else if (value.length < 6) {
                                  return 'Please Enter Vaild Password';
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                              ),
                              child: Padding(
                                padding:const EdgeInsets.symmetric(vertical: 3.0),
                                child: RaisedButton(
                                  child: Text('Log In'),
                                  onPressed: Login,
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
                            SizedBox(height: 10.0),
                            FlatButton(
                              child: Text(
                                'Forget Password ?',
                                style: TextStyle(color: Colors.white,decoration: TextDecoration.underline),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => forgotPassword()
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10.0),
                            FlatButton(
                              child: Text(
                                'New to Elflix? Create an account',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()
                                  ),
                                );
                              },
                            ),
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
