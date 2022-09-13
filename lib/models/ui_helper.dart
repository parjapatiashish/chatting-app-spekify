import 'package:flutter/material.dart';
class UIHelper{
  static void showLoadingDialog(BuildContext contex , String title){
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 30,),
            Text(title),
          ],
        ),
      ),
    );
    showDialog(
        context: contex,
        barrierDismissible: false,
        builder: (contex){
      return loadingDialog;
    });
  }
  static void showAlertDialod(BuildContext context , String title , String content){
    AlertDialog alertDialog = AlertDialog(
      title : Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            },
          child: const Text('Ok'),
        ),
      ],
    );
   showDialog(context: context, builder: (content){
     return alertDialog;
   }
   );

  }
}
