import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spekify/main.dart';
import 'package:spekify/models/message_model.dart';
import 'package:spekify/models/user_model.dart';
import '../models/chat_room_model.dart';
class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetUser, required this.chatRoom, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async{
    String msg = messageController.text.trim();
    messageController.clear();
    if(msg!=''){
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        createdOn: Timestamp.now(),
        seen: false,
      );
      FirebaseFirestore.instance.
      collection('chatrooms').doc(widget.chatRoom.chatroomid).
      collection('messages').doc(newMessage.messageId).set(newMessage.toMap());

      widget.chatRoom.lastMessage = msg;

      FirebaseFirestore.instance.
      collection('chatrooms').doc(widget.chatRoom.chatroomid).set(widget.chatRoom.toMap());


      log('message sent!');
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[500],
              backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.
                  collection('chatrooms').doc(widget.chatRoom.chatroomid).
                  collection('messages').orderBy('createdOn',descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.active){
                       if(snapshot.hasData){
                         QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                         return ListView.builder(
                           reverse: true,
                           itemCount: dataSnapshot.docs.length,
                           itemBuilder: (context,index){
                             MessageModel currentModel = MessageModel.fromMap(dataSnapshot.
                             docs[index].data() as Map<String,dynamic>);

                             return Row(
                               mainAxisAlignment:(currentModel.sender == widget.userModel.uid)? MainAxisAlignment.end:MainAxisAlignment.start,
                               children: [
                                 Container(
                                     margin: const EdgeInsets.symmetric(vertical: 2),
                                     padding: const EdgeInsets.symmetric(
                                       horizontal: 10,
                                       vertical: 10,
                                     ),
                                     decoration: BoxDecoration(
                                       color: (currentModel.sender == widget.userModel.uid) ?Colors.blueGrey[600] : Theme.of(context).colorScheme.secondary,
                                       borderRadius: BorderRadius.circular(5),
                                       ),


                                     child: Text(currentModel.text.toString(),
                                     style: const TextStyle(
                                       color: Colors.white,
                                     ),
                                     ),
                                 ),
                               ],
                             );
                           },
                         );

                       }else if(snapshot.hasError){
                         return const Center(
                           child: Text('An error accrued! please check your internet connection.'),
                         );
                       }else{
                         return const Center(
                           child: Text('Say hii to your new friends'),
                         );
                       }
                    }else{
                       return const Center(
                         child: CircularProgressIndicator(),
                       );
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                        controller: messageController,
                        minLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter message',
                        ),
                      ),
                  ),

                  IconButton(
                      onPressed: (){
                        sendMessage();
                      },
                      icon: Icon(Icons.send,color: Theme.of(context).colorScheme.secondary,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
