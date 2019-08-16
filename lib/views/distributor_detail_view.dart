import 'dart:async';
import 'dart:io';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/distributor_overview_item.dart';
import 'package:auto_glass_crm/services/distributor_service.dart';
import 'package:auto_glass_crm/services/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:html_unescape/html_unescape.dart';


class DistributorDetailView extends StatefulWidget {
  _DistributorDetailViewState state;
  String distributorId = "";
  int pageMode = 0; // 0: view, 1: edit, 2: create

  DistributorDetailView({this.distributorId, this.pageMode});

  @override
  _DistributorDetailViewState createState() {
    state = new _DistributorDetailViewState();
    return state;
  }
}

class _DistributorDetailViewState extends State<DistributorDetailView> {
  int pageMode = 0;
  String distributorId = "";


  BuildContext _scaffoldContext;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var unescape = new HtmlUnescape();
  bool isSaving = false;

  bool _dataLoaded = false;
  bool _hasError = false;

  final FocusNode distributorFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode faxFocusNode = FocusNode();
  final FocusNode managerNameFocusNode = FocusNode();
  final FocusNode managerEmailFocusNode = FocusNode();
  final FocusNode address1FocusNode = FocusNode();
  final FocusNode address2FocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode zipFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();

  TextEditingController _distributorNameController = new TextEditingController(text: "");
  TextEditingController _phoneController = new TextEditingController(text: "");
  TextEditingController _faxController = new TextEditingController(text: "");
  TextEditingController _managerNameController = new TextEditingController(text: "");
  TextEditingController _managerEmailController = new TextEditingController(text: "");
  TextEditingController _address1Controller = new TextEditingController(text: "");
  TextEditingController _address2Controller = new TextEditingController(text: "");
  TextEditingController _cityController = new TextEditingController(text: "");
  TextEditingController _zipController = new TextEditingController(text: "");
  TextEditingController _notesController = new TextEditingController(text: "");

  String _selectedType = "Dealership";
  String _selectedState = "AL";
  String _selectedPaymentNet30 = "0";
  String _selectedPaymentCOD = "0";

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();


