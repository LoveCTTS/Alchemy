import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linkproto/pages/create_nick_name_email.dart';
import 'package:linkproto/pages/email_verify.dart';
import 'package:linkproto/pages/phonenumber_verify.dart';
import '../services/google_auth_service.dart';
import '../helper/helper_functions.dart';
import 'home_page.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../shared/constants.dart';
import '../shared/loading.dart';

class SignInPage extends StatefulWidget {
  /*final Function toggleView; //함수형 변수 toggleView생성
  SignInPage({this.toggleView}); // 인스턴스생성 시 새로운 함수를 받아서 인스턴스에 저장*/

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService(); //인증서비스 이용을위해 AuthService 인스턴스 생성
  //final _formKey = GlobalKey<FormState>(); //현재 앱 전체에서 사용될수있는 독특한 키를 생성하기 위해 GlobalKey인스턴스 생성
  //bool _isLoading = false;



  // text field state
  String email = '';
  String password = '';
  String error = '';
  String fullName ='';
  GoogleAuthService _googleAuth = GoogleAuthService();



  /*_onSignIn() async {
    if (_formKey.currentState.validate()) { // GlobalKey가 올바르게 생성되었다면
      setState(() {
        _isLoading = true;
      });
      await _auth.signInWithEmailAndPassword(email, password).then((result) async { //이메일과 비밀번호를 입력받아서 인증하고, 결과를 result에 반환
        if (result != null) { //result에 값이 반환되었다면
          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(email); //매개변수 email에 저장된 email과 동일한 사용자의 데이터정보 저장
          await HelperFunctions.saveUserLoggedInSharedPreference(true); //사용자가 잘 로그인되었기때문에 true로 변경
          await HelperFunctions.saveUserEmailSharedPreference(email); //현재 사용자의 email을 저장
          await HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot.docs[0].data()["fullName"]
          );// 현재 사용자의 풀네임을 저장

          // 로그인이 잘된상태이기때문에 그것에 대한 출력을 하는 부분
          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          //로그인후 첫 페이지 어디로 할지 선정(현재 HomePage()로 설정 됨)
          //context에는 현재 클래스에서 가장 가까운 인스턴스의 상태를 저장하고있다.(이해하기어렵다면, 그냥 로그인 할때 사용자 정보를 context에 저장하고있다고보면된다.)
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        }
        //로그인 인증이 실패한경우
        else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }*/

