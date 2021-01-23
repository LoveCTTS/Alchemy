import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:linkproto/pages/signin_page.dart';
import 'package:linkproto/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';


// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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



class MyAppState extends State<MyApp> {



  @override
  void initState() { // 상태 초기화 함수(State<MyApp>에 이미 작성되어 있기 때문에, 상속받은 _MyAppState도 initState()사용가능

    // firebaseCloudMessaging_Listeners();

    super.initState(); //Sate<MyApp> 조상님 인스턴스 안에서 initSate 실행하여 상태 초기화(Super 키워드 이해할것!)
    

  }
  @override
  void dispose(){
    super.dispose();
  }

  /*void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print('token:'+token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }
  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
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

        theme: ThemeData(
            fontFamily: 'Raleway-Regular',
            primaryColor: Color(0xff9932cc)

        ), //MaterialAPP에 속하는 위젯 모두를 기본적으로 Dark Theme로 설정
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


