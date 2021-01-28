import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkproto/helper/helper_functions.dart';
import 'package:linkproto/pages/signin_page.dart';
import 'package:linkproto/services/admob.dart';
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
  bool distanceSwitched=true;
  bool ageSwitched=true;
  String appealContents='';
  String local='';
  String hashTag='';
  final _picker = ImagePicker();
  FToast fToast;
  AdMobManager adMob = AdMobManager();




  //사용자가 프로필에서 편집하는 데이터를 제어하기위한 인스턴스
  TextEditingController appealController= TextEditingController();
  // TextEditingController hashTagController= TextEditingController();
  //TextEditingController localController= TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  initState() {

    fToast = FToast();
    fToast.init(context);
    _prepareService();
    appealController.addListener(() { });
    ageController.addListener(() { });

    super.initState();

  }
  @override
  void dispose(){
    super.dispose();
    ageController.dispose();
    appealController.dispose();


  }

  _prepareService() async{
    _user= _firebaseAuth.currentUser;

    _userName=await HelperFunctions.getUserNameSharedPreference();

    await DatabaseService(userName: _userName).getUserAppeal().then((value){
      setState(() {
        appealController.text = value;
      });
    });
    /*
    await DatabaseService(userName: _userName).getUserLocal().then((value){
      setState(() {
        localController.text = value;
      });
    });
    */
    /*
    await DatabaseService(userName: _userName).getUserHashTag().then((value){
      setState(() {
        hashTagController.text = value;
      });
    });

     */
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

    Reference _storageReference = _firebaseStorage.ref('user_image/$_userName/$_userName[$number]');
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
    Reference storageReference = _firebaseStorage.ref('user_image/$_userName/$_userName[$number]');

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
        _showToastAfterUpload();

      });

    }

    // 업로드된 사진의 URL을 페이지에 반영

  }
  _showToastAfterSave() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xdd48d1cc),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("저장되었습니다"),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
  _showToastAfterUpload() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xdd48d1cc),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("정상적으로 업로드되었습니다"),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
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

    /*serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }*/

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
      backgroundColor: Color(0xdd212121),
      content: Container(


          width: 250,
          height: 150,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [

            TextButton(
                onPressed: () {
                   _uploadImageToStorage(ImageSource.gallery, number);
                   Navigator.of(context).pop();

                },
                child: Text("업로드",style: TextStyle(color:Colors.white,fontSize:17))),
            Expanded(child:Divider(color:Colors.white)),
            TextButton(
                onPressed: () {
                  _deleteImageFromStorage(number);
                  Navigator.of(context).pop();
                },

                child: Text("삭제하기",style: TextStyle(color:Colors.red,fontSize:17))),
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
      backgroundColor: Color(0xff212121),
        body: GestureDetector(
          onTap:(){
          },
            child:ListView(

          children: <Widget>[

                Container(
                  padding: EdgeInsets.all(10),
                    child:Row(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  GestureDetector(
                      onTap: (){

                        _popupEdit(context,0);
                      },
                      child: Container(
                        height: 120,
                        width: 100,
                        child: Align(alignment: Alignment(1.5, 1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
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
                        height: 120,
                        width: 100,
                        child: Align(alignment: Alignment(1.5,1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
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
                        height: 120,
                        width: 100,
                        child: Align(alignment: Alignment(1.5,1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: _hasNetworkImage[2]? NetworkImage(_profileImageURL[2]):AssetImage("images/default.png")

                          ),
                        ),
                      )),
                ])),
            Container(
                padding : EdgeInsets.all(10),
                child:Row(

                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){

                            _popupEdit(context,0);
                          },
                          child: Container(
                            height: 120,
                            width: 100,
                            child: Align(alignment: Alignment(1.5, 1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: _hasNetworkImage[3]? NetworkImage(_profileImageURL[3]):AssetImage("images/default.png")

                              ),
                            ),
                          )),
                      GestureDetector(
                          onTap: (){

                            _popupEdit(context,1);
                          },
                          child: Container(
                            height: 120,
                            width: 100,
                            child: Align(alignment: Alignment(1.5,1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: _hasNetworkImage[4]? NetworkImage(_profileImageURL[4]):AssetImage("images/default.png")

                              ),
                            ),
                          )),
                      GestureDetector(
                          onTap: (){

                            _popupEdit(context,2);
                          },
                          child: Container(
                            height: 120,
                            width: 100,
                            child: Align(alignment: Alignment(1.5,1.5),child:IconButton(icon: Icon(Icons.arrow_circle_up_rounded, color: Color(0xff9932cc)))),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: _hasNetworkImage[5]? NetworkImage(_profileImageURL[5]):AssetImage("images/default.png")

                              ),
                            ),
                          )),
                    ])),
            SizedBox(height: 23.0),
            TextField(

                maxLines: null,
                controller: appealController,
                style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 10.0),
                    border: OutlineInputBorder(),
                    labelText: "자기소개"

                )
            ),
            SizedBox(height:15),
            TextField(

                controller: ageController,
                maxLines: 1,
                style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(),
                  labelText: '나이',
                )
            ),
            SizedBox(height:30),

            Row(children: [
              Text("나이 표시",style:TextStyle(color: Colors.white)),
              Switch(
                  activeColor: Color(0xff9932cc),
                  value: ageSwitched,
                  onChanged: (value) {
                    setState(() {
                      ageSwitched = value;

                    }
                    );
                  }
              )
            ]),
            Row(children: [
              Text("거리 표시", style: TextStyle(color: Colors.white)),
              Switch(

                  activeColor: Color(0xff9932cc),
                  value: distanceSwitched,
                  onChanged: (switched){
                    setState(() {
                      distanceSwitched = switched;
                      print(distanceSwitched);
                    }
                    );
                    if(distanceSwitched){
                      _determinePosition().then((value){
                        DatabaseService(userName: _userName).setLocationFromGPS(value.latitude, value.longitude);

                      });
                    }else if(distanceSwitched == false){

                      //DatabaseService(userName: _userName).deleteLocationFromGPS();


                    }
                  }
              )
            ]),


            GestureDetector(
                onTap: ()async{
                  await _showToastAfterSave();
              DatabaseService(userName: _userName).updateAppeal(appealController.text);
              DatabaseService(userName: _userName).updateAge(ageController.text);

            }, child: Container(

                width: 150,
                height : 40,
                decoration: BoxDecoration(
                  //border : Border.all(color: Colors.white, width:0),
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0)
                  ),
                  color: Color(0xff9932cc),
                ),
                child: Center(child:Text("저장하기",style: TextStyle(color:Colors.white,fontWeight: FontWeight.w900)))
            )
            ),
            SizedBox(height:10),

            GestureDetector(
              onTap: () async {

                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.clear();
                await _auth.signOut();

                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignInPage()), (Route<dynamic> route) => false);

              },
              child: Container(
                    width: 150,
                    height : 40,
                    decoration: BoxDecoration(
                    //border : Border.all(color: Colors.white, width:0),
                    borderRadius: BorderRadius.all(
                    Radius.circular(5.0)
                    ),
                    color: Colors.white),
                    child:Center(child:Text('로그아웃', style: TextStyle(color: Color(0xff9932cc),fontWeight: FontWeight.w900))),

              )
            )
          ],
        )
        )
    );
  }
}


