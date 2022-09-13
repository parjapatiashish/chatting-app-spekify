import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spekify/models/ui_helper.dart';
import 'package:spekify/models/user_model.dart';
import 'package:spekify/pages/complete_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>{

 TextEditingController emailController = TextEditingController();
 TextEditingController passwordController = TextEditingController();
 TextEditingController cPasswordController = TextEditingController();

 void checkValue(){
   String email = emailController.text.trim();
   String password = passwordController.text.trim();
   String cPassword = cPasswordController.text.trim();
   if(email == '' || password=='' || cPassword==''){
     UIHelper.showAlertDialod(context, 'Incomplete Data', 'please fills all the fields!');
   }else if(password!=cPassword){
     UIHelper.showAlertDialod(context, 'Password Mismatch', 'Passwords do not match!');
   }else{
     signUp(email, password);
   }
 }

 void signUp(String email, String password) async{
   UserCredential? credential;
   UIHelper.showLoadingDialog(context, 'Create a new account');
   try{
          credential = await FirebaseAuth.instance
         .createUserWithEmailAndPassword(email: email, password: password);
   } on FirebaseAuthException catch(ex){
     Navigator.pop(context);
     UIHelper.showAlertDialod(context, 'An error accrued', ex.code.toString());
   }
   if(credential!=null){
     String uid = credential.user!.uid;
     UserModel newUser = UserModel(
       uid: uid,
       email: email,
       fullname: '',
       profilepic: '',
     );
     await FirebaseFirestore
         .instance.collection('users').doc(uid).set(newUser.toMap())
         .then((value){
           
           log('new users created!');
           Navigator.popUntil(context, (route) => route.isFirst);
           Navigator.pushReplacement(
               context, 
               MaterialPageRoute(builder: (context){
                 return CompleteProfilePage(userModel: newUser, firebaseuser: credential!.user!);
               }));
     });
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
                  const SizedBox(height: 10,),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password'
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirm Password'
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CupertinoButton(
                    onPressed: checkValue,
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text('Sign Up'),
                  ),

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
            'Already have an account?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          CupertinoButton(
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
