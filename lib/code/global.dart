
import 'package:servicestack/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:auto_glass_crm/views/account_warning_page.dart';

enum ConfirmAction { CANCEL, OK }

class StateItem{
  String twoLetter;
  String fullLetter;

  StateItem(String a, String b){
    this.twoLetter = a;
    this.fullLetter = b;
  }
}

class Global {
  //static String baseUrl = "https://rightautoglass.autoglasscrm.com/";
  //static String baseUrl = "https://demo.autoglasscrm.com/";

  static String domainFirst = "https://";
  static String domainSurfix = ".autoglasscrm.com";
  static String versionString = "1.0";

  static String userToken = "";
  static String userAccess = "";
  static String userID = "";
  static String userFirstName = "";
  static String userLastName = "";
  static String vindecoderAuth = "";
  static String vindecoderOnly = "";
  static String currentUserName = "";
  static String currentPassword = "";
  static bool   isRemeberMe = false;
  static String notificationStatus = "";
  static String pushNotificationToken = "";

  static String domainPrefix = "";
  static String vinderPrefix = "vindecoder";


  /* font sizes */
  static double fontSizeNormal = 18.0;
  static double fontSizeSmall = 16.0;
  static double fontSizeTiny = 13.0;

  /* ---font sizes --- */
  static List<StateItem> stateList = [
    new StateItem("", "Select a state..."),
    new StateItem("AL", "Alabama"),
    new StateItem("AK", "Alaska"),
    new StateItem("AZ", "Arizona"),
    new StateItem("AR", "Arkansas"),
    new StateItem("CA", "California"),
    new StateItem("CO", "Colorado"),
    new StateItem("CT", "Connecticut"),
    new StateItem("DE", "Delaware"),
    new StateItem("DC", "District Of Columbia"),
    new StateItem("FL", "Florida"),
    new StateItem("GA", "Georgia"),
    new StateItem("HI", "Hawaii"),
    new StateItem("ID", "Idaho"),
    new StateItem("IL", "Illinois"),
    new StateItem("IN", "Indiana"),
    new StateItem("IA", "Iowa"),
    new StateItem("KS", "Kansas"),
    new StateItem("KY", "Kentucky"),
    new StateItem("LA", "Louisiana"),
    new StateItem("ME", "Maine"),
    new StateItem("MD", "Maryland"),
    new StateItem("MA", "Massachusetts"),
    new StateItem("MI", "Michigan"),
    new StateItem("MN", "Minnesota"),
    new StateItem("MS", "Mississippi"),
    new StateItem("MO", "Missouri"),
    new StateItem("MT", "Montana"),
    new StateItem("NE", "Nebraska"),
    new StateItem("NV", "Nevada"),
    new StateItem("NH", "New Hampshire"),
    new StateItem("NJ", "New Jersey"),
    new StateItem("NM", "New Mexico"),
    new StateItem("NY", "New York"),
    new StateItem("NC", "North Carolina"),
    new StateItem("ND", "North Dakota"),
    new StateItem("OH", "Ohio"),
    new StateItem("OK", "Oklahoma"),
    new StateItem("OR", "Oregon"),
    new StateItem("PA", "Pennsylvania"),
    new StateItem("RI", "Rhode Island"),
    new StateItem("SC", "South Carolina"),
    new StateItem("SD", "South Dakota"),
    new StateItem("TN", "Tennessee"),
    new StateItem("TX", "Texas"),
    new StateItem("UT", "Utah"),
    new StateItem("VT", "Vermont"),
    new StateItem("VA", "Virginia"),
    new StateItem("WA", "Washington"),
    new StateItem("WV", "West Virginia"),
    new StateItem("WI", "Wisconsin"),
    new StateItem("WY", "Wyoming"),
  ];

  static JsonServiceClient jsonClient;
  static JsonServiceClient theHttpClient() {
    Global.jsonClient = JsonServiceClient();

    if (Global.userToken.isNotEmpty) {
      Map<String, String> h = { "Authorization" : Global.userToken, "Access" : Global.userAccess };
      Global.jsonClient.headers.addAll(h);
    }
    
    return Global.jsonClient;
  }

