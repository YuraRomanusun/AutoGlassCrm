import 'dart:async';
import 'dart:io';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/installer_overview_item.dart';
import 'package:auto_glass_crm/services/installer_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:string_mask/string_mask.dart';
import 'package:html_unescape/html_unescape.dart';


class InstallerDetailView extends StatefulWidget {
  _InstallerDetailViewState state;
  String installerId = "";
  int pageMode = 0;  //0: view, 1: edit, 2: create

  InstallerDetailView({this.installerId, this.pageMode});

  @override
  _InstallerDetailViewState createState() {
    state = new _InstallerDetailViewState();
    return state;
  }
}

class _InstallerDetailViewState extends State<InstallerDetailView> {
  var formatter = new StringMask("(###) ###-####");
  int pageMode = 0;
  String installerId = "";

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
  final FocusNode taxIDFocusNode = FocusNode();
  final FocusNode companyNameFocusNode = FocusNode();
  final FocusNode payRateFocusNode = FocusNode();
  final FocusNode deliveryAddressFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();

  TextEditingController _firstNameController = new TextEditingController(text: "");
  TextEditingController _lastNameController = new TextEditingController(text: "");
  TextEditingController _phoneController = new TextEditingController(text: "");
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _address1Controller = new TextEditingController(text: "");
  TextEditingController _address2Controller = new TextEditingController(text: "");
  TextEditingController _cityController = new TextEditingController(text: "");
  TextEditingController _zipController = new TextEditingController(text: "");
  TextEditingController _taxIDController = new TextEditingController(text:"");
  TextEditingController _companyNameController = new TextEditingController(text:"");
  TextEditingController _payRateController = new TextEditingController(text:"");
  TextEditingController _deliveryAddressController = new TextEditingController(text:"");
  TextEditingController _notesController = new TextEditingController(text:"");

