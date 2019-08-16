import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/services/authentication_service.dart';
import 'package:auto_glass_crm/views/home_page.dart';
import 'package:auto_glass_crm/views/password_reset.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:validators/sanitizers.dart';

class SignupView extends StatefulWidget {

  SignupView();

  @override
  _SignupViewState createState() => new _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  BuildContext _scaffoldContext;
  TextEditingController _businessNameController = new TextEditingController(text: "");
  TextEditingController _firstNameController = new TextEditingController(text: "");
  TextEditingController _lastNameController = new TextEditingController(text: "");
  TextEditingController _phoneController = new TextEditingController(text: "");
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _pwController = new TextEditingController(text: "");
  TextEditingController _domainController = new TextEditingController(text: "");

  final FocusNode domainFocusNode = FocusNode();
  final FocusNode businessNameFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSigning = false;

  @override
  void initState() {
    super.initState();
    _domainController.text = Global.domainPrefix;
  }

  /* Create an account */
  void doSignUp() async {
    var domain = _domainController.text.trim();
    var businessName = _businessNameController.text.trim();
    var firstName = _firstNameController.text.trim();
    var lastName = _lastNameController.text.trim();
    var phone = _phoneController.text.trim();
    var email = _emailController.text.trim();
    var password = _pwController.text.trim();

    if ( domain.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type domain.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(domainFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( domain.length < 5 || domain.length > 25  || isAlpha(domain) == false ){
      final snackBar = SnackBar(
        content: Text(
          'Prefix must be 5-24 letters, with no spaces or special characters.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(domainFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( businessName.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type business name.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(businessNameFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( firstName.length == 0 )
    {
      final snackBar = SnackBar(
        content: Text(
          'Please type first name.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(firstNameFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( lastName.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type last name.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(lastNameFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( phone.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type phone.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(phoneFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( email.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type email.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(emailFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }

    if ( password.length == 0 ){
      final snackBar = SnackBar(
        content: Text(
          'Please type password.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      FocusScope.of(context).requestFocus(passwordFocusNode);
      isSigning = false;
      setState(() {});

      return;
    }



    var response = await AuthenticationService.checkURLPrefix(domain);
    if ( response == "1" ){
      final snackBar = SnackBar(
        content: Text(
          "We're sorry, but a site with URL prefix " + domain + " already exists. Please select another.",
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSigning = false;
      setState(() {});
      return;
    }
    else {
      var response = await AuthenticationService.createAccount(domain, businessName, firstName, lastName, phone, email, password);
      if ( response != null ){
        if ( response.containsKey("success") && response['success'] == 1 ) {
          final snackBar = new SnackBar(
              content:
              new Text('You have created an account succssfully'),
              duration: Duration(seconds: 2, milliseconds: 500));
          scaffoldKey.currentState.showSnackBar(snackBar);

          await Future.delayed(const Duration(seconds: 2), () => "2");

          isSigning = false;
          setState(() {});

          Navigator.of(context).pop();
          return;
        }
      }

      final snackBar = SnackBar(
        content: Text(
          'An error occurred. Please try again.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    }

    isSigning = false;
    setState(() {});
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

  _signupTextWidget() {
    return Text(
      "Create My Account",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black;
    const Color prefixColor = Color(0xFFA4C6EB);
    const Color boxBorderColor = Colors.black54;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        backgroundColor: Colors.white,
        title: Text("Sign up", style: TextStyle(color: textColor),),
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
                SizedBox(height: 10.0),

                Container(
                  margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                  child: Center(
                    child: Text(
                      "About Your Business",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),

                /* Business name */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "Business Name*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: businessNameFocusNode,
                    onChanged: (newValue){
                      var tmp = newValue.replaceAll(" ", "");
                      _domainController.text = tmp;
                    },
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(firstNameFocusNode);
                    },
                  ),
                ),

                /* Domain */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0 ),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "URL Prefix*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: boxBorderColor),
                        left: BorderSide(width: 1.0, color: boxBorderColor),
                        right: BorderSide(width: 1.0, color: boxBorderColor),
                        bottom: BorderSide(width: 1.0, color: boxBorderColor),
                      ),
                    ),
                    margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                    child: Row(
                        children: <Widget>[
                          Expanded(
                              flex: 7,
                              child: Container(
                                child: TextField(
                                  autocorrect: false,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                  keyboardType: TextInputType.text,
                                  controller: _domainController,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 0.0, bottom: 5.0),
                                  ),
                                  focusNode: domainFocusNode,
                                  onSubmitted: (newValue) {
                                    FocusScope.of(context).requestFocus(businessNameFocusNode);
                                  },
                                ),
                              )
                          ),
                          Expanded(
                              flex: 8,
                              child: Text(".autoglasscrm.com", style: TextStyle(color: textColor, fontSize: 14),)
                          ),

                        ]
                    )
                ),


                Container(
                  margin: const EdgeInsets.only(left: 0.0, top: 30.0),
                  child: Center(
                    child:Text(
                      "Create Your Admin Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),

                /* First name */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "First Name*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: firstNameFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(lastNameFocusNode);
                    },
                  ),
                ),

                /* Last name */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "Last Name*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: lastNameFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(phoneFocusNode);
                    },
                  ),
                ),

                /* Phone */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "Phone",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: phoneFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(emailFocusNode);
                    },
                  ),
                ),

                /* Email */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "Email*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: emailFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                  ),
                ),

                /* Password */
                Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child:Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 29, top: 0, bottom: 0),
                      child: Text(
                        "Password*",
                        style: TextStyle(
                          color: prefixColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: boxBorderColor),
                      left: BorderSide(width: 1.0, color: boxBorderColor),
                      right: BorderSide(width: 1.0, color: boxBorderColor),
                      bottom: BorderSide(width: 1.0, color: boxBorderColor),
                    ),
                  ),
                  margin: const EdgeInsets.only(top:0.0, bottom: 0.0, left:20.0, right: 20.0),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: _pwController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                    ),
                    focusNode: passwordFocusNode,
                    onSubmitted: (newValue) {
                      if (isSigning) {
                        return null;
                      } else {
                        isSigning = true;
                        setState(() {});
                        doSignUp();
                      }
                    },
                  ),
                ),

                /* SignUp button */
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
                              child: isSigning
                                  ? _loadingWidget()
                                  : _signupTextWidget(),
                            ),
                            onPressed: () {
                              if (isSigning) {
                                return null;
                              } else {
                                isSigning = true;
                                setState(() {});
                                doSignUp();
                              }
                            }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.0,)
              ],
            ),
          ),
        );
      }),
    );
  }
}
