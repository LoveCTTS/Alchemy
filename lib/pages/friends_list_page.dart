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

  User _user;
  String _userName = '';


  //TextEditingController형의 인스턴스를 저장하는 변수 messageEditingController 생성
  @override
  void initState() {
    getUserInfo();
    super.initState();

  }


  @override
  void dispose(){

    super.dispose();
    getUserInfo().dispose();
  }

  getUserInfo() async{

    _user = FirebaseAuth.instance.currentUser;

    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
    //indexOf를 통해 문자열에서 _(언더바)의 위치를 알아내서 인덱스값을 반환하게되면, res.substring(0, 인덱스값) 형태가 되니깐. 그룹Id를 문자열로 반환하게됨
  }


  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
    //"그룹ID_그룹이름" 형태의 문자열에서 indexOf('_')를 이용해 _(언더바)가 있는 인덱스 위치를 알아내고, +1을 하여 subString을 호출하면 그룹이름만 문자열로 반환한다.
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
                  stream: DatabaseService().userCollection.doc(_userName).snapshots(),
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
                      var friendRequestList = snapshot.data["request"]; //이부분 data가 data()로 패치됬다고 되있는데 data()라고 하면 실행이 DocumentSnapshot noSuchMethod Error 뜸 -_-;
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
        body: StreamBuilder(
            stream: DatabaseService().userCollection.doc(_userName).snapshots(),
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

                        return ListView.builder(
                            itemCount: friendList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              int reqIndex = friendList.length - index - 1;
                              return FriendTile(
                                friendChatGroupId: _destructureId(friendList[reqIndex]),
                                friendName: _destructureName(friendList[reqIndex]),
                              );
                            }
                            );
              }
            }
        ),

    );
  }
}






