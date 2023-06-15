import 'package:elflix/home.dart';
import 'package:elflix/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class firebaseAuth extends StatefulWidget {
  const firebaseAuth({Key? key}) : super(key: key);

  @override
  State<firebaseAuth> createState() => _firebaseAuthState();
}

class _firebaseAuthState extends State<firebaseAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return home();
          }else{
            return Login();
          }
        },
        
      ),

    );
    
  }
}