import 'dart:developer';

import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:spekify/models/ui_helper.dart';
import 'package:spekify/models/user_model.dart';
import 'package:spekify/pages/home_page.dart';
class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const CompleteProfilePage({Key? key, required this.userModel, required this.firebaseuser}) : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async{
   XFile? pickedFile = await ImagePicker().pickImage(source: source);
   if(pickedFile!=null){
     croImage(pickedFile);
   }
  }
  void croImage(XFile file) async{
   File? cropedImage = await ImageCropper().cropImage(
     sourcePath: file.path,
     aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
     compressQuality: 15,
   );
   if(cropedImage!=null){
    setState(() {
      imageFile = cropedImage;
    });
   }
  }

  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('Upload Profile Picture!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: const Icon(Icons.photo_album),
              title: const Text('Select from gallery'),
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
            ),
          ],
        ),
      );
    }
    );
  }

  void checkValues(){
    String fullName = fullNameController.text.trim();
    if(fullName =='' || imageFile==null){
      UIHelper.showAlertDialod(context, 'Incomplete Data','please fill all the fields and upload the profile picture');

    }else{
      log(fullName);
      log(imageFile.toString());
      log('Data Uploading!');
      uploadData();
    }
  }
  void uploadData() async{
     UIHelper.showLoadingDialog(context, 'Uploading image...');

     UploadTask uploadTask = FirebaseStorage.instance.ref('profilepictures').child(widget.userModel.uid.toString()).putFile(imageFile!);
     TaskSnapshot snapshot = await uploadTask;
     log(snapshot as String);

     String? imageUrl = await snapshot.ref.getDownloadURL();
     String? fullName = fullNameController.text.trim();

     widget.userModel.fullname =fullName;
     widget.userModel.profilepic=imageUrl;

     await FirebaseFirestore.instance.collection('users').
     doc(widget.userModel.uid).set(widget.userModel.toMap()).
     then((value){
       log('Data Uploaded!');
       Navigator.popUntil(context, (route) => route.isFirst);
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseuser);
     }));
     });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,//stop back option
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(height: 20,),
              CupertinoButton(
                onPressed: (){
                  showPhotoOptions();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:imageFile!=null? FileImage(imageFile!):null,
                  child:imageFile==null? const Icon(Icons.person,size: 60,):null,
                ),
              ),
              const SizedBox(height: 20,),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name'
                ),
              ),
              const SizedBox(height: 20,),
              CupertinoButton(
                onPressed:checkValues,
                color: Theme.of(context).colorScheme.secondary,
                child: const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
