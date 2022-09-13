import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spekify/models/firebase_helper.dart';
import 'package:spekify/models/user_model.dart';
import 'package:spekify/pages/login_page.dart';
import 'package:uuid/uuid.dart';
import './pages/home_page.dart';
var uuid = const Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser!=null){
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }else{
      runApp(const MyApp());
    }
  }else{
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const LogInPage(),
    );
  }
}
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:HomePage(firebaseUser: firebaseUser, userModel: userModel,),
    );
  }
}