  @override
  void initState() {
    super.initState();

    distributorId = widget.distributorId;
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
    var response = await DistributorService.getDistributorDetails(distributorId);
    if (response != null) {
      if ( response.containsKey("success") && response['success'] == 0 ) {
        Global.checkResponse(context, response['message']);
      }

      DistributorOverviewItem _distributorDetails = DistributorOverviewItem.fromJson(response);

      if ( _distributorDetails != null ) {
        _distributorNameController.text =
            unescape.convert(_distributorDetails.name);
        _selectedType = _distributorDetails.type;
        _phoneController.text = _distributorDetails.phone;
        _faxController.text = _distributorDetails.fax;
        _managerNameController.text =
            unescape.convert(_distributorDetails.managerName);
        _managerEmailController.text = _distributorDetails.managerEmail;
        _address1Controller.text =
            unescape.convert(_distributorDetails.address1);
        _address2Controller.text =
            unescape.convert(_distributorDetails.address2);
        _cityController.text = unescape.convert(_distributorDetails.city);
        _selectedState = _distributorDetails.state;
        if (_selectedState == null) {
          _selectedState = "";
        }
        _zipController.text = _distributorDetails.zip;
        _notesController.text = unescape.convert(_distributorDetails.notes);
        _selectedPaymentNet30 = _distributorDetails.payment_net30;
        _selectedPaymentCOD = _distributorDetails.payment_cod;

        _dataLoaded = true;
        _hasError = false;
      }
      else {
        _dataLoaded = true;
        _hasError = true;
      }
    } else {
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


  void saveDistributor(int _isDuplicate) async {
    if ( _distributorNameController.text.trim().length == 0  ){
      FocusScope.of(context).requestFocus(distributorFocusNode);

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

    FormData fd = new FormData.from({
      "isNotDuplicate": _isDuplicate,
      "name": _distributorNameController.text.trim(),
      "type": _selectedType,
      "phone": _phoneController.text.trim(),
      "fax": _faxController.text.trim(),
      "manager": _managerNameController.text.trim(),
      "email": _managerEmailController.text.trim(),
      "address1": _address1Controller.text.trim(),
      "address2": _address2Controller.text.trim(),
      "city": _cityController.text.trim(),
      "state": _selectedState,
      "zip": _zipController.text.trim(),
      "notes": _notesController.text.trim(),
      "payment_net30": _selectedPaymentNet30,
      "payment_cod": _selectedPaymentCOD
    });

    if ( pageMode == 1 ) {
      fd.add("id", distributorId);
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
    Response response =  await DistributorService.createOrEditDistributor(fd);
    Scaffold.of(_scaffoldContext).hideCurrentSnackBar();

    isSaving = false;
    if (response != null ) {
      if ( response.data is List<dynamic> ){
        List<Widget> dialogContent = new List<Widget>();
        for(var i=0;i<response.data.length;i++){
          dialogContent.add(
            new Text(response.data[i]['name'] + "(" + response.data[i]['address1'] + "," + response.data[i]['city'] + " " + response.data[i]['state'] + ")",
                style: TextStyle(fontSize: 12.0))
          );
        }

        showDialog<ConfirmAction>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure this is a new distributor?\nPlease check this distributtor already exist.',
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
                    saveDistributor(1);
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
          },
        );
      }else{
        if ( response.data.containsKey('success') && response.data['success'] == 1 ){
          if ( pageMode == 2 ){
            distributorId = response.data['message'];
            Global.asyncAlertDialog(context, "You have created this distributor successfully.");
          }
          else{
            Global.asyncAlertDialog(context, "You have updated this distributor successfully.");
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
              saveDistributor(0);
            }
          }
          else if (pageMode == 1 )  // edit mode
              {
            if ( _dataLoaded && _hasError == false ){
              if ( isSaving == false ) {
                isSaving = true;
                setState(() {});
                saveDistributor(1);
              }
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
    if ( pageMode == 0 ){
      AppTitle = Text("View Distributor", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else if ( pageMode == 1 ){
      AppTitle = Text("Edit Distributor", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else{
     AppTitle = Text("Create Distributor", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }

    var ActionButtons = _buildActionButtons();


    List<DropdownMenuItem> typeItem = new List();
    var typeItemHint = Text("");

    List<DropdownMenuItem> stateItem = null;
    var stateItemHint = Text("");

    List<DropdownMenuItem> paymentNet30Item = new List();
    var paymentNet30ItemHint = Text("");

    List<DropdownMenuItem> paymentCODItem = new List();
    var paymentCODItemHint = Text("");

    bool enableControls = false;
    if ( pageMode > 0 ) {
      enableControls = true;

      typeItem.add(DropdownMenuItem(child: new Text("Dealership", textAlign: TextAlign.center,), value: "Dealership") );
      typeItem.add(DropdownMenuItem(child: new Text("Wholesaler", textAlign: TextAlign.center,), value: "Wholesaler") );

      stateItem = Global.stateList.map((state){
        return DropdownMenuItem(child: new Text(state.fullLetter, textAlign: TextAlign.center,), value: state.twoLetter);
      }).toList();

      paymentNet30Item.add( DropdownMenuItem(child: new Text("Yes", textAlign: TextAlign.center,), value: "1") );
      paymentNet30Item.add( DropdownMenuItem(child: new Text("No", textAlign: TextAlign.center,), value: "0") );

      paymentCODItem.add( DropdownMenuItem(child: new Text("Yes", textAlign: TextAlign.center,), value: "1") );
      paymentCODItem.add( DropdownMenuItem(child: new Text("No", textAlign: TextAlign.center,), value: "0") );
    }else{
      typeItemHint = Text(_selectedType);

      for(var i=0; i< Global.stateList.length;  i++){
        if ( Global.stateList[i].twoLetter == _selectedState ){
          stateItemHint = Text(Global.stateList[i].fullLetter);
          break;
        }
      }

      if ( _selectedPaymentNet30 == "1" )
        paymentNet30ItemHint = Text("Yes");
      else
        paymentNet30ItemHint = Text("No");

      if ( _selectedPaymentCOD == "1" )
        paymentCODItemHint = Text("Yes");
      else
        paymentCODItemHint = Text("No");
    }

    var fbody = Builder(builder: (BuildContext context) {
      _scaffoldContext = context;

      if (_dataLoaded && !_hasError) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // Distributor Name
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
                        "Distributor Name *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_distributorNameController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _distributorNameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Distributor Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: distributorFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(phoneFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Type
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
                        "Type *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_selectedType):
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
                        value: _selectedType,
                        hint: typeItemHint,
                        items: typeItem,
                        onChanged: (newValue){
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            _selectedType = newValue;
                          });
                        }
                      ),
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
                      child:Text(_phoneController.text,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          )
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
                        FocusScope.of(context).requestFocus(faxFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Fax
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
                        "Fax",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_faxController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _faxController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Fax',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: faxFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(managerNameFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Manager Name
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
                        "Manager Name",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_managerNameController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _managerNameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Manager Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: managerNameFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(managerEmailFocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Manager / Sales Email
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
                        "Manager / Sales Email *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_managerEmailController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _managerEmailController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Manager / Sales Email',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: managerEmailFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(address1FocusNode);
                      },
                    ),
                  ],
                ),
              ),

              // Address1
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
                    GestureDetector(
                      onTap: (){
                        if ( _address1Controller.text.length > 0 ) {
                          MapUtils.openMapAddress(_address1Controller.text);
                        }
                      },
                      child: Text(_address1Controller.text, style: TextStyle(color: Colors.blue))
                    ):
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

              // Address2
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
                    GestureDetector(
                        onTap: (){
                          if ( _address2Controller.text.length > 0 ) {
                            MapUtils.openMapAddress(_address2Controller.text);
                          }
                        },
                        child: Text(_address2Controller.text, style: TextStyle(color: Colors.blue))
                    ):
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
                    pageMode==0?Text(_cityController.text):
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

              // State *
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
                    pageMode==0?Text(_selectedState):
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
                    pageMode==0?Text(_zipController.text):
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
                        FocusScope.of(context).requestFocus(notesFocusNode);
                      }
                    ),
                  ],
                ),
              ),

              // Notes
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
                        "Notes",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_notesController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        maxLength: 800,
                        controller: _notesController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: 'Enter Notes',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: notesFocusNode,
                        onSubmitted: (newValue) {
                          //FocusScope.of(context).requestFocus(zipFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Payment Net30
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
                        "Payment Net30",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    _selectedPaymentNet30=="1"?Text("Yes"):Text("No"):
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
                          value: _selectedPaymentNet30,
                          hint: paymentNet30ItemHint,
                          items: paymentNet30Item,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedPaymentNet30 = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),


              // Payment COD
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
                        "Payment COD",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    _selectedPaymentCOD=="1"?Text("Yes"):Text("No"):
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
                          value: _selectedPaymentCOD,
                          hint: paymentCODItemHint,
                          items: paymentCODItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedPaymentCOD = newValue;
                            });
                          }
                      ),
                    ),


                  ],
                ),
              ),


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