  static setAuthorizationToJsonServiceClient(client, auth){
    Map<String, String> h = { "Authorization" : auth };
    client.headers.clear();
    client.headers.addAll(h);
  }

  static Dio dioClient;
  static Dio theDioClient() {
    //if ( Global.dioClient == null )
    {
      Global.dioClient = new Dio();

      Global.dioClient.interceptors.add(InterceptorsWrapper(
          onRequest:(Options options) async {
            // If no token, request token firstly and lock this interceptor
            // to prevent other request enter this interceptor.
            Global.dioClient.interceptors.requestLock.lock();
            //Set the token to headers
            options.headers["Authorization"] = Global.userToken;
            options.headers["Access"] = Global.userAccess;
            Global.dioClient.interceptors.requestLock.unlock();

            return options; //continue
          }
      ));
    }

    return Global.dioClient;
  }

  static void saveSettings() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.setString("CurrentUser", Global.currentUserName);
    prefs.setString("CurrentPassword", Global.currentPassword);
    prefs.setString("UserID", Global.userID);
    prefs.setString("UserFirstName", Global.userFirstName);
    prefs.setString("UserLastName", Global.userLastName);
    prefs.setString("UserToken", Global.userToken);
    prefs.setString("UserAccess", Global.userAccess);
    prefs.setString("domainPrefix", Global.domainPrefix);
    prefs.setString("vindecoderAuth", Global.vindecoderAuth);
    prefs.setString("vindecoderOnly", Global.vindecoderOnly);
    prefs.setBool("rememberMe", isRemeberMe);
    prefs.setString("notificationstatus", Global.notificationStatus);
  }

  static Future<Null> loadSettings() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    Global.currentUserName = prefs.getString("CurrentUser") ?? "";
    Global.currentPassword = prefs.getString("CurrentPassword") ?? "";
    Global.userID = prefs.getString("UserID") ?? "";
    Global.userFirstName = prefs.getString("UserFirstName") ?? "";
    Global.userLastName = prefs.getString("UserLastName") ?? "";
    Global.userToken = prefs.getString("UserToken") ?? "";
    Global.userAccess = prefs.getString("UserAccess") ?? "";
    Global.domainPrefix = prefs.getString("domainPrefix") ?? "";
    Global.isRemeberMe = prefs.getBool("rememberMe") ?? false;
    Global.vindecoderAuth = prefs.getString("vindecoderAuth") ?? "";
    Global.vindecoderOnly = prefs.getString("vindecoderOnly") ?? "";
    Global.notificationStatus = prefs.getString("notificationstatus") ?? "";
  }

  static void resetSettings() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.setString("CurrentUser", "");
    prefs.setString("CurrentPassword", "");
    prefs.setString("UserID", "");
    prefs.setString("UserFirstName", "");
    prefs.setString("UserLastName", "");
    prefs.setString("UserToken", "");
    prefs.setString("UserAccess", "");
    prefs.setString("vindecoderAuth", "");
    prefs.setString("vindecoderOnly", "");
    prefs.setString("notificationstatus", "");

    Global.currentUserName = "";
    Global.currentPassword = "";
    Global.userID = "";
    Global.userFirstName = "";
    Global.userLastName = "";
    Global.userToken = "";
    Global.userAccess = "";
    Global.vindecoderAuth = "";
    Global.vindecoderOnly = "";
    Global.notificationStatus = "";

    if ( Global.isRemeberMe == false ){
      prefs.setString("domainPrefix", "");
      Global.domainPrefix = "";
    }
  }

  static Future<ConfirmAction> asyncAlertDialog(BuildContext context, String bodyText) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(bodyText),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<ConfirmAction> asyncLgoutDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Global.resetSettings();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            )
          ],
        );
      },
    );
  }

  static bool isAccouontWarningPageOn = false;
  static checkResponse(BuildContext context, String message){
    if ( message.toUpperCase() == "LOCKED" ) {
      if ( isAccouontWarningPageOn == false ) {
        isAccouontWarningPageOn = true;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                AccountWarningPage()
        ));
      }
    }
  }

  static bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
