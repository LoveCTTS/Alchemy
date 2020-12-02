import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/widgets/friend_tile.dart';
import 'package:linkproto/widgets/mikemessage_tile.dart';
import '../services/database_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/friendrequest_tile.dart';

class FriendsListPage extends StatefulWidget {

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {

  FirebaseUser _user;
  String _userName = '';
  Stream<QuerySnapshot> _chats; //QuerySnapshot 데이터가 여러개인 Stream형태 _chat변수
  TextEditingController messageEditingController = new TextEditingController();




  //TextEditingController형의 인스턴스를 저장하는 변수 messageEditingController 생성
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }


  getUserInfo() async{
    _userName = await HelperFunctions.getUserNameSharedPreference();
    _user = await FirebaseAuth.instance.currentUser();
  }

  void _popupFriendRequest(BuildContext context) {
    Widget closeButton = FlatButton(
        minWidth: 80,
        child: Text("Close"),
        onPressed: () async {
          Navigator.of(context).pop();
        });

    AlertDialog alert = AlertDialog(
        title: Text("친구 요청 목록 "),
        content: Container(
            width: 250,
            height: 300,
            child: ListView(children: [
              StreamBuilder(
                  stream: DatabaseService(uid:_user.uid, userName: _userName).userCollection.document(_userName).snapshots(),
                  builder: (context, snapshot) {
                    List<Widget> children;
                    if (snapshot.hasError) {
                      children = <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('Error: ${snapshot.error}'),
                        )
                      ];
                    }
                    if (!snapshot.hasData) {
                      return Text("Currently Not Friend",
                          style: TextStyle(fontSize: 30));
                    } else {
                      var friendRequestList = snapshot.data["request"];
                      return ListView
                          .builder(
                          itemCount: friendRequestList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            int reqIndex = friendRequestList.length - index - 1;
                            return FriendRequestTile(
                              receiverName: _userName,
                              senderName: friendRequestList[reqIndex].toString(),
                            );
                          }
                      );
                    }
                  }),

            ]
            )),

        actions: <Widget>[
          closeButton
        ]
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  //채팅 페이지 디자인 관련 코드인데, 직접 실시간으로 조절하면서 디자인하면되니 설명은 생략함.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("친구 목록", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black87,
            actions: <Widget>[
              SizedBox(
                  height: 20.0,
                  width: 35.0,
                  child: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.pinkAccent),
                    padding: EdgeInsets.all(0.0),
                    iconSize: 30,
                    onPressed: () {},
                  )
              ),

              SizedBox(
                  height: 20.0,
                  width: 35.0,
                  child: IconButton(
                    icon: Icon(Icons.person_add, color: Colors.purpleAccent),
                    padding: EdgeInsets.all(0.0),
                    iconSize: 30,
                    onPressed: () {
                      _popupFriendRequest(context);
                    },
                  )
              ),
            ]

        ),
        body:Container(
            width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: DatabaseService().userCollection.document(_userName).snapshots(),
                  builder: (context, snapshot) {
                    List<Widget> children;
                    if (snapshot.hasError) {
                      children = <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('Error: ${snapshot.error}'),
                        )
                      ];
                    }
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      var friendList = snapshot.data["friends"];
                      return StreamBuilder(
                          stream: DatabaseService(uid:_user.uid,userName: _userName).friendsChatCollection.snapshots(),
                          builder: (context, snapshot) {

                            List<Widget> children;
                            if(snapshot.hasError){

                              children = <Widget>[
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text('Error: ${snapshot.error}'),
                                )
                              ];
                            }
                            if(!snapshot.hasData) {
                              return CircularProgressIndicator();

                            }else{
                              List allFriendGroups = snapshot.data.documents.map((e) {return e.data;}).toList();
                            return ListView.builder(
                                itemCount: friendList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  int reqIndex = friendList.length - index - 1;
                                  return FriendTile(
                                    groupId: allFriendGroups[reqIndex]["groupId"],
                                    friendName: friendList[reqIndex],
                                  );
                                }
                            );
                            }
                          });
                    }
                  }
              ),
            )
        );
  }
}





