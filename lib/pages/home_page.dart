import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/helper_functions.dart';
import '../pages/authenticate_page.dart';
import '../pages/chat_page.dart';
import '../pages/search_page.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/group_tile.dart';
import 'group_page.dart';
import 'test_page.dart';
import 'agora_page.dart';
import 'friends_list_page.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex=1; //하단 바 터치시 이동하기위한 정수형 Index변수 생성

  String friendsListPageuserName='';
  final List _children = [FriendsListPage(),AgoraPage(),GroupPage(),ProfilePage()];//터치시 각 위젯으로 가기 위한 클래스들을 저장한 리스트변수 생성
  //변경이 되면 안되기때문에 final 키워드 사용(Constant랑 같은 의미)

  @override
  void initState() {
    super.initState();

    prepareService();

  }

  void prepareService() async{

    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        friendsListPageuserName = value;
        _children[0]=FriendsListPage(userName: friendsListPageuserName);
      });
    });
  }
  // Building the HomePage widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(child:_children.elementAt(_currentIndex)),
        //_currentIndex가 터치시마다 유동적으로 바뀌면서 elementAt에 인자로서 보내지고,
        //Center에 의해서 위젯이 중간에 배치된다.

        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (int index){ //매개변수 index(터치된 아이콘의 인덱스값이 index에 복사됨
              setState((){ //상태 set
                _currentIndex = index; //현재 인덱스값을 터치한 아이콘의 index로 변경
              });
            },

            backgroundColor: Color(0xff9932cc),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            items: [
              new BottomNavigationBarItem(
                icon: Icon(Icons.chat, size:20.0),
                title: Text('친구'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.language, size:20.0),
                title: Text('아고라'),

              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size:20.0),
                title: Text('내 그룹'),

              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.account_circle, size:20.0),
                title: Text('프로필'),

              )
            ]));
  }
}
