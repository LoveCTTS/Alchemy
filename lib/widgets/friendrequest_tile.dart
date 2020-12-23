import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/agora_page.dart';


class FriendRequestTile extends StatefulWidget {
  //그룹 타일도 한번 실행후 상태 변화가 없기때문에 StatelessWidget 사용

  final String receiverName;
  final String senderName;
  final String friendChatGroupId;

  FriendRequestTile(
      {this.receiverName, this.senderName, this.friendChatGroupId});

  @override
  FriendRequestTileState createState() => FriendRequestTileState();

}
class FriendRequestTileState extends State<FriendRequestTile>{


  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL= '';
  bool _hasNetworkImage=false;

  @override
  void initState() {

    super.initState();
    prepareSerivce();
  }

  void prepareSerivce() async{
    _hasNetworkImage= await hasNetworkImage();
  }
  hasNetworkImage() async{

    Reference storageReference =
    _firebaseStorage.ref('user_image/${widget.senderName}' + '[1]');
    String downloadURL = await storageReference.getDownloadURL();
    if(downloadURL == null){
      return false;
    }else if(downloadURL != null){
      setState((){
        _profileImageURL = downloadURL;
      });
      return true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

              );
            },
          );
        },
        child:Container( //Card size 조절하기위한 SizedBox
            height:70.0,
            width: MediaQuery.of(context).size.width,
             //ListTile을 조금 더 쉽게 나은 디자인을하기 위한 Card
            child:Row(
                children:[
              Container(
                width:50,
                height:50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: _hasNetworkImage? NetworkImage(_profileImageURL):AssetImage("images/default.png"),
                  ),
                ),
              ),SizedBox(width:10),
              Text(widget.senderName,style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width:50),
              Expanded(child:TextButton(
                  child:Text("수락", style: TextStyle(color:Colors.greenAccent, fontWeight: FontWeight.bold)),
                onPressed: () async{
                  await DatabaseService(userName: widget.receiverName).createFriendsChatGroup(widget.receiverName, widget.senderName).then((value){
                    DatabaseService(userName: widget.receiverName).permitFriendRequest(value,widget.senderName);
                  });

                },

              )),
              Expanded(
                  child:TextButton(
                      child:Text("거절",style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: (){
                      DatabaseService(userName: widget.receiverName).rejectFriendRequest(widget.senderName);
                    },
                  ))

            ])

        )

    );
  }
}