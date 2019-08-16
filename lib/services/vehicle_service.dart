import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/customer_overview_item.dart';
import 'package:auto_glass_crm/models/job_count_item.dart';
import 'package:auto_glass_crm/models/job_overview.dart';
import 'dart:async';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';


class VehicleService {
  /*
  Create or Edit Vehicle
   */
  static Future<Response> createOrEditVehicle(FormData fd) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/vehicle/appsave";
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
}
