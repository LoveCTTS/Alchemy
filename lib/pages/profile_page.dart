import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/services/auth_service.dart';
import 'package:linkproto/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authenticate_page.dart';
import 'package:geolocator/geolocator.dart';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final AuthService _auth = AuthService();
  File _image;
  FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
  User _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<String> _profileImageURL=List<String>(6);
  final picker = ImagePicker();
  List<bool> _hasNetworkImage = List<bool>.generate(6, (index) => false); //6개의 false값을 가지고있는 배열생성
  String _userName='';
  Reference _storageReference;
  bool distanceSwitched=false;
  bool ageSwitched=false;
  String appealContents='';
  String local='';
  String hashTag='';
  final _picker = ImagePicker();

  //사용자가 프로필에서 편집하는 데이터를 제어하기위한 인스턴스
  TextEditingController appealController= TextEditingController();
  TextEditingController hashTagController= TextEditingController();
  TextEditingController localController= TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  initState() {

    _prepareService();
    appealController.addListener(() { });
    hashTagController.addListener(() { });
    localController.addListener(() { });
    ageController.addListener(() { });
    super.initState();

  }
  @override
  void dispose(){
    super.dispose();
    ageController.dispose();
    localController.dispose();
    hashTagController.dispose();
    appealController.dispose();
    _prepareService().dispose();

  }

  _prepareService() async{
    _user= _firebaseAuth.currentUser;
    _userName=await HelperFunctions.getUserNameSharedPreference();

    await DatabaseService(userName: _userName).getUserAppeal().then((value){
      setState(() {
        appealController.text = value;
      });
    });
    await DatabaseService(userName: _userName).getUserLocal().then((value){
      setState(() {
        localController.text = value;
      });
    });
    await DatabaseService(userName: _userName).getUserHashTag().then((value){
      setState(() {
        hashTagController.text = value;
      });
    });
    await DatabaseService(userName: _userName).getUserAge().then((value){
      setState(() {
        ageController.text = value;
      });
    });
    for(int i=0;i<6;i++) {
      _hasNetworkImage[i] =await hasNetworkImage(i);
    }

  }

  void _deleteImageFromStorage(int number) async{

    Reference _storageReference = _firebaseStorage.ref('user_image/$_userName' + '[$number]');
    String downloadURL = await _storageReference.getDownloadURL();
    _storageReference = FirebaseStorage.instance.ref(downloadURL);
    _storageReference.delete();
    setState(() {
      _profileImageURL[number] = downloadURL;
      _hasNetworkImage[number] = false;
    });

  }
  void _uploadImageToStorage(ImageSource source,int number) async {
    PickedFile pickedFile = await _picker.getImage(source: source);

    File image = File(pickedFile.path);

    if (image == null) return;

    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    Reference storageReference = _firebaseStorage.ref('user_image/$_userName' + '[$number]');

    try{
      await storageReference.putFile(_image);

    }on FirebaseException catch (e){
      print("Failed Upload");
    }




    String downloadURL = await storageReference.getDownloadURL();



    if(downloadURL!=null){

      setState(() {
        _profileImageURL[number] = downloadURL;
        _hasNetworkImage[number] = true;

      });
    }
    // 업로드된 사진의 URL을 페이지에 반영

  }

    Future<bool> hasNetworkImage(int number) async{

    Reference storageReference =
    _firebaseStorage.ref("user_image/$_userName"+ "[$number]");

    String downloadURL = await storageReference.getDownloadURL();
    if(downloadURL == null){
      return false;
    }else if(downloadURL != null){
      setState((){
        _profileImageURL[number] = downloadURL;
      });
      return true;
    }
    return false;
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
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }

  void _popupEdit(BuildContext context,int number) {


    AlertDialog edit = AlertDialog(
      content: Container(
          width: 250,
          height: 150,
          child:Column(children: [

            TextButton(
                onPressed: () {
                   _uploadImageToStorage(ImageSource.gallery, number);

                },
                child: Text("업로드")),
            TextButton(
                onPressed: () {
                  _deleteImageFromStorage(number);
                },

                child: Text("삭제하기")),
          ]
          )
      ) ,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return edit;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            child:ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0,horizontal: 0),
          children: <Widget>[

                Row(
                children: [
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,0);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[0]? NetworkImage(_profileImageURL[0]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,1);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[1]? NetworkImage(_profileImageURL[1]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,2);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[2]? NetworkImage(_profileImageURL[2]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                ]),
            Row(
                children: [
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,3);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[3]? NetworkImage(_profileImageURL[3]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,4);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[4]? NetworkImage(_profileImageURL[4]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,5);
                      },
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Align(alignment: Alignment.center,child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Colors.red))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[5]? NetworkImage(_profileImageURL[5]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                ]),
            SizedBox(height: 23.0),
            TextField(
                maxLines: null,
                controller: appealController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 10.0),
                    border: OutlineInputBorder(),
                    labelText: "자기소개"
                )
            ),
            SizedBox(height:30),
            TextField(

                controller: hashTagController,
                maxLines: 2,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(),
                  labelText: '관심 해시태그 ',
                )
            ),
            SizedBox(height:30),
            TextField(

                controller: ageController,
                maxLines: 1,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(),
                  labelText: '나이',
                )
            ),
            SizedBox(height:30),
            TextField(
                maxLines: 1,
                controller: localController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(),
                  labelText: '거주지 ',
                )
            ),

            Row(children: [
              Text("나이 표시"),
              Switch(
                  activeColor: Colors.pinkAccent,
                  value: ageSwitched,
                  onChanged: (value) {
                    setState(() {
                      ageSwitched = value;
                      print(ageSwitched);
                    }
                    );
                  }
              )
            ]),
            Row(children: [
              Text("거리 표시"),
              Switch(
                  activeColor: Colors.pinkAccent,
                  value: distanceSwitched,
                  onChanged: (switched){
                    setState(() {
                      distanceSwitched = switched;
                      print(distanceSwitched);
                    }
                    );
                    if(distanceSwitched){
                      _determinePosition().then((value){
                        DatabaseService(userName: _userName).updateLocationFromGPS(value.latitude, value.longitude);

                      });
                    }else if(distanceSwitched == false){

                      DatabaseService(userName: _userName).deleteLocationFromGPS();


                    }
                  }
              )
            ]),

            TextButton(onPressed: (){
              DatabaseService(userName: _userName).updateAppeal(appealController.text);
              DatabaseService(userName: _userName).updateLocal(localController.text);
              DatabaseService(userName: _userName).updateHashTag(hashTagController.text);
              DatabaseService(userName: _userName).updateAge(ageController.text);
            }, child: Text("저장하기")),

            ListTile(
              onTap: () async {

                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.clear();
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticatePage()), (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        )
        )
    );
  }
}


