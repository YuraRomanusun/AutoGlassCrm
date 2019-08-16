import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/customer_overview_item.dart';
import 'package:auto_glass_crm/models/job_count_item.dart';
import 'package:auto_glass_crm/models/job_overview.dart';
import 'dart:async';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';


class CustomerService {
  static Future<Map<String, dynamic>> getCustomerDetails(String customerId) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/customer/single/$customerId";
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

  /*
  Create or Edit Installer
   */
  static Future<Response> createOrEditCustomer(FormData fd) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/customer/appsave";
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
