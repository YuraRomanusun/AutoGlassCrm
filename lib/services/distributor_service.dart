import 'dart:convert';
import 'dart:io';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/distributor_list_item.dart';
import 'package:auto_glass_crm/models/distributor_overview_item.dart';
import 'dart:async';
import 'package:servicestack/client.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class DistributorService {
  static Future<dynamic> getDistributorList(String pnum, String psize, String s) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/distributor/applist";
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
  Create or Edit Distributor
   */
  static Future<Response> createOrEditDistributor(FormData fd) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/distributor/appsave";
    try {
      var client = Global.theDioClient();
      Response response = await client.post(url, data: fd);
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


  static Future<Map<String, dynamic>> getDistributorDetails(String distributorId) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/distributor/appview/$distributorId";
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
