import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:string_mask/string_mask.dart';
import 'package:html_unescape/html_unescape.dart';


class VehicleCreateView extends StatefulWidget {
  _VehicleCreateViewState state;
  String customerId = "";
  String customerName = "";
  VehicleCreateView({this.customerId, this.customerName});

  @override
  _VehicleCreateViewState createState() {
    state = new _VehicleCreateViewState();
    return state;
  }
}

class _VehicleCreateViewState extends State<VehicleCreateView> {
  BuildContext _scaffoldContext;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var unescape = new HtmlUnescape();
  bool isSaving = false;

  final FocusNode yearFocusNode = FocusNode();
  final FocusNode makeFocusNode = FocusNode();
  final FocusNode modelFocusNode = FocusNode();
  final FocusNode trimFocusNode = FocusNode();
  final FocusNode bodyFocusNode = FocusNode();
  final FocusNode vinFocusNode = FocusNode();


  TextEditingController _yearController = new TextEditingController(text: "");
  TextEditingController _makeController = new TextEditingController(text: "");
  TextEditingController _modelController = new TextEditingController(text: "");
  TextEditingController _trimController = new TextEditingController(text: "");
  TextEditingController _bodyController = new TextEditingController(text: "");
  TextEditingController _vinController = new TextEditingController(text: "");


  @override
  void initState() {
    super.initState();
  }

  void saveVehicle() async {
    var model = _modelController.text.trim();
    if ( _yearController.text.trim().length == 0  ){
      FocusScope.of(context).requestFocus(yearFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }


    if ( _makeController.text.trim().length == 0  ){
      FocusScope.of(context).requestFocus(makeFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }

    /*
    if ( Global.isNumeric(model) ){
      FocusScope.of(context).requestFocus(modelFocusNode);

      final snackBar = SnackBar(
        content: Text("Model should be letters."),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }
    */

    if ( model.length == 0  ){
      FocusScope.of(context).requestFocus(modelFocusNode);

      isSaving = false;
      setState(() {});
      return;
    }



    FormData fd = new FormData.from({
      "customer_id": widget.customerId,
      "year": _yearController.text.trim(),
      "make": _makeController.text.trim(),
      "model": _modelController.text.trim(),
      "trim": _trimController.text.trim(),
      "body": _bodyController.text.trim(),
      "vin": _vinController.text.trim(),
    });
    print(fd);

    var snackBarLoading = SnackBar(
      duration: Duration(seconds: 30),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Saving...")
        ],
      ),
    );

    Scaffold.of(_scaffoldContext).showSnackBar(snackBarLoading);
    Response response =  await VehicleService.createOrEditVehicle(fd);
    Scaffold.of(_scaffoldContext).hideCurrentSnackBar();

    isSaving = false;
    if (response != null ) {
      if ( response.data.containsKey('success') && response.data['success'] == 1 ){
        //Global.asyncAlertDialog(context, "You have created this vehicle successfully.");

        Map<String, dynamic> result = {
          "vehicle_id": response.data['message'],
          "text": _makeController.text + " " + _modelController.text + " " + _yearController.text,
        };

        Navigator.pop(context, json.encode(result));
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

    ActionButtons.add(new IconButton(
      icon: const Icon(Icons.check, color: Colors.black),
      onPressed: () {
        if ( isSaving == false ){
          isSaving = true;
          setState(() {});
          saveVehicle();
        }

      },
    ));


    return ActionButtons;
  }

  @override
  Widget build(BuildContext context) {
    const Color color_border = Color(0x30A4C6EB);
    const Color colorSubHeader = Color(0xFF7D90B7);

    var AppTitle;
    AppTitle = Text("New Vehicle for " + widget.customerName, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14.0));

    var ActionButtons = _buildActionButtons();

    var fbody = Builder(builder: (BuildContext context) {
      _scaffoldContext = context;



      List<DropdownMenuItem> stateItem = null;
      var stateItemHint = Text("");



      bool enableControls = true;

      stateItem = Global.stateList.map((state){
        return DropdownMenuItem(child: new Text(state.fullLetter, textAlign: TextAlign.center,), value: state.twoLetter);
      }).toList();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // Year
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
                      "Year *",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _yearController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter Year',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: yearFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(makeFocusNode);
                    },
                  ),
                ],
              ),
            ),

            // Make
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
                      "Make *",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _makeController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter Make',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: makeFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(modelFocusNode);
                    },
                  ),
                ],
              ),
            ),

            // Model
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
                      "Model *",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _modelController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter Model',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: modelFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(trimFocusNode);
                    },
                  ),
                ],
              ),
            ),

            // Trim
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
                      "Trim",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _trimController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter Trim',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: trimFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(bodyFocusNode);
                    },
                  ),
                ],
              ),
            ),

            // Body
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
                      "Body",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _bodyController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter Body',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: bodyFocusNode,
                    onSubmitted: (newValue) {
                      FocusScope.of(context).requestFocus(vinFocusNode);
                    },
                  ),
                ],
              ),
            ),


            // VIN
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
                      "VIN",
                      style: TextStyle(
                        color: colorSubHeader,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextField(
                    enabled: enableControls,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _vinController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0)
                          ),
                          borderSide: const BorderSide(color: color_border, width: 1.0)
                      ),
                      hintText: 'Enter VIN',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: vinFocusNode,
                    onSubmitted: (newValue) {
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

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
