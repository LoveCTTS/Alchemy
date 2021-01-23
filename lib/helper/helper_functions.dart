import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{

  //static => 프로그램 실행 -> 종료시까지 메모리에서 삭제되지않는다.

   static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
   static String sharedPreferenceUserNameKey = "USERNAMEKEY";
   static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
   static String sharedPreferenceUserPhoneNumberKey = "USERPHONENUMBERKEY";

  // SharedPreferences라는 클래스는 소,중량의 데이터를 저장하기위한 용도이며, 앱 종료후에도 데이터가 XML형태로 저장되어있기때문에,
  //재 실행 후에도 데이터를 그대로 가져와서 사용할 수 있음.

  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    //SharedPreferences 클래스의 변수 preferences를 생성
    //Sharedpreferences내의 getInstace()를 통해 그값을 preferences에 저장
    //await는 비동기식안에서 동기식으로 처리하고싶은부분 앞에 붙이는 키워드이기때문에 getInstance는 동기식으로 처리된다.

    return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);

  }

  static Future<bool> saveUserNameSharedPreference(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }

   static Future<bool> saveUserPhoneNumberSharedPreference(String userPhoneNumber) async{
     SharedPreferences preferences = await SharedPreferences.getInstance();
     return await preferences.setString(sharedPreferenceUserPhoneNumberKey, userPhoneNumber);
   }
  static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
     SharedPreferences preferences = await SharedPreferences.getInstance();
     return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
   }



  static Future<bool> getUserLoggedInSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getUserNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserNameKey);
  }

   static Future<String> getUserPhoneNumberSharedPreference() async{
     SharedPreferences preferences = await SharedPreferences.getInstance();
     return preferences.getString(sharedPreferenceUserPhoneNumberKey);
   }

  static Future<String> getUserEmailSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserEmailKey);
  }

}