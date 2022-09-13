import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spekify/models/chat_room_model.dart';
import 'package:spekify/models/firebase_helper.dart';
import 'package:spekify/models/user_model.dart';
import 'package:spekify/pages/chat_room_page.dart';
import 'package:spekify/pages/login_page.dart';
import 'package:spekify/pages/search_page.dart';
class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({Key? key, required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Spekify'),
        actions: [
          IconButton(
              onPressed: ()async{
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context){
                    return const LogInPage();
                   }
                 )
                );
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.
          collection('chatrooms').where('participants.${widget.userModel.uid}',isEqualTo: true).snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.active){
                if(snapshot.hasData){
                 QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                 return ListView.builder(
                   itemCount: chatRoomSnapshot.docs.length,
                   itemBuilder: (context,index){
                     ChatRoomModel chatRoomModel = ChatRoomModel.
                     fromMap(chatRoomSnapshot.docs[index].data() as Map<String,dynamic>);
                     Map<String,dynamic> participants = chatRoomModel.participants!;
                     List<String> participantsKey = participants.keys.toList();
                     participantsKey.remove(widget.userModel.uid);
                     return FutureBuilder(
                       future: FirebaseHelper.getUserModelById(participantsKey[0]),
                       builder: (context,userData){
                         if(userData.connectionState==ConnectionState.done){
                           if(userData.data!=null){
                             UserModel targetUser = userData.data as UserModel;
                             return ListTile(
                               onTap: (){
                                 Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                         builder: (context){
                                           return ChatRoomPage(
                                               targetUser:  targetUser,
                                               chatRoom: chatRoomModel,
                                               userModel: widget.userModel,
                                               firebaseUser: widget.firebaseUser,
                                           );
                                         }
                                         )
                                 );
                               },
                               leading: CircleAvatar(
                                 backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                               ),
                               title: Text(targetUser.fullname.toString()),
                               subtitle:(chatRoomModel.lastMessage.toString()!='')?
                               Text(chatRoomModel.lastMessage.toString()):
                               Text(
                                   'Say hi to your new friends!',
                                   style: TextStyle(
                                   color:Theme.of(context).colorScheme.secondary,
                               ),
                               ),
                             );
                           }else{
                             return Container();
                           }

                         }else{
                           return Container();
                         }

                       },
                     );

                   },
                 );
                }else if(snapshot.hasError){
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }else{
                  return const Center(
                    child: Text('No chats!'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