  //바텀시트(이메일,휴대폰번호 가입하기)- 필요시 개발 착수
  /*void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.email),
                    title: new Text('이메일로 가입하기'),
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          EmailVerifyPage()));
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.phone),
                  title: new Text('휴대번호로 가입하기'),
                  onTap: () {
                  Navigator.push(
                  context, MaterialPageRoute(builder: (context) =>
                  PhoneNumberVerifyPage()));
                  },
                ),
              ],
            ),
          );
        }
    );
  }*/
  //이메일 가입버튼(필요시 개발착수)
  /*Widget _onEmailSignIn(){
    return GestureDetector(
      onTap: (){

        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmailVerifyPage()));
      },
      child: Container(
        width:200,
        height:40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.white
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.email), Text("이메일로 로그인")],)
      )
    );
  }*/
  Widget _onPhoneNumberSignIn(){
    return GestureDetector(
      onTap: () async{
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhoneNumberVerifyPage()));
      },
        child: Container(
            width:200,
            height:60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              border: Border.all(
                color: Colors.grey,
                width: 2
              ),

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.phone,color: Colors.purple,size: 40,), SizedBox(width:10),Text("휴대폰 번호로 로그인",style: TextStyle(color:Colors.white,fontSize: 20))],)
        )
    );
  }
  //회원가입버튼( 필요시 다시 개발진행)
  /*Widget signUp(){

    return GestureDetector(
        onTap: (){
          _settingModalBottomSheet(context);
        },
        child: Container(
            width:200,
            height:40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.white
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.perm_identity), Text("회원 가입")],)
        )
    );
  }*/
  Widget _onGoogleSignIn() {
              return OutlineButton(
                splashColor: Colors.grey,
                onPressed: () async{
                  _googleAuth.signInWithGoogle().then((result) async{
                    await DatabaseService().isGuserJoined(result.email).then((isJoined) async{
                      if(isJoined==true){

                        QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(result.email); //매개변수 email에 저장된 email과 동일한 사용자의 데이터정보 저장
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



                      }
                      else if(isJoined==false){

                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CreateNickNameEmailPage(result)));


                      }
                    });
                  });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey,width: 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '구글로 로그인하기',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( //로그인 성공시 Loading() / 실패시 Scaffold 실행(참고로 첫 로그인페이지화면과는 똑같이생겼지만, 여기 화면은 별개다.
      backgroundColor: Color(0xff212121),
      body: ListView(
                /*mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,*/
                children: <Widget>[
                  SizedBox(height:100),Center(child:Text("Alchemy", style: TextStyle(color: Colors.purpleAccent, fontSize: 100, fontFamily: 'Satisfy'))),
                  SizedBox(height:100),//앱 메인 제목(FittedBox를 통해 기기에 따라 유연하게 적용)
                  /*SizedBox(height: 20.0),
                
                  TextFormField( //입력칸 위젯
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: '이메일'), //입력칸 라벨

                    // email 입력시 규칙 적용
                    validator: (val) {
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please enter a valid email";
                    },

                    //사용자가 입력칸에 값이 변경(삽입/삭제/다른값으로 변경)
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    }, //
                  ),
                
                  SizedBox(height: 15.0),

                  //비밀번호 입력칸
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: '비밀번호'), //라벨
                    validator: (val) => val.length < 6 ? '비밀번호는 최소 6자리 이상' : null, // 비밀번호 규칙
                    obscureText: true,

                    //비밀번호 입력칸에 비밀번호가 변경(삽입/삭제/다른값으로 변경)
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),

                  SizedBox(height: 20.0),

                  //Sign in 버튼 디자인
                  SizedBox(
                    width: double.infinity, //RaisedButton에 Size조절이없어서 SizedBox로 너비조절
                    height: 50.0, // 높이 조절
                    child: RaisedButton(
                      elevation: 0.0, // 바꿔봐도 바뀌는게없음..(안중요)(z-coordinate at which to place this button relative to its parent 라고하는데 이해안됨.)
                      color: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text('로그인', style: TextStyle(color: Colors.white, fontSize: 16.0)),

                      //버튼을 누르면 직접 만든 _onSignIn()함수 실행
                      onPressed: () {
                        _onSignIn();
                      }
                    ),
                  ),*/

                
                  SizedBox(height: 10.0),
                  _onGoogleSignIn(),
                  //_onEmailSignIn(), 이메일 로그인
                  SizedBox(height: 10.0),
                  _onPhoneNumberSignIn(),
                  //유지보수를 위해 임시적으로만들어놓은 버튼
                  RaisedButton(onPressed: (){

                    _googleAuth.signOutGoogle();
                    FirebaseAuth.instance.signOut();
                  },
                  child: Text("signout",style: TextStyle(color:Colors.white)))


                  /*Center(child:Text.rich( //Text의 생성자 Text.rich
                    TextSpan(
                      text: "계정이 아직 없으신가요? ",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: '계정 생성',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline
                          ),

                          //아래 명령어에서 ..는 TapGestureRecognizer이라는 클래스의 인스턴스를 생성(TapGestureRecognizer() 이라고하면 바로 생성됨.(new TapGestureRecognizer()과 같은 의미))
                          //함과 동시에 바로 그 인스턴스안에있는 onTap 속성 or 필드를 사용하겠다는의미
                          //쉽게 말해서 아래 명령어는 register here 글을 누르면 register_page로 이동한다.(widget.toggleView()는 고정된 기능의 함수가 아니고,
                          //signin_page에 들어오는 함수가 항상 바뀔수있도록 작성해놨기때문에 항상 다른 함수로 바뀔수있다.
                          //참고로 onTap에는 () {widget.toggleView;}형태의 이름없는 함수의 주소가 저장이 됨. ()는 매개변수가 표기되는곳인데, 여기서는 매개변수 사용안함

                         recognizer: TapGestureRecognizer()..onTap = () {

                           Navigator.push(context, MaterialPageRoute(builder: (context) =>
                               PhoneNumberVerifyPage()));
                            //widget.toggleView();
                          },
                        ),
                      ],
                    ),
                  ))*/

                ],
              ));
  }
}
