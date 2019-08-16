import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/vindecoder.dart';
import 'package:auto_glass_crm/models/vindecoder_history.dart';
import 'dart:async';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;

class VindecoderService {
  static Future<dynamic> getVindecoder(String s) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/vindecoder/appsearch?s=${Uri.encodeComponent(s)}";
    print(url);
    try {
      var client = Global.theHttpClient();
      Global.setAuthorizationToJsonServiceClient(client, Global.userToken);
      var response = await client.getAs(url);
      print(response);
      return response;
    } on WebServiceException catch (e) {
      print("error1=" + e.message.toString());
      return "error";
    } catch (e) {
      print("error2=" + e.toString());
      return "error";
    }
  }


  static Future<dynamic> getVindecoderHistory(String s, int pnum, int psize) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/vindecoder/apphistory?s=${Uri.encodeComponent(s)}&pnum=" + pnum.toString() + "&psize=" + psize.toString();
    print(url);
    try {
      var client = Global.theHttpClient();
      Global.setAuthorizationToJsonServiceClient(client, Global.userToken);
      var response = await client.getAs(url);
      print(response);

      return response;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String> sendHelpRequest(String user, String search, String searchid, String glass) async {
    var url = Global.domainFirst + Global.vinderPrefix + Global.domainSurfix + "/api/requesthelp";
    print(url);
    try {
      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {"Authorization": Global.vindecoderAuth};
      request.headers.addAll(h);

      Map<String, String> params = {};
      params['user'] = user;
      params['search'] = search;
      if ( searchid == null ){
        params['searchid'] = "0";
      }else {
        params['searchid'] = searchid;
      }
      params['glass'] = glass;

      request.fields.addAll(params);
      print(params);

      var response = await request.send().then((response) async {
        String responseData = await response.stream.transform(utf8.decoder).join(); // decodes on response data using UTF8.decoder
        return responseData;
      });
      print(response);
      return response;
    } on WebServiceException catch (e) {
      print("sendHelpRequest error1=" + e.message.toString());
      return null;
    } catch (e) {
      print("sendHelpRequest error2=" + e.toString());
      return null;
    }
  }

  static Future<VindecoderAnswer> getVindecoderAnswer(String id) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/vindecoder/appanswer/" + id;
    print(url);
    try {
      var client = Global.theHttpClient();
      Global.setAuthorizationToJsonServiceClient(client, Global.userToken);
      var response = await client.getAs(url);
      print(response);
      if (response == null ) return null;
      var result = VindecoderAnswer.fromJson(response);
      return result;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
