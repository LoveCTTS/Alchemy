import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:linkproto/pages/position_error_page.dart';


class TestPage2 extends StatefulWidget {
  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage2> {



  @override
  void initState() {
    super.initState();

    _determinePosition();
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return Future.error('Location services are disabled.');
    }

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
      appBar: AppBar(
        title: Text(
          "hello", style: TextStyle(color:Colors.white)
        ),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _determinePosition();
        },
      ),
    );
  }

}

