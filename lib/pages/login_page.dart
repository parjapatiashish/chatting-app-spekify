import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spekify/models/ui_helper.dart';
import 'package:spekify/models/user_model.dart';
import 'package:spekify/pages/home_page.dart';
import 'package:spekify/pages/signup_page.dart';
class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if(email == '' || password == '' ){
      UIHelper.showAlertDialod(context, 'Incomplete Data', 'please fill all the field!');

    }else{
      logIn(email, password);
    }
  }
  void logIn(String email,String password) async{
    UserCredential? credetial;
    UIHelper.showLoadingDialog(context, 'Logging In...');
    try{
      credetial = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UIHelper.showAlertDialod(context,'An error occurred', ex.message.toString());
    }
    if(credetial!=null){
      String uid = credetial.user!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.
      collection('users').doc(uid).get();

      UserModel userModel = UserModel.fromMap(userData.data() as Map<String , dynamic>);
      log('Log In successful!');

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context){
            return HomePage(userModel: userModel, firebaseUser: credetial!.user!);
         }
       )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/images/spekify_logo.png'),
                  const SizedBox(height: 20,),
                  Text(
                    'Spekify',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                  ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address'
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password'
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CupertinoButton(
                    onPressed:checkValues,
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text('Log In'),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account?',
            style: TextStyle(
            fontSize: 16,
          ), ),
          CupertinoButton(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
              ),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context){
                          return const SignUpPage();
                        },
                    )
                );
              },
          ),
        ],
      ),
    );
  }
}
