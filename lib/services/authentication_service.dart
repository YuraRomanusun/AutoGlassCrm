import 'package:auto_glass_crm/models/authentication_response.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:auto_glass_crm/code/global.dart';
import 'package:servicestack/client.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  static Future<AuthenticationResponse> authenticate(String domainPrefix, String email, String password) async {
    var url = Global.domainFirst + domainPrefix + Global.domainSurfix + "/login/appauth?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}";
    print(url);
    try {
      var auth = await Global.theHttpClient().getAs(url);
      print(auth);
      var resp = AuthenticationResponse.fromJson(auth);

      return resp;
    } on WebServiceException catch (e) {
      print("authenticate error1=" + e.message.toString());
      return null;
    } catch (e) {
      print("authenticate error2=" +  e.message.toString());
      return null;
    }
  }

  static Future<PasswordResetResponse> resetPassword(String domain, String email) async {
    var url = Global.domainFirst + domain + Global.domainSurfix + "/login/appemailreset";
    print(url);

    try {
      FormData fd = new FormData.from({
          "email": email
      });

      var client = Global.theDioClient();
      Response response = await client.post(url, data: fd);
      print(response);

      PasswordResetResponse resp = new PasswordResetResponse();
      resp.success = response.data["success"];
      resp.message = response.data["message"];
      return resp;

    } on WebServiceException catch (e) {
      print(e.message.toString());
      return null;
    } catch (e) {
      print(e.message.toString());
      return null;
    }
  }


  static Future<String> checkURLPrefix(String domain) async {
    var url = Global.domainFirst + "admin" + Global.domainSurfix + "/account/checkprefix/" + domain;
    print(url);
    try {
      FormData fd = new FormData.from({
      });

      var client = Global.theDioClient();
      Response response = await client.post(url, data: fd);
      var ret = response.data;

      print(ret);
      return ret.toString();
    } on WebServiceException catch (e) {
      print("checkURLPrefix error1=" + e.message.toString());
      return null;
    } catch (e) {
      print("checkURLPrefix error2=" +  e.message.toString());
      return null;
    }
  }


  static Future<dynamic> createAccount(String domain, String contactName, String firstName, String lastName, String phone, String email, String password) async {
    var url = Global.domainFirst + "admin" + Global.domainSurfix + "/account/create";
    print(url);
    try {
      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> h = {
        "APP_AUTH_ID": "app-VDCRM-2019",
        "APP_AUTH_KEY": "n>aP=:k}Vm*GT--9zVB@\$3EQ|+Ayu<Y^r-_jf-zLjg?w*)y:t6zm&@Wh&6"
      };
      request.headers.addAll(h);

      Map<String, String> params = {};
      params['COMPANY_PREFIX'] = domain;
      params['CONTACT_NAME'] = contactName;
      params['first_name'] = firstName;
      params['last_name'] = lastName;
      params['email'] = email;
      params['phone'] = phone;
      params['password'] = password;
      request.fields.addAll(params);

      var response = await request.send().then((response) async {
        String responseData = await response.stream.transform(utf8.decoder).join(); // decodes on response data using UTF8.decoder
        return responseData;
      });

      if ( response == null ){
        return null;
      }
      var result = json.decode(response);
      return result;
    } on WebServiceException catch (e) {
      print("createAccount error1=" + e.message.toString());
      return null;
    } catch (e) {
      print("createAccount error2=" +  e.message.toString());
      return null;
    }
  }



}
