import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/customer_overview_item.dart';
import 'package:auto_glass_crm/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:string_mask/string_mask.dart';
import 'package:html_unescape/html_unescape.dart';


class CustomerDetailView extends StatefulWidget {
  _CustomerDetailViewState state;
  String customerId = "";
  int pageMode = 0;  //0: view, 1: edit, 2: create

  CustomerDetailView({this.customerId, this.pageMode});

  @override
  _CustomerDetailViewState createState() {
    state = new _CustomerDetailViewState();
    return state;
  }
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  var formatter = new StringMask("(###) ###-####");
  int pageMode = 0;
  String customerId = "";

  BuildContext _scaffoldContext;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var unescape = new HtmlUnescape();
  bool isSaving = false;

  bool _dataLoaded = false;
  bool _hasError = false;

  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode address1FocusNode = FocusNode();
  final FocusNode address2FocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode zipFocusNode = FocusNode();


  TextEditingController _firstNameController = new TextEditingController(text: "");
  TextEditingController _lastNameController = new TextEditingController(text: "");
  TextEditingController _phoneController = new TextEditingController(text: "");
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _address1Controller = new TextEditingController(text: "");
  TextEditingController _address2Controller = new TextEditingController(text: "");
  TextEditingController _cityController = new TextEditingController(text: "");
  TextEditingController _zipController = new TextEditingController(text: "");
  TextEditingController _notesController = new TextEditingController(text: "");

