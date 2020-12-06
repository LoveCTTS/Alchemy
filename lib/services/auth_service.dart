import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../helper/helper_functions.dart';
import '../models/customuser.dart';
import '../services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; //Firebase서비스를 이용하기위해 인증과 관련된 인스턴스 생성



  // //FirebaseUser로 접속하였을때 User객체 생성 함수
  // CustomUser _userFromFirebaseUser(CustomUser user) {
  //   return (user != null) ? CustomUser(uid: user.uid) : null;
  //   //user이 null이 아니라면 ==> User생성자에 user.uid를 input하여 User인스턴스 생성 후 User형태 반환
  //   //user이 null이라면 ==> null을 반환
  //  }


  Stream<User> get authStateChanges => _auth.authStateChanges();
  //로그인페이지에서 이메일과 비밀번호를 입력하였을때 인증처리 과정을 보여주는 함수
  Future signInWithEmailAndPassword(String email, String password) async {
    try { //에러가 있을수도있는 명령어들은 try{ }안에 전부다 기입
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch(e) { //위 try에서 예외(Error)가 생겼다면, 그 오류정보가 매개변수 e에 저장이 되고, catch{ }안에서 에러를 어떻게 처리할것인지에 대한 명령어 기입
      return e.message;
    }
  }


  // 풀네임/이메일/비밀번호로 회원 등록할 때 쓰이는 함수
  Future registerWithEmailAndPassword(String fullName, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      //createUserWithEmailAndPassword를 통해 새로운 이메일과 비밀번호를 가진 인스턴스생성
      User user = result.user;
      //FirebaseUser에 새로운 user 초기화
      await DatabaseService(uid: user.uid,userName: fullName).updateUserData(fullName, email, password);
      //Firebase DB에 새로운 풀네임/이메일/비밀번호를 가진 user 갱신
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //로그아웃
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false); //로그인 되어있는지 안되어있는지 상태를 저장하는 변수를 false값으로 전환
      await HelperFunctions.saveUserEmailSharedPreference(''); //email정보도 null값으로 전환
      await HelperFunctions.saveUserNameSharedPreference(''); //이름도 null값으로 전환

      return await _auth.signOut().whenComplete(() async { //로그아웃이 잘완료되었다면
        print("Logged out");
        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          //getUserLoggedInSharedPreference를 통해 value매개변수에 false라는값이 저장됨.
          print("Logged in: $value"); //"Logged in: false" 출력 (" "안에 변수를 출력하고싶다면 변수앞에 $를 붙이면 된다.(Dart,Kotlin에서만)
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}