  String _selectedState = "";
  String _selectedType = "Subcontractor";
  String _selectedPaymentMethod = "Salary";
  String _selectedPayRatePer = "hour";
  bool _is_will_call = false;
  bool _is_delivery = false;
  String _selectedTextWorkOrder = "0";

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    installerId = widget.installerId;
    pageMode = widget.pageMode;
    if ( pageMode == 2 ){
      _dataLoaded = true;
      _hasError = false;
    }
    else{
      loadData();
    }
  }

  Future<InstallerOverviewItem> loadData() async {
    InstallerOverviewItem _installerDetails;
    var response = await InstallerService.getInstallerDetails(installerId);
    if ( response != null && response is Map<String, dynamic>){
      if ( response.containsKey("success") && response['success'] == 0 ) {
        Global.checkResponse(context, response['message']);
      }
      else{
        _installerDetails = InstallerOverviewItem.fromJson(response);
      }
    }

    if (_installerDetails != null) {
      _dataLoaded = true;
      _hasError = false;

      _firstNameController.text = unescape.convert(_installerDetails.first_name);
      _lastNameController.text = unescape.convert(_installerDetails.last_name);
      _emailController.text = _installerDetails.email;
      _phoneController.text = _installerDetails.phone;
      _address1Controller.text = unescape.convert(_installerDetails.address1);
      _address2Controller.text = unescape.convert(_installerDetails.address2);
      _cityController.text = unescape.convert(_installerDetails.city);

      _selectedState = _installerDetails.state;
      if ( _selectedState == null )
        _selectedState = "";

      _zipController.text = _installerDetails.zip;
      _selectedType = _installerDetails.type;
      if ( _selectedType == null || _selectedType == "" ){
        _selectedType = "Subcontractor";
      }

      if ( _installerDetails.tax_id == null ){
        _taxIDController.text = "";
      }else {
        _taxIDController.text = _installerDetails.tax_id;
      }

      if ( _installerDetails.company_name == null ){
        _companyNameController.text = "";
      }else {
        _companyNameController.text = unescape.convert(_installerDetails.company_name);
      }

      _selectedPaymentMethod = _installerDetails.payment_method;
      if ( _selectedPaymentMethod == null ){
        _selectedPaymentMethod = "";
      }

      if ( _installerDetails.pay_rate == null ){
        _payRateController.text = "";
      }
      else{
        _payRateController.text = _installerDetails.pay_rate;
      }

      _selectedPayRatePer = _installerDetails.pay_rate_per;
      if ( _selectedPayRatePer == null ){
        _selectedPayRatePer = "";
      }
      else if ( _selectedPayRatePer.contains("job") ){
        _selectedPayRatePer = "job";
      }


      if ( _installerDetails.is_will_call == "1" ){
        _is_will_call = true;
      }else{
        _is_will_call = false;
      }

      if ( _installerDetails.is_delivery == "1" ){
        _is_delivery = true;
      }else{
        _is_delivery = false;
      }

      if ( _installerDetails.text_work_order == "1" ){
        _selectedTextWorkOrder = "1";
      }
      else{
        _selectedTextWorkOrder = "0";
      }

      _deliveryAddressController.text = _installerDetails.delivery_address!=null?unescape.convert(_installerDetails.delivery_address):"";

      if ( _installerDetails.notes != null ) {
        _notesController.text = unescape.convert(_installerDetails.notes);
      }
      else{
        _notesController.text = "";
      }

    } else {
      _dataLoaded = true;
      _hasError = true;
    }

    if ( this.mounted ) {
      setState(() {});
    }

    return _installerDetails;
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


  void saveInstaller(int _isDuplicate) async {
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

    FormData fd = new FormData.from({
      "isNotDuplicate": _isDuplicate,
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "email": _emailController.text.trim(),
      "address1": _address1Controller.text.trim(),
      "address2": _address2Controller.text.trim(),
      "city": _cityController.text.trim(),

      "state": _selectedState,
      "zip": _zipController.text.trim(),
      "type": _selectedType,

      "payment_method": _selectedPaymentMethod,
      "pay_rate": _payRateController.text.trim(),
      "pay_rate_per": _selectedPayRatePer,
      "is_will_call": _is_will_call?"1":"0",
      "is_delivery": _is_delivery?"1":"0",
      "delivery_address": _deliveryAddressController.text.trim(),
      "text_work_order": _selectedTextWorkOrder,
      "notes": _notesController.text.trim(),
    });

    if ( _selectedType == "Subcontractor"){
      fd.add("tax_id", _taxIDController.text.trim());
      fd.add("company_name", _companyNameController.text.trim());
    }

    if ( pageMode > 0 ) {
      fd.add("id", installerId);
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
    Response response =  await InstallerService.createOrEditInstaller(fd);
    Scaffold.of(_scaffoldContext).hideCurrentSnackBar();

    isSaving = false;
    if (response != null ) {
      if ( response.data is List<dynamic> ){
        List<Widget> dialogContent = new List<Widget>();
        for(var i=0;i<response.data.length;i++){
          dialogContent.add(
            new Text(response.data[i]['first_name'] + " " + response.data[i]['last_name'] + "(" + response.data[i]['address1'] + "," + response.data[i]['city'] + " " + response.data[i]['state'] + ")",
                style: TextStyle(fontSize: 12.0))
          );
        }

        showDialog<ConfirmAction>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure this is a new installer?\nPlease check this installer already exist.',
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
                    saveInstaller(1);
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
            installerId = response.data['message'];
            Global.asyncAlertDialog(context, "You have created this installer successfully.");
          }
          else{
            Global.asyncAlertDialog(context, "You have updated this installer successfully.");
          }
          pageMode = 0;
        }
        else{
          print(response);

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
              saveInstaller(0);
            }
          }
          else if (pageMode == 1 )  // edit mode
              {
            if ( _dataLoaded && _hasError == false ){
              saveInstaller(1);
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
      AppTitle = Text("View Installer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else if ( pageMode == 1 ){
      AppTitle = Text("Edit Installer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else{
      AppTitle = Text("Create Installer", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    var ActionButtons = _buildActionButtons();

    var fbody = Builder(builder: (BuildContext context) {
      _scaffoldContext = context;



      List<DropdownMenuItem> stateItem = null;
      var stateItemHint = Text("");

      List<DropdownMenuItem> typeItem = new List();
      var typeItemHint = Text("");

      List<DropdownMenuItem> paymentMethodItem = new List();
      var paymentMethodItemHint = Text("");

      List<DropdownMenuItem> payRatePerItem = new List();
      var payRatePerItemHint = Text("");

      List<DropdownMenuItem> textWorkOrdersItem = new List();
      var textWorkOrdersItemHint = Text("");

      var willCallCallback = null;
      var deliveryCallback = null;

      bool enableControls = false;
      if ( pageMode > 0 ) {
        enableControls = true;

        stateItem = Global.stateList.map((state){
          return DropdownMenuItem(child: new Text(state.fullLetter, textAlign: TextAlign.center,), value: state.twoLetter);
        }).toList();

        typeItem.add(DropdownMenuItem(child: new Text("Subcontractor"), value: "Subcontractor"));
        typeItem.add(DropdownMenuItem(child: new Text("Employee"), value: "Employee"));

        paymentMethodItem.add(DropdownMenuItem(child: new Text("Select Payment Method"), value: ""));
        paymentMethodItem.add(DropdownMenuItem(child: new Text("Salary"), value: "Salary"));
        paymentMethodItem.add(DropdownMenuItem(child: new Text("Direct Deposit"), value: "Direct Deposit"));
        paymentMethodItem.add(DropdownMenuItem(child: new Text("PayPal"), value: "PayPal"));
        paymentMethodItem.add(DropdownMenuItem(child: new Text("Mail Check"), value: "Mail Check"));

        payRatePerItem.add(DropdownMenuItem(child: new Text("Select Pay Rate Per"), value: ""));
        payRatePerItem.add(DropdownMenuItem(child: new Text("hour"), value: "hour"));
        payRatePerItem.add(DropdownMenuItem(child: new Text("job"), value: "job"));

        textWorkOrdersItem.add(DropdownMenuItem(child: new Text("Yes"), value: "1"));
        textWorkOrdersItem.add(DropdownMenuItem(child: new Text("No"), value: "0"));

        willCallCallback = (bool value) {
          setState(() {
            _is_will_call = value;
          });
        };

        deliveryCallback = (bool value) {
          setState(() {
            _is_delivery = value;
          });
        };
      }else{
        for(var i=0; i< Global.stateList.length;  i++){
          if ( Global.stateList[i].twoLetter == _selectedState ){
            stateItemHint = Text(Global.stateList[i].fullLetter);
            break;
          }
        }
        typeItemHint = Text(_selectedType);
        paymentMethodItemHint = Text(_selectedPaymentMethod);
        payRatePerItemHint = Text(_selectedPayRatePer);

        textWorkOrdersItem = null;
        if ( _selectedTextWorkOrder == "0" )
          textWorkOrdersItemHint = Text("No");
        else
          textWorkOrdersItemHint = Text("Yes");
      }


      var taxIdContainer = Container();
      var companyContainer = Container();
      if ( _selectedType == "Subcontractor" ){
        taxIdContainer = Container(
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
                  "Tax ID",
                  style: TextStyle(
                    color: colorSubHeader,
                    fontSize: 16,
                  ),
                ),
              ),
              pageMode==0?
              Text(_taxIDController.text):
              TextField(
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  controller: _taxIDController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: 'Enter Tax ID',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: taxIDFocusNode,
                  onSubmitted: (newValue) {
                    FocusScope.of(context).requestFocus(companyNameFocusNode);
                  }
              ),
            ],
          ),
        );

        companyContainer = Container(
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
                  "Company Name",
                  style: TextStyle(
                    color: colorSubHeader,
                    fontSize: 16,
                  ),
                ),
              ),
              pageMode==0?
              Text(_companyNameController.text):
              TextField(
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: 'Enter Company Name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: companyNameFocusNode,
                  onSubmitted: (newValue) {
                    FocusScope.of(context).requestFocus(payRateFocusNode);
                  }
              ),
            ],
          ),
        );
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
                        FocusScope.of(context).requestFocus(taxIDFocusNode);
                      }
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
                        "Type",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_selectedType):
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
                          hint: typeItemHint,
                          value: _selectedType,
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


              // Tax ID
              taxIdContainer,

              // Company Name
              companyContainer,

              // Payment Method
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
                        "Payment Method",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_selectedPaymentMethod):
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
                          hint: paymentMethodItemHint,
                          value: _selectedPaymentMethod,
                          items: paymentMethodItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedPaymentMethod = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Pay Rate
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
                        "Pay Rate",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_payRateController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _payRateController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Pay Rate',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: payRateFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(deliveryAddressFocusNode);
                      }
                    ),
                  ],
                ),
              ),

              // Pay Rate Per
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
                        "Pay Rate Per",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_selectedPayRatePer):
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
                          hint: payRatePerItemHint,
                          value: _selectedPayRatePer,
                          items: payRatePerItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedPayRatePer = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Delivery Options
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
                        "Delivery Options",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: CheckboxListTile(
                            title: Text("Will Call", style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0
                            )),
                            value: _is_will_call,
                            onChanged: willCallCallback,
                            controlAffinity: ListTileControlAffinity.leading,
                          )
                        ),
                        Expanded(
                            child: CheckboxListTile(
                              title: Text("Delivery", style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0
                              ),),
                              value: _is_delivery,
                              onChanged: deliveryCallback,
                              controlAffinity: ListTileControlAffinity.leading,
                            )
                        ),
                      ],
                    )

                  ],
                ),
              ),

              // Delivery Address
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
                        "Delivery Address",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_deliveryAddressController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      maxLength: 400,
                      controller: _deliveryAddressController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Enter Delivery Address',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      focusNode: deliveryAddressFocusNode,
                      onSubmitted: (newValue) {
                        FocusScope.of(context).requestFocus(notesFocusNode);
                      }
                    ),
                  ],
                ),
              ),

              // Send work order via text?
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
                        "Send work order via text?",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?
                    Text(_selectedTextWorkOrder=="1"?"Yes":"No"):
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
                          hint: textWorkOrdersItemHint,
                          value: _selectedTextWorkOrder,
                          items: textWorkOrdersItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedTextWorkOrder = newValue;
                            });
                          }
                      ),
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
                        //FocusScope.of(context).requestFocus(payRateFocusNode);
                      }
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
