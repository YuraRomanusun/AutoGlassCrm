import 'dart:async';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class SettingsView extends StatefulWidget {
  _SettingsViewState state;
  @override
  _SettingsViewState createState() {
    state = new _SettingsViewState();
    return state;
  }
}

class _SettingsViewState extends State<SettingsView> {
  var unescape = new HtmlUnescape();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isNotificationEnabled = true;

  bool isSettingNotification = false;
  @override
  void initState() {
    super.initState();
    if ( Global.notificationStatus == "1" ){
      isNotificationEnabled = true;
    }
    else{
      isNotificationEnabled = false;
    }
  }

  setNotification(context, _enabled) async{
    isSettingNotification = true;
    var snackBarLoading = SnackBar(
      duration: Duration(seconds: 60),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Loading...")
        ],
      ),
    );

    Scaffold.of(context).showSnackBar(snackBarLoading);
    var ret = "0";
    if ( _enabled ) {
      ret = await PushNotificationService.sendPushToken(Global.pushNotificationToken);
    }
    else{
      ret = await PushNotificationService.sendPushToken("");
    }
    Scaffold.of(context).hideCurrentSnackBar();

    if ( ret == "1" ){
      isNotificationEnabled = _enabled;
      if ( _enabled )
        Global.notificationStatus = "1";
      else
        Global.notificationStatus = "0";
      Global.saveSettings();
    }
    else{
      final snackBar = SnackBar(
        content: Text(
          'Something went wrong. Please try again.',
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);

      isNotificationEnabled = !_enabled;
    }
    isSettingNotification = false;
    setState(() {
    });
  }

  
  @override
  Widget build(BuildContext context) {
    const Color rowBgColor = Colors.black26;

    FutureBuilder fbBody = new FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return ListView(children: [
            SizedBox(height:10),
            Container(
              color: rowBgColor,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child:Row(
                  children: <Widget>[
                    Expanded(
                      child: Text("Notification",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)
                      )
                    ),
                    Switch(
                      value: isNotificationEnabled,
                      onChanged: (value) {
                        if ( isSettingNotification ){
                          return;
                        }

                        setState(() {
                          isNotificationEnabled = value;
                        });
                        setNotification(context, value);
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ],
                )
              )
            ),
            SizedBox(
              height: 10,
            ),

            Container(
                color: rowBgColor,
                child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child:Row(
                      children: <Widget>[
                        Expanded(
                            child: Text("Log out",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)
                            )
                        ),
                        IconButton(
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                          onPressed: (){
                            Global.asyncLgoutDialog(context);
                          },
                        )
                      ],
                    )
                )
            ),
          ]);
    });

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: const BackButton(),
          iconTheme: IconThemeData(
            color: Colors.black87, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text("Settings", style: TextStyle(color: Colors.black87)),
          brightness: Brightness.light,
          centerTitle: true,
      ),
      body: fbBody
    );
  }
}
