import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/installer_list_item.dart';
import 'package:auto_glass_crm/models/installer_overview_item.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
//import 'package:package_info/package_info.dart';

class PushNotificationService {
  /*
  Save Push Subscription
   */
  static Future<String> savePushSubscription(String client, String token) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/user/appaddpushsub";
    print(url);

    try {

      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {"Authorization": Global.userToken};
      request.headers.addAll(h);

      Map<String, String> params = {};
      params['client'] = client;

      if ( token != "" ) {
        Map<String, String> sub = {};
        sub['token'] = token;
        params['sub'] = sub.toString();
      }
      else{
        params['sub'] = "";
      }

      request.fields.addAll(params);

      var response = await request.send().then((response) async {
        String responseData = await response.stream.transform(utf8.decoder).join(); // decodes on response data using UTF8.decoder
        return responseData;
      });
      print(response);

      var result = json.decode(response);
      if ( result["success"] == 1 ){
        return "1";
      }
      else{
        return "0";
      }
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return "0";
    } catch (e) {
      print(e.message.toString());
      return "0";
    }
  }

  static Future<String> sendPushToken(String token) async {
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var client = "android";
    if ( Platform.isAndroid ) {
      client = "android";
    }
    else{
      client = "ios";
    }
    var response = PushNotificationService.savePushSubscription(client, token);
    return response;
  }
}
