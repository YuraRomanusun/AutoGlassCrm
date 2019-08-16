import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:auto_glass_crm/code/global.dart';

class AccountWarningPage extends StatefulWidget {
  AccountWarningPage();

  @override
  _AccountWarningPageState createState() => new _AccountWarningPageState();
}

class _AccountWarningPageState extends State<AccountWarningPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TapGestureRecognizer _recognizer1;
  final String urlReactivate =  Global.domainFirst + Global.domainPrefix + ".autoglasscrm.com/account";

  @override
  void initState() {
    super.initState();

    _recognizer1 = TapGestureRecognizer()
      ..onTap = () {
        _launchURL();
      };
  }

  @override
  dispose() {
    super.dispose();
    Global.isAccouontWarningPageOn = false;
  }

  _launchURL() async {
    print(urlReactivate);

    if (await canLaunch(urlReactivate)) {
      await launch(urlReactivate);
    } else {
      throw 'Could not launch $urlReactivate';
    }
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder fbBody = new FutureBuilder<bool>(
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return ListView(children: [
          SizedBox(height: 25.0),
          Padding(
            padding: EdgeInsets.only(left:10, right:10, top:10, bottom:5),
            child: Text("Your account has been temporarily locked, most likely because of a repeated billing failure.",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0)
            )
          ),
          SizedBox(height: 5.0),

          Padding(
            padding: EdgeInsets.only(left:10, right:10, top:0, bottom:0),
            child: RichText(
              text: new TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: new TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                children: [
                  new TextSpan(text: 'Please visit '),
                  new TextSpan(
                      text: urlReactivate,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Color(0xFFA4C6EB),
                      ),
                      recognizer: _recognizer1
                  ),
                  new TextSpan(text: ' to reactivate.'),
                ],
              ),
            ),
          )

          /*
          Padding(
            padding: EdgeInsets.only(left:10, right:10, top:10, bottom:5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Please visit ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                new GestureDetector(
                  onTap: (){
                    print("account");
                    /*
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => SignupView()
                      )
                  );
                  */
                  },
                  child: Text(
                    Global.domainPrefix + ".autoglasscrm.com/account",
                    style: TextStyle(
                      color: Color(0xFFA4C6EB),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                Text(
                  " to reactivate.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ]
            )
          )
*/


        ]);
      }
    );
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        backgroundColor: Colors.white,
        title: Text("Account Warning", style: TextStyle(color: Colors.black),),
        brightness: Brightness.light,
        centerTitle: true,
      ),
      body: fbBody
    );
  }
}