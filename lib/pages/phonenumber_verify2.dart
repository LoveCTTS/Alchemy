import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/create_nick_name_phone.dart';
import 'package:linkproto/pages/home_page.dart';
import 'package:linkproto/services/auth_service.dart';
import 'package:linkproto/services/database_service.dart';
import 'package:pinput/pin_put/pin_put.dart';

class PhoneNumberVerify2Page extends StatefulWidget {
  final String phoneNumber;


  PhoneNumberVerify2Page(this.phoneNumber);
  @override
  PhoneNumberVerify2PageState createState() => PhoneNumberVerify2PageState();
}

class PhoneNumberVerify2PageState extends State<PhoneNumberVerify2Page> {


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String verificationCode='';
  final FocusNode pinPutFocusNode = FocusNode();
  TextEditingController pinCodeController= TextEditingController();
  final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(43, 46, 66, 1),
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(
        color: const Color.fromRGBO(126, 203, 224, 1),
      ),
  );


  @override
  void initState() {
    verifyPhoneNumber();
    pinCodeController.addListener(() { });
    super.initState();
  }

  /*
  registerPhoneUserInDB() async{
    await DatabaseService().setPhoneUserData(nickNameController.text, widget.result.phoneNumber);
    QuerySnapshot userInfoSnapshot = await DatabaseService()
        .getPhoneUserData(widget.result
        .phoneNumber); //매개변수 email에 저장된 email과 동일한 사용자의 데이터정보 저장
    await HelperFunctions
        .saveUserLoggedInSharedPreference(
        true); //사용자가 잘 로그인되었기때문에 true로 변경
    await HelperFunctions.saveUserNameSharedPreference(
        userInfoSnapshot.docs[0].data()["nickName"]);
    // 로그인이 잘된상태이기때문에 그것에 대한 출력을 하는 부분
    print("Signed In");
    await HelperFunctions
        .getUserLoggedInSharedPreference().then((value) {
      print("Logged in: $value");
    });
    await HelperFunctions
        .getUserPhoneNumberSharedPreference().then((
        value) {
      print("Phone Number: $value");
    });
    await HelperFunctions.getUserNameSharedPreference()
        .then((value) {
      print("Nick Name: $value");
    });

  }

   */
  void _popupTest(BuildContext context) {

    AlertDialog alert = AlertDialog(

      insetPadding: EdgeInsets.symmetric(horizontal: 40),
      title: Row(children: [ Text("친구 요청 목록",style: TextStyle(color:Colors.white)),
        SizedBox(width:65),
        IconButton(
          icon:Icon(Icons.close_rounded,color: Colors.white,),
          onPressed: (){
            Navigator.of(context).pop();
          },
        )]),
      backgroundColor: Color(0xff212121),
      content: Text("test"),

    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  verifyPhoneNumber() async{
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+1${widget.phoneNumber}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
            if (value.user != null) {

            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int resendToken) {
          setState(() {
            verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 60));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: scaffoldKey,
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
                  Icon(Icons.phone,size: 100), Text("내 인증번호:",style:TextStyle(color: Colors.white, fontSize: 30))
                ],),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: PinPut(
                  fieldsCount: 6,
                  textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
                  eachFieldWidth: 40.0,
                  eachFieldHeight: 55.0,
                  focusNode: pinPutFocusNode,
                  controller: pinCodeController,
                  submittedFieldDecoration: pinPutDecoration,
                  selectedFieldDecoration: pinPutDecoration,
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                  onSubmit: (pin) async{
                    try {

                      await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: verificationCode, smsCode: pin))
                          .then((value) async {
                        if (value.user != null) {

                          //print(value.user.phoneNumber);

                          /*await DatabaseService().isPhoneUserJoinedByNumber(value.user.phoneNumber).then((isJoined){
                            if(isJoined==false){
                              print("I'm not joined!");

                            }

                          });

                           */
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                              CreateNickNamePhonePage(value.user)));


                        }
                    });} catch (e) {
                      FocusScope.of(context).unfocus();
                      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('인증번호를 잘못 입력하였습니다.')));
                    }
                  }

                ),
              ),
              SizedBox(height:50),

            ],)
        )
    );
  }
}

