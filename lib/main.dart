import 'package:elflix/episode.dart';
import 'package:elflix/firebaseAuth.dart';
import 'package:elflix/forgotPassword.dart';
import 'package:elflix/home.dart';
import 'package:elflix/login.dart';
import 'package:elflix/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    
  runApp(MaterialApp(

    initialRoute: 'auth',
    routes: {
      'home':(context) => home(),
      'episode':(context) => episode(seriesName: '', imageUrl: '', description: '' ,),
      'login':(context) => Login(),
      'register':(context) => Register(),
      'auth':(context)=>firebaseAuth(),
      'forget':(context)=>forgotPassword(),
         
    },
  ));

    
  
}