  String _selectedState = "";


  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    customerId = widget.customerId;
    pageMode = widget.pageMode;
    if ( pageMode == 2 ){
      _dataLoaded = true;
      _hasError = false;
    }
    else{
      loadData();
    }
  }

  void loadData() async {
    var response = await CustomerService.getCustomerDetails(customerId);
    if (response != null && response['success'] == 1 ) {

      var _customerDetails = CustomerOverViewItem.fromJson(response);

      _dataLoaded = true;
      _hasError = false;

      _firstNameController.text = unescape.convert(_customerDetails.first_name);
      _lastNameController.text = unescape.convert(_customerDetails.last_name);
      _emailController.text = _customerDetails.email;
      _phoneController.text = _customerDetails.phone;
      _address1Controller.text = unescape.convert(_customerDetails.address1);
      _address2Controller.text = unescape.convert(_customerDetails.address2);
      _cityController.text = unescape.convert(_customerDetails.city);

      _selectedState = _customerDetails.state;
      if ( _selectedState == null )
        _selectedState = "";

      _zipController.text = _customerDetails.zip;

    } else {
      if ( response != null && response['success'] == 0 ){
        Global.checkResponse(context, response['message']);
      }

      _dataLoaded = true;
      _hasError = true;
    }

    if ( this.mounted ) {
      setState(() {});
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

  _createTextWidget() {
    return Text(
      "Create",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }


  void saveCustomer(int _isDuplicate) async {
    if ( _firstNameController.text.trim().length == 0  ){
      FocusScope.of(context).requestFocus(firstNameFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }


    if ( _lastNameController.text.trim().length == 0  ){
      FocusScope.of(context).requestFocus(lastNameFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }


    if ( _phoneController.text.trim().length == 0  ) {
      FocusScope.of(context).requestFocus(phoneFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _emailController.text.trim().length == 0  ) {
      FocusScope.of(context).requestFocus(emailFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _cityController.text.trim().length == 0  ) {
      FocusScope.of(context).requestFocus(cityFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _selectedState == "" ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a State',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _zipController.text.trim().length == 0  ) {
      FocusScope.of(context).requestFocus(zipFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }

    var firstName = _firstNameController.text.trim();
    var lastName = _lastNameController.text.trim();
    var phone = _phoneController.text.trim();
    var email = _emailController.text.trim();
    var address1 = _address1Controller.text.trim();
    var address2 = _address2Controller.text.trim();
    var city = _cityController.text.trim();
    var state = _selectedState;
    var zip = _zipController.text.trim();
    var notes = _notesController.text.trim();

    FormData fd = new FormData.from({
      "isNotDuplicate": _isDuplicate,
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "email": email,
      "address1": address1,
      "address2": address2,
      "city": city,
      "state": state,
      "zip": zip,
      "notes": notes,
    });

    if ( pageMode == 1 ) {
      fd.add("id", customerId);
    }

    var snackBarLoading = SnackBar(
      duration: Duration(seconds: 60),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Saving...")
        ],
      ),
    );
    Scaffold.of(_scaffoldContext).showSnackBar(snackBarLoading);
    Response response =  await CustomerService.createOrEditCustomer(fd);
    Scaffold.of(_scaffoldContext).hideCurrentSnackBar();

    isSaving = false;
    if (response != null ) {
      if ( response.data is List<dynamic> ){
        List<Widget> dialogContent = new List<Widget>();
        dialogContent.add(
          Text("Does this customer record already exist? Please select the correct customer or 'This is a new customer' below:",
              style:TextStyle(
                  fontSize: Global.fontSizeNormal,
                  decoration: TextDecoration.none
              )
          ),
        );

        dialogContent.add(SizedBox(height:15));

        //List<Widget> items = new List<Widget>();
        for(var i=0;i<response.data.length;i++){
          var text = response.data[i]['first_name'] + " " + response.data[i]['last_name'] + "(" + response.data[i]['address1'] + "," + response.data[i]['city'] + " " + response.data[i]['state'] + ")";
          dialogContent.add(
            GestureDetector(
              onTap: (){
                Navigator.pop(context);

                Map<String, dynamic> result;
                result = {
                  "customer_id": response.data[i]['id'],
                  "name": response.data[i]['first_name'] + " " + response.data[i]['last_name'],
                  "phone": response.data[i]['phone'],
                  "email": response.data[i]['email'],
                  "address1": response.data[i]['address1'],
                  "city": response.data[i]['city'],
                  "state": response.data[i]['state'],
                  "zip": response.data[i]['zip'],
                };

                Navigator.pop(context, json.encode(result));
              },
              child: Padding(padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline, color: Colors.red,),
                    SizedBox(width: 15,),
                    Expanded(
                      child: Text(text,
                          style: TextStyle(
                              fontSize: Global.fontSizeTiny,
                              decoration: TextDecoration.none
                          )
                      ),
                    )

                  ],
                ),
              ),


            )

          );
        }

        dialogContent.add(
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              saveCustomer(1);
            },
            child: Row(
              children: <Widget>[
                Icon(Icons.check_circle_outline, color: Colors.red,),
                SizedBox(width: 15,),
                Expanded(
                  child: Text("This is a new customer",
                      style: TextStyle(
                          fontSize: Global.fontSizeTiny,
                          decoration: TextDecoration.none
                      )
                  ),
                )

              ],
            )
          )
        );

        dialogContent.add(SizedBox(height:20));

        dialogContent.add(
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child:Text("Cancel", style: TextStyle(fontSize:Global.fontSizeNormal,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: Colors.red),
              )
          )
        );

        showDialog<ConfirmAction>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.only(left:20, right:20, top:50, bottom:10),
              color: Color(0xC0FFFFFF),
              child:ListView(
                children: dialogContent
              )
            );

            /*
            return AlertDialog(
              title: Text('Are you sure this is a new customer?\nPlease check this customer already exist.',
                  style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              ),
              content: ListView(
                children: dialogContent,
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    saveCustomer(1);
                  },
                ),
                FlatButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
            */



          },
        );
      }else{
        if ( response.data.containsKey('success') && response.data['success'] == 1 ){

          if ( pageMode == 2 ){
            customerId = response.data['message'];
            //Global.asyncAlertDialog(context, "You have created this customer successfully.");

            Map<String, dynamic> result = {
                  "customer_id": customerId,
                  "name": firstName + " " + lastName,
                  "phone": phone,
                  "email": email,
                  "address1": address1,
                  "city": city,
                  "state": state,
                  "zip": zip,
                };

            Navigator.pop(context, json.encode(result));
          }
          else{
            Global.asyncAlertDialog(context, "You have updated this customer successfully.");
          }
          pageMode = 0;
        }
        else{
          String errorMsg = "An error occurred. Please try again later.";
          if ( response.data['message'].length > 0 ){
            errorMsg = response.data['message'][0];
          }
          final snackBar = SnackBar(
            content: Text(errorMsg),
          );
          Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        }
      }
    } else {
      final snackBar = SnackBar(
        content: Text(
          'An error occurred. Please check your wifi connection.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    }
    setState(() {});
  }


  _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Divider(
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBodySkeleton([double opacity = 0.45]) {
    return Opacity(
      opacity: opacity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Container(
            height: 100,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/skele.png"),
                fit: BoxFit.contain,
                //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(opacity), BlendMode.dstATop)
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ),
      ),
    );
  }

  _buildActionButtons(){
    var ActionButtons = <Widget>[];
    if ( pageMode == 0 ){
      if ( _dataLoaded && _hasError == false ){
        ActionButtons.add(new IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            setState(() {
              pageMode = 1;
            });
          },
        ));
      }
    }
    else{
      ActionButtons.add(new IconButton(
        icon: const Icon(Icons.check, color: Colors.black),
        onPressed: () {
          if ( pageMode == 2 )  // create mode
              {
            if ( isSaving == false ){
              isSaving = true;
              setState(() {});
              saveCustomer(0);
            }
          }
          else if (pageMode == 1 )  // edit mode
              {
            if ( _dataLoaded && _hasError == false ){
              saveCustomer(1);
            }
          }
        },
      ));
    }

    return ActionButtons;
  }
  @override
  Widget build(BuildContext context) {
    const Color color_border = Color(0x30A4C6EB);
    const Color colorSubHeader = Color(0xFF7D90B7);

    var AppTitle;
    if ( pageMode == 0 ) {
      AppTitle = Text("View Customer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else if ( pageMode == 1 ){
      AppTitle = Text("Edit Customer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else{
      AppTitle = Text("Create Customer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    var ActionButtons = _buildActionButtons();

    var fbody = Builder(builder: (BuildContext context) {
      _scaffoldContext = context;



      List<DropdownMenuItem> stateItem = null;
      var stateItemHint = Text("");



      bool enableControls = false;
      if ( pageMode > 0 ) {
        enableControls = true;

        stateItem = Global.stateList.map((state){
          return DropdownMenuItem(child: new Text(state.fullLetter, textAlign: TextAlign.center,), value: state.twoLetter);
        }).toList();
      }else{
        for(var i=0; i< Global.stateList.length;  i++){
          if ( Global.stateList[i].twoLetter == _selectedState ){
            stateItemHint = Text(Global.stateList[i].fullLetter);
            break;
          }
        }
      }

      if (_dataLoaded && !_hasError) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // First Name
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "First Name *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_firstNameController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter First Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: firstNameFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(lastNameFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Last Name
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Last Name *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_lastNameController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Last Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: lastNameFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(phoneFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Phone
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Phone *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    GestureDetector(
                      onTap: (){
                        launch("tel:${_phoneController.text}");
                      },
                      child: Text(
                        _phoneController.text,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      )
                    ):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Phone',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: phoneFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(emailFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Email
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Email *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_emailController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Email',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: emailFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(address1FocusNode);
                      },
                    ),
                  ],
                ),
              ),


              // Address 1
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Address 1",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_address1Controller.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _address1Controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Address 1',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: address1FocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(address2FocusNode);
                      },
                    ),
                  ],
                ),
              ),


              // Address 2
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Address 2",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_address2Controller.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _address2Controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Address 2',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: address2FocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(cityFocusNode);
                      },
                    ),
                  ],
                ),
              ),


              // City
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "City *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_cityController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _cityController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter City',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: cityFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(zipFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // State
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "State *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_selectedState):
                    Container(
                      padding: EdgeInsets.only(left:5, top:2),
                      margin: EdgeInsets.only(top:2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(width: 1.0, color: Colors.black54),
                          top: BorderSide(width: 1.0, color: Colors.black54),
                          bottom:BorderSide(width: 1.0, color: Colors.black54),
                          right: BorderSide(width: 1.0, color: Colors.black54),
                        ),
                      ),
                      child:DropdownButton(
                        isDense: true,
                        isExpanded: true,
                        hint: stateItemHint,
                        value: _selectedState,
                        items: stateItem,
                        onChanged: (newValue){
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            _selectedState = newValue;
                          });
                        }
                      ),
                    ),

                  ],
                ),
              ),


              // Zip
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Zip *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_zipController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _zipController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Zip',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: zipFocusNode,
                      onSubmitted: (newValue) {
                      }
                    ),
                  ],
                ),
              ),


              // Note
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Text(
                        "Note",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_notesController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _notesController,
                      maxLines: 5,
                      maxLength: 400,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Note',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (newValue) {
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height:20)

            ],
          ),
        );
      } else if (_dataLoaded && _hasError) {
        return Center(
          child: Text(
            "Error has occurred.",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        );
      } else {
        return ListView(children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBodySkeleton(0.7),
                _buildDivider(),
                _buildBodySkeleton(0.65),
                _buildDivider(),
                _buildBodySkeleton(0.60),
                _buildDivider(),
                _buildBodySkeleton(0.55),
                _buildDivider(),
                _buildBodySkeleton(0.50),
                _buildDivider(),
                _buildBodySkeleton(0.45),
                _buildDivider(),
                _buildBodySkeleton(0.40),
              ],
            ),
          ),
        ]);
      }
    });

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        backgroundColor: Colors.white,
        title: AppTitle,
        brightness: Brightness.light,
        centerTitle: true,
        actions: ActionButtons
      ),
      body: fbody
    );

  }
}
