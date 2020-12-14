import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/helper_functions.dart';
import '../pages/search_page.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/group_tile.dart';


class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {

  // data
  final AuthService _auth = AuthService(); //
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _joinedGroups;

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  @override
  void dispose(){
    _getUserAuthAndJoinedGroups().dispose();
    super.dispose();
  }

  // 사용자가 아무 그룹에도 가입되어있지않았을때 뜨는 위젯(사용하지않을수도있어서 주석정리안함)
  Widget noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[
          GestureDetector(
            onTap: () {
              _popupDialog(context);
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0)
          ),
          SizedBox(height: 20.0),
          Text("You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below."),
        ],




      )
    );
  }


//사용자가 속한 그룹이 있다면 groupList를 통해 그룹들을 볼 수있고, 없다면 noGroupWidget함수로 이동
  Widget groupsList() {
    return StreamBuilder( //실시간으로 방이 생성되고 삭제되면 바로 적용해야되기때문에 StreamBuilder사용

      stream: _joinedGroups, //_groups에는 특정 사용자의 정보가 저장되어있음.(_groups는 snapshots()로부터 얻어온 정보를 사용하기때문에 StreamBuilder를 반드시 사용해야함.)
      
      builder: (context, snapshot) { //DB의 특정 유저의 snapshot(특정유저의 모든정보를 가지고있음)과 app의 context를 매개변수로 받아옴

        if(snapshot.hasData) { //특정 유저가 그룹정보를 가지고있다면

          if(snapshot.data['groups'] != null) { //특정유저의 데이터에서 groups라는 키에 매칭되는 배열의 주소가 null이 아니라면

            if(snapshot.data['groups'].length != 0) { //특정 유저의 데이터에서 groups라는 키에 매칭되는 배열의 요소의 개수가 0 이 아니라면

              return ListView.builder( //ListView.builder 생성자를 사용한 이유는 그룹이 정말 많이생성되어도 모두 다 리스팅될수도있도록 하기위함이다.(어몽어스처럼)

                itemCount: snapshot.data['groups'].length, //특정 유저의 groups키에 매칭되는 배열의 요소 개수를 itemCount에 저장(예를 들어 7개의 그룹에 속해있다면 7)
                shrinkWrap: true, // 스크롤 뷰의 범위를 보고있는 내용에따라 결정해야하는지 여부(별로 중요하지않음)
                itemBuilder: (context, index) {
                  int reqIndex = snapshot.data['groups'].length - index - 1; //reqIndex에 특정 유저가 속한 그룹의 수- 들어온 인덱스 값(index) - 1을 초기화

                  return GroupTile( //직접 만든 GroupTile 클래스를 이용해 인스턴스를 생성함과 동시에 아래 값들을 보냄

                      userName: _userName, //특정 유저의 풀네임을 userName에 저장

                      groupId: _destructureId(snapshot.data['groups'][reqIndex]),
                      //특정 유저의 groups키에 매칭되년 배열[reqIndex]값을 _destureId함수로 보내서 그룹ID만 groupId에 저장

                      groupName: _destructureName(snapshot.data['groups'][reqIndex]));
                      //특정 유저의 groups키에 매칭되는 배열[reqIndex] 값을 _destureName함수로 보내서 그룹이름만 groupName에 저장한다.
                }
              );
            }
            //유저가 그룹에 가입되어있지않다면
            else {
              return noGroupWidget();
            }
          }
          //유저가 그룹에 가입되어있지않다면
          else {
            return noGroupWidget();
          }
        }
        //사용자가 groups 키에 매칭되는 배열에 아무 값도 가지고있지않다면
        else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue, //로딩시 원의 뒷 배경 색
              strokeWidth: 20, //로딩되는 원의 두께
            )
            //로딩화면처럼 중간에 진행상황을 원으로 표시해주는 위젯(LinearProgressIndicator을 이용하면 게이지형식으로 표현가능)

          );
        }
      },
    );
  }



  _getUserAuthAndJoinedGroups() async {
    _user = FirebaseAuth.instance.currentUser; //현재 사용자에 대한 정보를 _user에 저장

    //SharedPreference에 저장된 username을 매개변수 value에 복사하고 현재 그룹페이지의 _userName에 초기화
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    //특정 유저가 속한 그룹정보를 매개변수 snapshot에 복사하고 그 정보를 _groups에 저장
    DatabaseService(userName: _userName).getUserSnapshots().then((snapshots) {
      // print(snapshots);
      setState(() {
        _joinedGroups = snapshots;
      });
    });
    //특정 유저의 이메일 정보를 SharedPreference로부터 반환받아서, 매개변수 value에 복사하여 현재 페이지의 _email에 저장
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
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


  //+ 버튼 눌렀을때 방만들기가 팝업 형식으로 생성되는 기능(사용하지않을수도있어서 주석 정리안함)

  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create"),
      onPressed:  () async {
        if(_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).createGroup(val, _groupName);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: TextField(
        onChanged: (val) {
          _groupName = val;
        },
        style: TextStyle(
          fontSize: 15.0,
          height: 2.0,
          color: Colors.black
        )
      ),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }





  // Building the GroupPage widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group', style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0.0,
         //기존에 오른쪽위에 검색 페이지로가는 버튼이지만, 일단 사용안하기때문에 주석처리 해둠
        /*
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            icon: Icon(Icons.search, color: Colors.white, size: 25.0), 
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
            }
          )
        ],
         */
      ),

      //소모임에서 앱바쪽 왼쪽 자기 프로필 보기 기능 필요없어서 일단은 주석처리하였지만, 하단바에 프로필에 활용할수있을수도있어서 안지우고 놔둠
      /*drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
            SizedBox(height: 15.0),
            Text(_userName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 7.0),
            ListTile(
              onTap: () {},
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Groups'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage(userName: _userName, email: _email)));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticatePage()), (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),

       */

      body: groupsList(), //Scaffold 클래스의 body 속성에는 하나의 클래스만 적용가능하다.

       //오른쪽 하단 기존의 + 버튼으로 방만들기 기능 (사용 안함)
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      )
    */
    );

  }
}

