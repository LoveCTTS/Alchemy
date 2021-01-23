/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/pages/create_nick_name_email.dart';
import 'package:linkproto/pages/home_page.dart';

class EmailVerifyPage2 extends StatefulWidget {
  @override
  EmailVerifyPage2State createState() => EmailVerifyPage2State();
}

class EmailVerifyPage2State extends State<EmailVerifyPage2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        body:Container(

          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                IconButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                    icon: Icon(Icons.arrow_back)),

                Text("가입하기",style: TextStyle(color: Colors.black,fontSize: 30)),
                SizedBox(height:10),
                Text("이메일 함에 전송된 인증 링크를 클릭해주세요."),
                SizedBox(height:30),
                GestureDetector(
                    onTap: (){
                      if()
                      User user = FirebaseAuth.instance.currentUser;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CreateNickNameEmailPage(user)));
                    },
                    child:Container(
                        alignment: Alignment.center,
                        width:MediaQuery.of(context).size.width,
                        height:50,
                        color: Colors.blue,
                        child: Text("다음")
                    ))




          ]),
    ));
  }
}

*/
