import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/create_nick_name_email.dart';
import 'package:linkproto/pages/home_page.dart';
import 'package:linkproto/pages/position_error_page.dart';
import 'package:linkproto/services/database_service.dart';

class CheckPositionPage2 extends StatefulWidget {

  final result;
  CheckPositionPage2( this.result);
  @override
  CheckPositionPage2State createState() => CheckPositionPage2State();
}

class CheckPositionPage2State extends State<CheckPositionPage2> {


  @override
  initState(){
    super.initState();
    _determinePosition().then((value) async{
      QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(widget.result.email);
      await DatabaseService(userName: userInfoSnapshot.docs[0].data()["nickName"]).setLocationFromGPS(value.latitude, value.longitude);
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));

    });

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    /*serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return Future.error('Location services are disabled.');
    }
*/
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PositionErrorPage()));
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        )
    );
  }
}

