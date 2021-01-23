import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/services/database_service.dart';
import 'home_page.dart';

class CreateNickNameEmailPage extends StatefulWidget {

  final User result;

  CreateNickNameEmailPage(this.result);

  @override
  CreateNickNameEmailPageState createState() => CreateNickNameEmailPageState();
}

class CreateNickNameEmailPageState extends State<CreateNickNameEmailPage> {

  TextEditingController nickNameController= TextEditingController();

  @override
  void initState() {
    nickNameController.addListener(() { });
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //앱바 색을 Scaffold와 일치시켜도 다르게 나타나기때문에 투명화 시킨 후 elevation을 0.0으로 주면 투명화 되면서 동시에 appBar기능 사용가능
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: Color(0xff212121),
        body: Container(
            child:Column(children: [
              Row(
                children: [
                  Icon(Icons.phone,size: 100), Text("내 닉네임:",style:TextStyle(color: Colors.white, fontSize: 30))
                ],),
              TextField(
                  controller: nickNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: "닉네임을 입력해주세요.",
                  ),
                  style: TextStyle(
                      color: Colors.black
                  )
              ),SizedBox(height:50),
              GestureDetector(
                  onTap: () async{
                          await DatabaseService().setUserData(nickNameController.text, widget.result.email);

                          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(widget.result.email); //매개변수 email에 저장된 email과 동일한 사용자의 데이터정보 저장
                          await HelperFunctions.saveUserLoggedInSharedPreference(true); //사용자가 잘 로그인되었기때문에 true로 변경
                          await HelperFunctions.saveUserNameSharedPreference(userInfoSnapshot.docs[0].data()["nickName"]);
                          // 로그인이 잘된상태이기때문에 그것에 대한 출력을 하는 부분
                          print("Signed In");
                          await HelperFunctions
                              .getUserLoggedInSharedPreference().then((value) {
                            print("Logged in: $value");
                          });
                          await HelperFunctions
                              .getUserEmailSharedPreference().then((
                              value) {
                            print("Email: $value");
                          });
                          await HelperFunctions.getUserNameSharedPreference()
                              .then((value) {
                            print("Nick Name: $value");
                          });

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                        },
                  child: Container(
                      alignment: Alignment.center,
                      color: Colors.blue,
                      width:MediaQuery.of(context).size.width,
                      child:Text("다음",style: TextStyle(color: Colors.white,fontSize: 30))
                  ))
            ],)
        )
    );
  }
}

