import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/pages/signin_page.dart';
import 'package:linkproto/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'helper/helper_functions.dart';
import 'pages/authenticate_page.dart';
import 'pages/home_page.dart';
import 'pages/test_page.dart';
import 'routes/routes.dart';


//메인에서 runApp을 통해 MyApp 클래스 실행
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override //StatefulWidget으로부터 상속받은 기능이나 변수들을 Customizing하여 사용
  MyAppState createState() => MyAppState(); //createState(){ new _MyAppState }

}


class MyAppState extends State<MyApp> { //State<MyApp>으로부터 상속받은 _MyAppState

  bool _isLoggedIn = false; // 로그인 안되있는상태로 시작

  @override
  void initState() { // 상태 초기화 함수(State<MyApp>에 이미 작성되어 있기 때문에, 상속받은 _MyAppState도 initState()사용가능
    super.initState(); //Sate<MyApp> 조상님 인스턴스 안에서 initSate 실행하여 상태 초기화(Super 키워드 이해할것!)
   // _getUserLoggedInStatus();//_getUserLoggedInStatus()함수 호출


  }


//로그인 되었는지 안되었는지 상태 정보 얻기(old version)
 /* _getUserLoggedInStatus() async { //_getUserLoggedInStatus를 비동기식으로 사용하겠다고 선언
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) { //HelperFunctions내의 getUserLoggedInSharedPreference를 동기식 호출
      //then을 이용해서 getUserLoggedinSharedPreference의 반환값을 value라는 매개변수에 저장한 이후 아래 코드블록으로 진입
      var result; //비어있는 result 선언 --> 기본적으로 선언과 동시에 null값 저장되어있음

      if(result != null) { //result가 null값이 아니라면
        setState(() {
          _isLoggedIn = value; //기본적으로 false가 저장된 inLoggedIn에 value내에 저장된 값을 초기화
        });
      }
    });
  }*/


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),

        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
        )
      ],

      child: MaterialApp(
        home: AuthenticationWrapper(),
        theme: ThemeData(fontFamily: 'Raleway-Regular'), //MaterialAPP에 속하는 위젯 모두를 기본적으로 Dark Theme로 설정
        darkTheme: ThemeData.dark(),
      ),

    );
  }
}

class AuthenticationWrapper extends StatelessWidget{

  const AuthenticationWrapper({Key key}): super(key: key);

  @override
  Widget build(context){
    final firebaseUser = context.watch<User>();
    if(firebaseUser != null){
      return HomePage();
    }
    return SignInPage();
  }
}
