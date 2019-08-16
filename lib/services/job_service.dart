import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/job_list_item.dart';
import 'package:auto_glass_crm/models/job_count_item.dart';
import 'package:auto_glass_crm/models/job_overview.dart';
import 'dart:async';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';


class JobService {
  static Future<Map<String, dynamic>> getJobList(String range, String key) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/job/applist";
    if ( range.length > 0 ){
      url += "?range=" + range + "&psize=100";
      if ( key.length > 0 ){
        url += "&s=" + key;
      }
    }
    else if ( key.length > 0 ){
      url += "?s=" + key;
    }
    print(url);
    try {
      var response = await Global.theHttpClient().getAs(url);
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

  static Future<JobOverview> getJobDetails(String jobId) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/job/single/$jobId";
    print(url);
    try {
      var result = await Global.theHttpClient().getAs(url);
      print(result);
      var resp = JobOverview.fromJson(result);

      return resp;
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
  static Future<Response> createOrEditJob(FormData fd) async{
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/job/appsavenew";
    print(url);
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

  static Future<dynamic> searchCustomers(String firstName, String lastName, String phone, String zip) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/customer/appsearch";
    print(url);
    try {
      /*
      FormData fd = new FormData.from({

        "first_name": firstName,
        "last_name": lastName,
        "phone": phone

      });
      if ( zip.length > 0 ){
        fd.add("zip", zip);
      }


      var res = await Global.theHttpClient().getAs(url);
      print(res);
      */

      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {"Authorization": Global.userToken};
      request.headers.addAll(h);

      Map<String, String> params = {};
      if ( firstName.length > 0 )
        params['first_name'] = firstName;

      if ( lastName.length > 0 )
        params['last_name'] = lastName;

      if ( phone.length > 0 )
        params['phone'] = phone;

      if ( zip.length > 0 )
        params['zip'] = zip;

      request.fields.addAll(params);

      var response = await request.send().then((response) async {
        String responseData = await response.stream.transform(utf8.decoder).join(); // decodes on response data using UTF8.decoder
        return responseData;
      });
      print(response);
      var result = json.decode(response);
      return result;
      /*
      var client = Global.theDioClient();
      Response response = await client.post(url, data: fd);
      print("5555");

      if ( response.statusCode == 200 ) {
        var result = json.decode(response.data);
        return result;
      }else{
        return response.toString();
      }
      */
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }

  static Future<dynamic> searchVehicles(String cid) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/customer/appgetvehicles";
    if ( cid.length > 0 ){
      url += "?cid=" + cid;
    }
    print(url);
    try {
      var client = Global.theDioClient();
      Response response = await client.post(url);

      if ( response.statusCode == 200 ) {
        print(response);
        var result = json.decode(response.data);
        return result;
      }else{
        return null;
      }
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }

  static Future<dynamic> searchSalesPerson(String key) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/salesperson/appsearch";
    if ( key.length > 0 ){
      url += "?s=" + key;
    }
    print(url);
    try {
      var response = await Global.theHttpClient().getAs(url);
      print(response);
      return response;
    } on WebServiceException catch (e) {
      print("WebServiceException:" + e.message.toString());
      return null;
    } catch (e) {
      print("Error:" + e.message.toString());
      return null;
    }
  }






  static Future<bool> removePhoto(int fileId) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/file/appdelete/$fileId";

    try {
      await Global.theHttpClient().postAs(url, {});

      return true;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return false;
    } catch (e) {
      print(e.message.toString());
      return false;
    }
  }

  static Future<int> uploadPhoto(List<int> photoBytes, String jobId, String filename) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/file/appsave/$jobId";
    
    try {
      var uri = Uri.parse(url);

      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {"Authorization": Global.userToken};
      request.headers.addAll(h);

      var multipartFile = new http.MultipartFile.fromBytes('file-upload', photoBytes, filename: '$filename.jpg');

      request.files.add(multipartFile);

      var response = await request.send().then((response) async {
        String responseData = await response.stream.transform(utf8.decoder).join(); // decodes on response data using UTF8.decoder
        return responseData;
      });

      var photoId = int.tryParse(response) ?? 0;
      return photoId;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return 0;
    } catch (e) {
      print(e.message.toString());
      return 0;
    }
  }

  static Future<dynamic> saveJobDetails(List<int> photoBytes, String jobId, {String notes}) async {
    var url = Global.domainFirst + Global.domainPrefix + Global.domainSurfix + "/job/appsave/$jobId";

    try {
      var uri = Uri.parse(url);

      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {"Authorization": Global.userToken};
      request.headers.addAll(h);
      
      var multipartFile = new http.MultipartFile.fromBytes('file-upload', photoBytes, filename: 'signature.png');

      request.files.add(multipartFile);
      if (notes.isNotEmpty) {
        request.fields.addAll({'note': notes});
      }
      

      var response = await request.send();

      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });

      return true;
    } on WebServiceException catch (e) {
      print(e.message.toString());
      return false;
    } catch (e) {
      print(e.message.toString());
      return false;
    }
  }
}
