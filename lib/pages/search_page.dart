import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spekify/main.dart';
import 'package:spekify/models/chat_room_model.dart';
import 'package:spekify/models/user_model.dart';
import './chat_room_page.dart';
class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async{
    ChatRoomModel? chatRoom;
    //QuerySnapshot snapshot =  await FirebaseFirestore.instance.collection('chatrooms').get();
    QuerySnapshot snapshot =  await FirebaseFirestore.instance.collection('chatrooms').
    where('participants.${widget.userModel.uid}',isEqualTo: true).
    where('participants.${targetUser.uid}', isEqualTo: true).get();
    log('participants.${widget.userModel.uid}');
    log('participants.${targetUser.uid}');
    log(snapshot.docs.length.toString());

    if(snapshot.docs.isNotEmpty){
     //log('chat room already created!');
     var docData = snapshot.docs[0].data();
     ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData as Map<String , dynamic>);

     chatRoom = existingChatRoom;

    }else{
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: '',
        participants: {
          widget.userModel.uid.toString():true,
          targetUser.uid.toString():true,
        }
      );
      await FirebaseFirestore.instance.
      collection('chatrooms').doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
      chatRoom = newChatRoom;
      log('new char room created!');
   }
   return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                ),
              ),
              const SizedBox(height: 20,),
              CupertinoButton(
                  child: const Text('Search'),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: (){
                    setState(() {

                    });
                  }
              ),
              StreamBuilder<QuerySnapshot>(

                  stream: FirebaseFirestore.instance.collection('users')
                      .where("email" ,isEqualTo: searchController.text.trim().toString()).where('email', isNotEqualTo: widget.userModel.email).snapshots(),
                  builder: (context , snapshot){
                     if(snapshot.connectionState==ConnectionState.active){
                       if(snapshot.hasData){
                         QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                         // print(dataSnapshot.size);
                         // print(dataSnapshot.docs.first.toString());
                         if(dataSnapshot.docs.isNotEmpty){
                           Map<String , dynamic> userMap = dataSnapshot.docs[0].data() as Map<String,dynamic>;
                           UserModel searchModel = UserModel.fromMap(userMap);
                           return ListTile(
                             onTap: () async{
                               ChatRoomModel? chatRoomModel = await getChatRoomModel(searchModel);
                               if(chatRoomModel != null){
                                 Navigator.pop(context);
                                 Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context){
                                       return ChatRoomPage(
                                           targetUser: searchModel,
                                           chatRoom: chatRoomModel,
                                           userModel: widget.userModel,
                                           firebaseUser: widget.firebaseUser
                                       );
                                     },
                                     ),
                                 );
                               }
                             },

                             leading: CircleAvatar(
                               backgroundImage: NetworkImage(searchModel.profilepic!),
                               backgroundColor: Colors.grey[500],
                             ),
                             title: Text(searchModel.fullname!),
                             subtitle: Text(searchModel.email!),
                             trailing: const Icon(Icons.keyboard_arrow_right),
                           );
                         }else{
                           return const Text('No result found!');
                         }

                       }else if(snapshot.hasError){
                         return const Text('An error accrued!');
                       }else{
                         return const Text('No result found!');
                       }
                     }else{
                       return const CircularProgressIndicator();
                     }
                  }
              ),

            ],
          ),
        ),
      ),
    );
  }
}
