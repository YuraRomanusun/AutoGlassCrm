import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/services/authentication_service.dart';
import 'package:flutter/material.dart';

class PasswordResetView extends StatefulWidget {

  PasswordResetView();

  @override
  _PasswordResetViewState createState() => new _PasswordResetViewState();
}

class _PasswordResetViewState extends State<PasswordResetView> {
  BuildContext _scaffoldContext;
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _domainController = new TextEditingController(text: "");
  final FocusNode myFocusNode = FocusNode();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isWorking = false;

  void getResetPasswordLink() async {
    var response = await AuthenticationService.resetPassword(_domainController.text, _emailController.text);

    isWorking = false;
    setState(() {});

    if (response != null && response.success == 1 ) {
      Global.asyncAlertDialog(context, response.message);
    } else {
      var errorText = "An error occurred.";
      if ( response != null && response.message != null ){
        errorText += " " + response.message;
      }
      final snackBar = SnackBar(
        content: Text(errorText),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      Global.checkResponse(context, response.message);
    }
  }

  _loadingWidget() {
    return SizedBox(
      height: 25.0,
      width: 25.0,
      child: new CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEFEFEF)),
        value: null,
        strokeWidth: 7.0,
      ),
    );
  }

  _signinTextWidget() {
    return Text(
      "Get Link",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF1E3C6B),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3C6B),
        title: Image.asset("assets/logo_sm.png"),
        brightness: Brightness.light,
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return GestureDetector(
          onTap: () => FocusScope.of(context)
              .requestFocus(new FocusNode()), // hide keyboard
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    "Password Reset",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 0.0, bottom: 10.0, left: 25),
                  margin: const EdgeInsets.only(top: 20.0),
                ),
                SizedBox(height: 24.0),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 20.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 29, top: 10, bottom: 10),
                      child: Text(
                        "Domain",
                        style: TextStyle(
                          color: Color(0xFFA4C6EB),
                          fontSize: 20,
                        ),
                      ),
                    )
                ),

                Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0),
                    ),
                    margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:35.0, right: 10.0),
                    child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                child: TextField(
                                  autocorrect: false,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  keyboardType: TextInputType.text,
                                  controller: _domainController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter prefix',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  onSubmitted: (newValue) {
                                    FocusScope.of(context).requestFocus(myFocusNode);
                                  },
                                ),
                              )
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(".autoglasscrm.com", style: TextStyle(color: Colors.white, fontSize: 18),)
                          ),

                        ]
                    )
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 24.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 15, right: 53, top: 10, bottom: 10),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            color: Color(0xFFA4C6EB),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          autocorrect: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onSubmitted: (newValue) {
                            FocusScope.of(context).requestFocus(myFocusNode);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                            color: Color(0xFF027BFF),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: isWorking
                                  ? _loadingWidget()
                                  : _signinTextWidget(),
                            ),
                            onPressed: () {
                              if (isWorking) {
                                return null;
                              } else {
                                isWorking = true;
                                setState(() {});
                                getResetPasswordLink();
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
