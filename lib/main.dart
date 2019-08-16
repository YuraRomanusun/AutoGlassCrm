import 'dart:async';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/views/home_page.dart';
import 'package:auto_glass_crm/views/job_list_view.dart';
import 'package:auto_glass_crm/views/job_overview_view.dart';
import 'package:auto_glass_crm/views/login_view.dart';
import 'package:auto_glass_crm/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
// import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';

void main() async {
  await Global.loadSettings();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoGlassCRM',
      theme: ThemeData(
          canvasColor: Color(0xFFFFFFFF),
          primarySwatch: Colors.blue,
          fontFamily: 'Montserrat'),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          if (Global.userToken.isNotEmpty) {
            return HomePage();
          } else {
            return LoginView();
          }
        }
      },
    );
  }
}
