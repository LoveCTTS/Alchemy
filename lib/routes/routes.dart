import 'package:flutter/material.dart';
import 'package:linkproto/pages/authenticate_page.dart';
import '../main.dart';
import '../pages/chat_page.dart';
import '../pages/agora_page.dart';
import '../pages/group_page.dart';
import '../pages/home_page.dart';

final routes = {


  '/home' : (BuildContext context) => HomePage(),
  '/auth': (BuildContext context) => AuthenticatePage(),
  '/agora': (BuildContext context) => AgoraPage(),
  '/group': (BuildContext context) => GroupPage(),

};