import 'package:elflix/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passtoggle = true;
  bool passtoggle1  =true;
  bool validateEmail(String email) {
    final pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final confirmpassword = confirmPasswordController.text;

      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: confirmpassword,
        );
            Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
        
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          final snackBar = SnackBar(content: Text('Email Already Exists'));
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
                      fontWeight: FontWeight.w700),
                ),
              ),
              Center(
                child: Form(
                key: _formKey,
                  child: Column(
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 25.0),
                    // child: TextField(
                    //   decoration: InputDecoration(
                    //     enabledBorder: const OutlineInputBorder(
                    //       borderSide: BorderSide(color:Colors.white),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: Colors.grey
                    //       ),
                    //     ),
                    //     fillColor: Colors.grey.shade900,
                    //     filled: true,
                    //     hintText: 'email'
                    //   ),
                    // ),)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
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
                              ),  style: TextStyle(color: Colors.white),
                              validator: (value){
                                if(value!.isEmpty){
                                  return 'Please Enter a Email';
                                }else if(!validateEmail(value)){
                                  return 'Please Enter a Valid Email';

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
                              ),style: TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Password';
                                } else if (value.length < 6) {
                                  return 'Please Enter Vaild Password';
                                }
                              },
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: passtoggle1,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:BorderSide(color: Colors.grey.shade900),
                                ),
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Colors.grey.shade900,
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passtoggle1 = !passtoggle1;
                                    });
                                  },
                                  icon: Icon(
                                    passtoggle1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white38,
                                  )
                                )
                              ),
                            style: TextStyle(color: Colors.white) ,
                            validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Confirm Password';
                                } else if (value!=passwordController.text) {
                                  return ' Confirm Password did not match with Password';
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                              ),
                              child: RaisedButton(
                                child: Text('Sign Up'),
                                onPressed: signUp,
                                color: Colors.black,
                                textColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            FlatButton(
                              child: Text(
                                'If you have account already?Sign In Here',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(
                                  builder:(context) =>Login()
                                ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );   
  }
}