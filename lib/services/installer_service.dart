import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/installer_list_item.dart';
import 'package:auto_glass_crm/models/installer_overview_item.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;

class InstallerService {
  static Future<dynamic> getInstallerList(String pnum, String psize, String s) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/installer/applist";
    url += "?pnum=" + pnum;
    if ( psize.length > 0 ){
      url += "&psize=" + psize;
    }
    if ( s.length > 0 ){
      url += "&s=" + s;
    }

    print(url);
    try {
      var response = await Global.theHttpClient().getAs(url);
      if (response == null) return null;
      print(response);

      return response;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }

  /*
  Create or Edit Installer
   */
  static Future<Response> createOrEditInstaller(FormData fd) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/installer/appsave";
    print(url);
    try {
      var client = Global.theDioClient();
      Response response = await client.post(url, data: fd);
      return response;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }


  static Future<dynamic> getInstallerDetails(String installerId) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/installer/appview/$installerId";
    print(url);

    try {
      var result = await Global.theHttpClient().getAs(url);
      print(result);
      return result;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }
}
