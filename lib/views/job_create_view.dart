import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/distributor_overview_item.dart';
import 'package:auto_glass_crm/models/distributor_list_item.dart';
import 'package:auto_glass_crm/models/installer_list_item.dart';
import 'package:auto_glass_crm/models/vehicle.dart';
import 'package:auto_glass_crm/models/job_overview.dart';
import 'package:auto_glass_crm/models/note.dart';
import 'package:auto_glass_crm/services/job_service.dart';
import 'package:auto_glass_crm/services/installer_service.dart';
import 'package:auto_glass_crm/services/distributor_service.dart';
import 'package:auto_glass_crm/services/map_utils.dart';
import 'package:auto_glass_crm/views/customer_search_view.dart';
import 'package:auto_glass_crm/views/customer_detail_view.dart';
import 'package:auto_glass_crm/views/vehicle_create_view.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_image_pick_crop/flutter_image_pick_crop.dart';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:signature_pad/signature_pad.dart';
import 'package:auto_glass_crm/code/signature_pad/signature_pad_controller.dart';

class JobCreateView extends StatefulWidget {
  _JobCreateViewState state;
  String jobId = "";
  int pageMode = 2; //0: view,  1: edit, 2: create

  JobCreateView({this.jobId, this.pageMode});

  @override
  _JobCreateViewState createState() {
    state = new _JobCreateViewState();
    return state;
  }
}

class DistributorSearchItem {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  String id;
  String text;
  String details;

  DistributorSearchItem(this.id, this.text, this.details);
}

class SalesPersonSearchItem {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  String id;
  String text;
  String details;

  SalesPersonSearchItem(this.id, this.text, this.details);
}

class InstallerSearchItem {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  String id;
  String text;
  String details;

  InstallerSearchItem(this.id, this.text, this.details);
}

class VehicleItem{
  String id;
  String text;
  VehicleItem(this.id, this.text);
}

class JobTypeDropDownItem{
  String id;
  String text;
  JobTypeDropDownItem(this.id, this.text);
}

class JobStageDropDownItem{
  String id;
  String text;
  JobStageDropDownItem(this.id, this.text);
}

class _JobCreateViewState extends State<JobCreateView> {
  int pageMode = 2;
  String jobId = "";

  var unescape = new HtmlUnescape();

  BuildContext _scaffoldContext;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSaving = false;

  bool _dataLoaded = false;
  bool _hasError = false;


  ///////////////////////////////////
  /*
  final FocusNode cashFocusNode = FocusNode();
  final FocusNode deductibleFocusNode = FocusNode();
  final FocusNode totalDueFocusNode = FocusNode();
  final FocusNode dispatchFocusNode = FocusNode();
  final FocusNode distributorOrderNumberFocusNode = FocusNode();
  final FocusNode partNumberFocusNode = FocusNode();
  final FocusNode dealerPartNumberFocusNode = FocusNode();
  final FocusNode glassOrderDateFocusNode = FocusNode();
  final FocusNode glassArrivalDateFocusNode = FocusNode();
  final FocusNode glassCostFocusNode = FocusNode();
  final FocusNode deliveryCostFocusNode = FocusNode();
  final FocusNode getInstallerByZipFocusNode = FocusNode();
  final FocusNode jobDateFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();
  */

  final FocusNode cashFocusNode = null;
  final FocusNode deductibleFocusNode = null;
  final FocusNode totalDueFocusNode = null;
  final FocusNode dispatchFocusNode = null;
  final FocusNode distributorOrderNumberFocusNode = FocusNode();
  final FocusNode partNumberFocusNode = null;
  final FocusNode dealerPartNumberFocusNode = null;
  final FocusNode glassOrderDateFocusNode = null;
  final FocusNode glassArrivalDateFocusNode = null;
  final FocusNode glassCostFocusNode = null;
  final FocusNode deliveryCostFocusNode = null;
  final FocusNode getInstallerByZipFocusNode = null;
  final FocusNode jobDateFocusNode = null;
  final FocusNode noteFocusNode = null;

  TextEditingController _cashController = new TextEditingController(text: "");
  TextEditingController _deductibleController = new TextEditingController(text: "");
  TextEditingController _totalDueController = new TextEditingController(text: "");
  TextEditingController _dispatchController = new TextEditingController(text: "");
  TextEditingController _distributorOrderNumberController = new TextEditingController(text: "");
  TextEditingController _partNumberController = new TextEditingController(text: "");
  TextEditingController _dealerPartNumberController = new TextEditingController(text: "");
  TextEditingController _glassOrderDateController = new TextEditingController(text: "");
  TextEditingController _glassArrivalDateController = new TextEditingController(text: "");
  TextEditingController _glassCostController = new TextEditingController(text: "");
  TextEditingController _deliveryCostController = new TextEditingController(text: "");
  TextEditingController _getInstallerByZipController = new TextEditingController(text: "");
  TextEditingController _jobDateController = new TextEditingController(text: "");
  TextEditingController _noteController = new TextEditingController(text: "");
  TextEditingController _timeFrameController = new TextEditingController(text: "");

  String _selectedJobType = "";
  String _selectedJobTypeLabel = "";
  String _selectedJobStage = "";
  String _selectedJobStageLabel = "";
  CustomerSearchItem selectedCustomer;
  String _selectedVehicle = "";
  String _selectedVehicleText = "";
  String _selectedJobDate = "";
  List<VehicleItem> vehicleItems = new List();
  List<JobTypeDropDownItem> jobTypeItems = new List();
  List<JobStageDropDownItem> jobStageItems = new List();

  String _selectedBillingInfo = "";
  String _selectedJobPaymentStatus = "0";
  String _selectedAccessory = "";
  bool   _isTextNotification = true;
  String _savedTimeFrame = "";


  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<SalesPersonSearchItem>>();
  AutoCompleteTextField<SalesPersonSearchItem> textFieldSalesperson;
  SalesPersonSearchItem selectedSalesPerson;
  List<SalesPersonSearchItem> salesPersonSuggestions = [];
  bool  _isSalesPersonSearching = false;
  String _salesPersonSearchKeyLater = "";


  GlobalKey distributorKey = new GlobalKey<AutoCompleteTextFieldState<DistributorSearchItem>>();
  AutoCompleteTextField<DistributorSearchItem> textFieldDistributor;
  DistributorSearchItem selectedDistributor;
  List<DistributorSearchItem> distributorSuggestions = [];
  bool  _isDistributorSearching = false;
  String _distributorSearchKeyLater = "";

  GlobalKey installerKey = new GlobalKey<AutoCompleteTextFieldState<InstallerSearchItem>>();
  AutoCompleteTextField<InstallerSearchItem> textFieldInstaller;
  InstallerSearchItem selectedInstaller;
  List<InstallerSearchItem> installerSuggestions = [];
  bool  _isInstallerSearching = false;
  String _installerSearchKeyLater = "";

  List<TextEditingController> accessory_part_number_controllers = [];
  List<TextEditingController> accessory_cost_controllers = [];
  List<String> accessory_part_type = [];

  List<Note> notes = new List();
  bool autocompleteFirst = true;


  SignaturePadController _padController;
  bool isSignatureStarted = false;
  List<int> windshieldPhotoBytes = new List<int>();
  List<int> vinPhotoBytes = new List<int>();
  List<int> partNumberPhotoBytes = new List<int>();
  List<int> trimPhotoBytes = new List<int>();
  int windshieldPhotoId = 0;
  int vinPhotoId = 0;
  int partNumberPhotoId = 0;
  int trimPhotoId = 0;
  bool isSubmitting = false;
  String _sendText = "Send";

  @override
  void initState() {
    super.initState();

    jobId = widget.jobId;
    pageMode = widget.pageMode;

    textFieldSalesperson = new AutoCompleteTextField<SalesPersonSearchItem>(
      clearOnSubmit: false,
      decoration: new InputDecoration(
          hintText: "Search Salesperson:", suffixIcon: new Icon(Icons.search)),
      textChanged: (text){
        if ( _isSalesPersonSearching ){
          _salesPersonSearchKeyLater = text;
        }
        else {
          searchSalesPerson(text);
        }
      },
      itemSubmitted: (item) {
        selectedSalesPerson = item;
        textFieldSalesperson.textField.controller.text = selectedSalesPerson.text;
        print("item submitted:" + selectedSalesPerson.text);
      },
      key: key,
      suggestions: salesPersonSuggestions,
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(
              title: new Text(suggestion.text),
              ),
          padding: EdgeInsets.all(8.0)),
      itemFilter: (suggestion, input) {
        if ( suggestion.text != null && input != null ) {
          return suggestion.text.toLowerCase().contains(input.toLowerCase());
        }
        else{
          return false;
        }
      }
    );

    textFieldDistributor = new AutoCompleteTextField<DistributorSearchItem>(
      clearOnSubmit: false,
      decoration: new InputDecoration(
          hintText: "Search Distributor:"
      ),
      textChanged: (text){
        if ( _isDistributorSearching ){
          _distributorSearchKeyLater = text;
        }
        else {
          searchDistributor(text);
        }
      },
      itemSubmitted: (item) {
        selectedDistributor = item;
        textFieldDistributor.clear();
        textFieldDistributor.textField.controller.text = selectedDistributor.text;

        distributorSuggestions.clear();
        textFieldDistributor.updateSuggestions(distributorSuggestions);
      },
      key: distributorKey,
      suggestions: distributorSuggestions,
      itemSorter: (item1, item2){
        return item1.text.compareTo(item2.text);
      },
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.text + "(" + suggestion.details + ")",
                style:TextStyle(
                    fontSize: 12.0
                )
            ),
          ),
          padding: EdgeInsets.all(8.0)
      ),
      itemFilter: (suggestion, input){
        print("itemFilter=" + suggestion.text);
        if ( suggestion.text != null && input != null ) {
          return suggestion.text.toLowerCase().contains(input.toLowerCase());
        }
        else{
          return false;
        }
      }

    );

    textFieldInstaller = new AutoCompleteTextField<InstallerSearchItem>(
      clearOnSubmit: false,
      decoration: new InputDecoration(
          hintText: "Search Installer:"),
      textChanged: (text){
        if ( _isInstallerSearching ){
          _installerSearchKeyLater = text;
        }
        else {
          searchInstaller(text);
        }
      },
      itemSubmitted: (item) {
        selectedInstaller = item;

        textFieldInstaller.clear();
        textFieldInstaller.textField.controller.text = selectedInstaller.text;

        installerSuggestions.clear();
        textFieldInstaller.updateSuggestions(installerSuggestions);
      },
      key: installerKey,
      suggestions: installerSuggestions,
      itemSorter: (item1, item2){
        return item1.text.compareTo(item2.text);
      },
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.text + "(" + suggestion.details + ")", style:TextStyle(
                fontSize: 12.0
            ) ),
          ),
          padding: EdgeInsets.all(8.0)
      ),
      itemFilter: (suggestion, input){
        /*
        if ( input.length == 0 ){
          return true;
        }
        */
        if ( suggestion.text != null && input != null ) {
          return suggestion.text.toLowerCase().contains(input.toLowerCase());
        }
        else{
          return false;
        }
      }
    );

    jobTypeItems.add(JobTypeDropDownItem("1", "Back Glass"));
    jobTypeItems.add(JobTypeDropDownItem("2", "Door Glass"));
    jobTypeItems.add(JobTypeDropDownItem("3", "Quarter Glass"));
    jobTypeItems.add(JobTypeDropDownItem("4", "Windshield Repair"));
    jobTypeItems.add(JobTypeDropDownItem("5", "Windshield Replacement"));
    jobTypeItems.add(JobTypeDropDownItem("6", "Windshield Shipment"));
    jobTypeItems.add(JobTypeDropDownItem("19", "Roof Glass"));
    jobTypeItems.add(JobTypeDropDownItem("20", "Side Glass"));
    jobTypeItems.add(JobTypeDropDownItem("21", "Partition Glass"));
    jobTypeItems.add(JobTypeDropDownItem("22", "Vent Glass"));

    jobStageItems.add(JobStageDropDownItem("8", "Follow Up"));
    jobStageItems.add(JobStageDropDownItem("9", "Pending - Call Back"));
    jobStageItems.add(JobStageDropDownItem("10", "Pending - Dealer Parts"));
    jobStageItems.add(JobStageDropDownItem("11", "Phone Call"));
    jobStageItems.add(JobStageDropDownItem("12", "Need to Schedule"));
    jobStageItems.add(JobStageDropDownItem("13", "Scheduled"));
    jobStageItems.add(JobStageDropDownItem("14", "Completed"));
    jobStageItems.add(JobStageDropDownItem("15", "Cancelled"));
    jobStageItems.add(JobStageDropDownItem("16", "Warranty Issue"));
    jobStageItems.add(JobStageDropDownItem("17", "Billed"));
    jobStageItems.add(JobStageDropDownItem("18", "Preinspected"));


    if ( pageMode == 2 ){
      _dataLoaded = true;
      _hasError = false;

      selectedSalesPerson = new SalesPersonSearchItem(Global.userID, Global.userFirstName + " " + Global.userLastName, "");
    }
    else{
      loadData();
    }

    windshieldPhotoBytes = new List<int>();
    vinPhotoBytes = new List<int>();
    partNumberPhotoBytes = new List<int>();
    trimPhotoBytes = new List<int>();

    _padController = new SignaturePadController(onDrawStart: () {
      setState(() {
        isSignatureStarted = true;
      });
    });
  }

  Future<JobOverview> loadData() async {
    JobOverview _jobDetails = await JobService.getJobDetails(jobId);
    if (_jobDetails != null) {
      if ( _jobDetails.salesperson != null ) {
        selectedSalesPerson = new SalesPersonSearchItem(
            _jobDetails.salesperson, _jobDetails.salespersonName, "");
      }

      _selectedJobType = _jobDetails.type;
      _selectedJobTypeLabel = _jobDetails.type_label;
      _selectedJobStage = _jobDetails.stage;
      _selectedJobStageLabel = _jobDetails.stage_label;

      var jobstageexist = false;
      for(var i=0;i<jobStageItems.length;i++){
        if ( jobStageItems[i].id == _selectedJobStage ){
          jobstageexist = true;
          break;
        }
      }
      if ( jobstageexist == false || _selectedJobStageLabel == null ){
        _selectedJobStageLabel = "";
        _selectedJobStage = "";
      }

      if ( _jobDetails.customerID.length > 0 ){
        selectedCustomer = new CustomerSearchItem(_jobDetails.customerID);
        selectedCustomer.name = _jobDetails.customerName;
        selectedCustomer.phone = _jobDetails.customerPhone;
        selectedCustomer.address1 = _jobDetails.customerAddress1;
        selectedCustomer.email = _jobDetails.customerEmail;
        selectedCustomer.city = _jobDetails.customerCity;
        selectedCustomer.state = _jobDetails.customerState;
        selectedCustomer.zip = _jobDetails.customerZip;
      }else{
        selectedCustomer = null;
      }

      _selectedVehicle = _jobDetails.vehicleId;
      if ( _jobDetails.vehicle != null ) {
        _selectedVehicleText =
            _jobDetails.vehicle.make + " " + _jobDetails.vehicle.model + " " +
                _jobDetails.vehicle.year;
      }else{
        _selectedVehicleText = "";
      }
      _selectedBillingInfo = _jobDetails.billingInfo;
      _cashController.text = _jobDetails.cashCCPaid;
      _deductibleController.text = _jobDetails.deductible;
      _selectedJobPaymentStatus = _jobDetails.totalDuePaid;
      _totalDueController.text = _jobDetails.totalDue;
      _dispatchController.text = _jobDetails.orderNum;

      if ( _jobDetails.distributorID.length > 0 ) {
        selectedDistributor = new DistributorSearchItem(
            _jobDetails.distributorID, _jobDetails.distributorName, "");
      }

      _distributorOrderNumberController.text = _jobDetails.distributorOrderNum;
      _partNumberController.text = _jobDetails.partNumber;
      _dealerPartNumberController.text = _jobDetails.dealerPartNum;
      _glassOrderDateController.text = _jobDetails.glassOrderDate;
      _glassArrivalDateController.text = _jobDetails.glassArrivalDate;
      _glassCostController.text = _jobDetails.costGlass;
      _deliveryCostController.text = _jobDetails.costDelivery;

      if ( _jobDetails.accessories != null ){
        for(var i=0; i < _jobDetails.accessories.length; i++){
          accessory_part_type.add(_jobDetails.accessories[i].type);
          TextEditingController partNumController = new TextEditingController(text:_jobDetails.accessories[i].partNumber);
          accessory_part_number_controllers.add(partNumController);
          TextEditingController costController = new TextEditingController(text:_jobDetails.accessories[i].cost);
          accessory_cost_controllers.add(costController);
        }
      }
      if ( _jobDetails.installerID.length > 0 ) {
        selectedInstaller = new InstallerSearchItem(
            _jobDetails.installerID, _jobDetails.installerName, "");
      }
      _selectedJobDate = _jobDetails.date;
      _jobDateController.text = _jobDetails.date;
      _timeFrameController.text = _jobDetails.timeframe_start + "-" + _jobDetails.timeframe_end;
      if ( _jobDetails.timeframe_start.length > 2 && _jobDetails.timeframe_end.length > 2 ){
        _savedTimeFrame = _jobDetails.timeframe_start.substring(0, _jobDetails.timeframe_start.length - 2) + "-" + _jobDetails.timeframe_end.substring(0, _jobDetails.timeframe_end.length - 2);
      }
      notes = _jobDetails.notes;

      if ( selectedCustomer != null  ) {
        loadVehicle(selectedCustomer.id);
      }

      _dataLoaded = true;
      _hasError = false;
    } else {
      _dataLoaded = true;
      _hasError = true;
    }

    if ( this.mounted ) {
      setState(() {});
    }

    return _jobDetails;
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


  void saveJob() async {
    if ( _selectedJobType == ""  ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Job Type',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _selectedJobStage == ""  ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Job Stage',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( selectedCustomer == null ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Customer',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( _selectedVehicle == "" ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Vehicle',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( selectedDistributor == null ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Distributor',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    if ( selectedInstaller == null ){
      final snackBar = SnackBar(
        content: Text(
          'Please select a Installer',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    var timeFrameStart = "";
    var timeFrameEnd = "";
    var tmpTimeFrame = "";

    var timeFrameArray = _timeFrameController.text.trim().split("-");
    if ( timeFrameArray.length == 2 ){
      if ( timeFrameArray[0].length >= 3 ) {
        var tmp1 = timeFrameArray[0].substring(timeFrameArray[0].length - 2);
        var tmp2 = timeFrameArray[0].substring(0, timeFrameArray[0].length - 2);

        if ( tmp1.toLowerCase() == "pm" || tmp1.toLowerCase() == "am"){
          var tmp3 = int.parse(tmp2);
          if ( tmp3 >= 0 && tmp3 <= 12 ){
            timeFrameStart = timeFrameArray[0];
            tmpTimeFrame = tmp2;
          }
        }
      }

      if ( timeFrameArray[1].length >= 3 ) {
        var tmp1 = timeFrameArray[1].substring(timeFrameArray[1].length - 2);
        var tmp2 = timeFrameArray[1].substring(0, timeFrameArray[1].length - 2);

        if ( tmp1.toLowerCase() == "pm" || tmp1.toLowerCase() == "am"){
          var tmp3 = int.parse(tmp2);
          if ( tmp3 >= 0 && tmp3 <= 12 ){
            timeFrameEnd = timeFrameArray[1];
            tmpTimeFrame = tmpTimeFrame + "-" + tmp2;
          }
        }
      }
    }

    if ( timeFrameStart == "" || timeFrameEnd == "" ){
      final snackBar = SnackBar(
        content: Text(
          'Please input correct timeframe(ex: 10am-5pm)',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      isSaving = false;
      setState(() {});
      return;
    }

    FormData fd = new FormData.from({
      "deductible": _deductibleController.text.trim(),
      "order_num": _dispatchController.text.trim(),
      "type": _selectedJobType,
      "stage": _selectedJobStage,
      "vehicle": _selectedVehicle,
      "billing_info": _selectedBillingInfo,
      "cashccpaid": _cashController.text.trim(),
      "total_due": _totalDueController.text.trim(),
      "total_due_paid": _selectedJobPaymentStatus,
      "part_number": _partNumberController.text.trim(),
      "dealer_part_num": _dealerPartNumberController.text.trim(),
      "glass_order_date":  _glassOrderDateController.text.trim(),
      "glass_arrival_date": _glassArrivalDateController.text.trim(),
      "distributor": selectedDistributor.id,
      "distributor_order_num": _distributorOrderNumberController.text.trim(),
      "cost_glass": _glassCostController.text.trim(),
      "cost_delivery": _deliveryCostController.text.trim(),
      "installer": selectedInstaller.id,
      "date": _selectedJobDate,
      "timeframe_start": timeFrameStart,
      "timeframe_end": timeFrameEnd,
      "no_texts": _isTextNotification?"1":"0",
      "note": _noteController.text.trim()
    });

    if ( pageMode < 2 ) {
      fd.add("id", jobId);
    }

    if ( selectedSalesPerson != null && selectedSalesPerson.id != null ){
      fd.add("salesperson", selectedSalesPerson.id);
    }

    List<String> accessoryPartNumber = [];
    for(var i=0;i<accessory_part_number_controllers.length;i++){
      accessoryPartNumber.add(accessory_part_number_controllers[i].text);
    }

    List<String> accessoryCost = [];
    for(var i=0;i<accessory_cost_controllers.length;i++){
      accessoryCost.add(accessory_cost_controllers[i].text);
    }

    fd.add("accessory_type", accessory_part_type);
    fd.add("accessory_part_number", accessoryPartNumber);
    fd.add("accessory_cost", accessoryCost);



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
    Response response =  await JobService.createOrEditJob(fd);
    Scaffold.of(_scaffoldContext).hideCurrentSnackBar();

    isSaving = false;
    if (response != null ) {
      if ( response.data is Map<String, dynamic> && response.data.containsKey('success') && response.data['success'] == 1 ){
        _savedTimeFrame = tmpTimeFrame;

        if ( pageMode == 2 ){
          jobId = response.data['message'];
          Global.asyncAlertDialog(context, "You have created this job successfully.");
        }
        else{
          Global.asyncAlertDialog(context, "You have updated this job successfully.");
        }
        pageMode = 0;
      }
      else{
        if ( response.data.containsKey("message") )
          Global.checkResponse(context, response.data['message'][0]);

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
          'An error occurred. Please try again.',
        ),
      );
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    }
    setState(() {});
  }

  void searchSalesPerson(String key) async{
    selectedSalesPerson = null;
    if ( key.length == 0 ) {
      salesPersonSuggestions.clear();
      textFieldSalesperson.updateSuggestions(salesPersonSuggestions);
      return;
    }

    if ( key.length < 3 ) {
      return;
    }

    _isSalesPersonSearching = true;
    salesPersonSuggestions.clear();

    var response = await JobService.searchSalesPerson( key);
    salesPersonSuggestions.clear();

    if ( response != null ){
      for(var i=0;i< response.length;i++){
        SalesPersonSearchItem item = new SalesPersonSearchItem(
            response[i]['id'], response[i]['first_name'] + " " + response[i]['last_name'], response[i]['email']);
        salesPersonSuggestions.add(item);
      }
    }

    textFieldSalesperson.updateSuggestions(salesPersonSuggestions);

    if ( this.mounted ){
      setState(() {
      });
    }

    _isSalesPersonSearching = false;

    if ( _salesPersonSearchKeyLater.length > 0 ){
      searchSalesPerson(_salesPersonSearchKeyLater);
      _salesPersonSearchKeyLater = "";
    }
  }

  void searchDistributor(String key) async{
    selectedDistributor = null;
    if ( key.length == 0 ) {
      distributorSuggestions.clear();
      textFieldDistributor.updateSuggestions(distributorSuggestions);
      return;
    }

    if ( key.length < 3 ) {
      return;
    }

    _isDistributorSearching = true;
    distributorSuggestions.clear();
    var response = await DistributorService.getDistributorList("1", "10", key);
    if ( response != null ) {
      if ( response is Map<String, dynamic> && response.containsKey("success") && response['success'] == 0) {
        Global.checkResponse(context, response['message']);
      }
      else if ( response is List<dynamic>){
        var _distributorsResult = List<DistributorListItem>();
        response.forEach((o) {
          var item = DistributorListItem.fromJson(o);

          _distributorsResult.add(item);
        });

        if (_distributorsResult != null && _distributorsResult.length > 0) {
          for (var i = 0; i < _distributorsResult.length; i++) {
            var _distributor = _distributorsResult[i];
            DistributorSearchItem item = new DistributorSearchItem(
                _distributor.id, _distributor.name, _distributor.location);
            distributorSuggestions.add(item);
          }
        }
      }
    }

    textFieldDistributor.updateSuggestions(distributorSuggestions);

    if ( this.mounted ){
      setState(() {
      });
    }
    _isDistributorSearching = false;

    if ( _distributorSearchKeyLater.length > 0 ){
      searchDistributor(_distributorSearchKeyLater);
      _distributorSearchKeyLater = "";
    }
  }

  void searchInstaller(String key) async{
    selectedInstaller = null;

    if ( key.length == 0 ) {
      installerSuggestions.clear();
      textFieldInstaller.updateSuggestions(installerSuggestions);
      return;
    }

    if ( key.length < 3 ) {
      return;
    }

    _isInstallerSearching = true;
    installerSuggestions.clear();

    var response = await InstallerService.getInstallerList("1", "10", key);
    if ( response != null ) {
      if ( response is List<dynamic> ){
        var _installersResult = List<InstallerListItem>();
        response.forEach((o) {
          var item = InstallerListItem.fromJson(o);
          _installersResult.add(item);
        });

        for(var i=0;i<_installersResult.length;i++){
          var _installer = _installersResult[i];

          InstallerSearchItem item = new InstallerSearchItem(
              _installer.id, _installer.first_name + " " + _installer.last_name,
              _installer.location);
          installerSuggestions.add(item);

        }
      }
      else if ( response.containsKey("success") && response['success'] == 0) {
        Global.checkResponse(context, response['message']);
      }
    }

    textFieldInstaller.updateSuggestions(installerSuggestions);

    if ( this.mounted ){
      setState(() {
      });
    }

    _isInstallerSearching = false;

    if ( _installerSearchKeyLater.length > 0 ){
      searchInstaller(_installerSearchKeyLater);
      _installerSearchKeyLater = "";
    }

  }

  void loadVehicle(String cid) async{
    vehicleItems.clear();
    var response =  await JobService.searchVehicles(cid);
    if ( response != null ){
      bool isIn= false;
      for(var i=0;i< response.length;i++){
        if ( response[i]['id'] == _selectedVehicle ){
          isIn = true;
          break;
        }
      }

      if ( isIn == false ) {
        _selectedVehicle = "";
        _selectedVehicleText = "";
      }

      for(var i=0;i< response.length;i++){
        var text = response[i]['make'] + " " + response[i]['model'] + " " + response[i]['year'];

        if ( _selectedVehicle == "" ){
          _selectedVehicle = response[i]['id'];
          _selectedVehicleText = text;
        }

        vehicleItems.add(new VehicleItem(response[i]['id'], text));
      }

    }

    if ( this.mounted ) {
      setState(() {});
    }
  }
  void showCustomerCreatePage() async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerDetailView(customerId: "0", pageMode: 2,) ),
    );
    print(result);
    if ( result != null ){
      var jsonResult = json.decode(result);
      if ( jsonResult != null ) {
        selectedCustomer = new CustomerSearchItem(jsonResult['customer_id'].toString());
        selectedCustomer.name = jsonResult['name'];
        selectedCustomer.phone = jsonResult['phone'];
        selectedCustomer.email = jsonResult['email'];
        selectedCustomer.address1 = jsonResult['address1'];
        selectedCustomer.city = jsonResult['city'];
        selectedCustomer.state = jsonResult['state'];
        selectedCustomer.zip = jsonResult['zip'];

        loadVehicle(selectedCustomer.id);
      }
      else{
        selectedCustomer = null;
      }

      if ( this.mounted ) {
        setState(() {
        });
      }
    }
  }

  void showCustomerSearch() async{
    final result = await Navigator.push(
      context,
      // We'll create the SelectionScreen in the next step!
      MaterialPageRoute(builder: (context) => CustomerSearchView()),
    );
    print(result);
    if ( result != null ){
      var jsonResult = json.decode(result);
      if ( jsonResult != null ) {
        selectedCustomer = new CustomerSearchItem(jsonResult['customer_id'].toString());
        selectedCustomer.name = jsonResult['name'];
        selectedCustomer.phone = jsonResult['phone'];
        selectedCustomer.email = jsonResult['email'];
        selectedCustomer.address1 = jsonResult['address1'];
        selectedCustomer.city = jsonResult['city'];
        selectedCustomer.state = jsonResult['state'];
        selectedCustomer.zip = jsonResult['zip'];

        loadVehicle(selectedCustomer.id);
      }
      else{
        selectedCustomer = null;
      }

      if ( this.mounted ) {
        setState(() {

        });
      }
    }
  }

  void showCreateVehicleView() async{
    FocusScope.of(context)
        .requestFocus(new FocusNode());

    if ( selectedCustomer == null ){
      return;
    }

    final result = await Navigator.push(
      context,
      // We'll create the SelectionScreen in the next step!
      MaterialPageRoute(builder: (context) => VehicleCreateView(customerId: selectedCustomer.id, customerName: selectedCustomer.name,)),
    );
    print(result);
    if ( result != null ) {
      var jsonResult = json.decode(result);
      if (jsonResult != null) {
        var vehicleId = jsonResult['vehicle_id'].toString();
        var text = jsonResult['text'];
        vehicleItems.add(new VehicleItem(vehicleId, text));

        if ( _selectedVehicle == "" ){
          _selectedVehicle = vehicleId;
          _selectedVehicleText = text;
        }
      }
    }

    if ( this.mounted ) {
      setState(() {});
    }
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
              FocusScope.of(context).requestFocus(new FocusNode());
              pageMode = 1;
              autocompleteFirst = true;
            });

          },
        ));
      }
    }
    else{
      if ( isSaving == false ) {
        ActionButtons.add(new IconButton(
          icon: const Icon(Icons.check, color: Colors.black),
          onPressed: () {
            if (pageMode == 2) // create mode
            {
              if (isSaving == false) {
                isSaving = true;
                setState(() {});
                saveJob();
              }
            }
            else if (pageMode == 1) // edit mode
            {
              if (_dataLoaded && _hasError == false) {
                if (isSaving == false) {
                  isSaving = true;
                  setState(() {});
                  saveJob();
                }
              }
            }
          },
        ));
      }
    }

    return ActionButtons;
  }

  _buildNotes() {
    var noteRows = List<Widget>();
    notes
        .take(5)
        .where((q) => q.name != 'Installer (via web link)')
        .forEach((note) {
      noteRows.add(Padding(
        padding: EdgeInsets.only(
          bottom: 10,
        ),
      ));

      noteRows.add(Row(
        children: <Widget>[
          Text(
            unescape.convert(note.name),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
          ),
          Expanded(
            child:Text(
              note.date,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
              ),
            ),
          )
        ],
      ));

      noteRows.add(Padding(
        padding: EdgeInsets.only(
          bottom: 5,
        ),
      ));
      noteRows.add(Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(unescape.convert(note.text)),
              ),
              color: Colors.black12,
            ),
          )
        ],
      ));
    });

    return noteRows;
  }

  Future<File> getImage(bool fromCamera) async {
    var image = await ImagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    return image;
  }

  Widget _cameraImage(ImageProvider<dynamic> img) {
    return Container(
      width: 70.0,
      height: 70.0,
      padding: EdgeInsets.all(5.0),
      decoration: new BoxDecoration(
        image: DecorationImage(
          image: img,
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0)),
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
    );
  }

  _showUploadOptions(PhotoSelected selectedPhoto) {
    // show picker options
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  child: ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('TAKE PHOTO'),
                    onTap: () async {
                      getImage(true).then((image) async {
                        Navigator.of(context).pop();

                        ImageProperties properties = await FlutterNativeImage.getImageProperties(image.path);

                        int width = properties.width;
                        int height = properties.height;

                        if ( properties.width > properties.height ){
                          if ( properties.width > 800 ){
                            width = 800;
                            height = width * properties.height ~/ properties.width;
                          }
                        }
                        else{
                          if ( properties.height > 800 ){
                            height = 800;
                            width = height * properties.width ~/ properties.height;
                          }
                        }

                        File compressedFile =
                        await FlutterNativeImage.compressImage(image.path, quality: 70, targetWidth: width, targetHeight: height);

                        switch (selectedPhoto) {
                          case PhotoSelected.Windshield:
                            windshieldPhotoBytes =
                                compressedFile.readAsBytesSync();
                            windshieldPhotoId = await JobService.uploadPhoto(
                                windshieldPhotoBytes,
                                widget.jobId,
                                'windshield');
                            setState(() {});
                            break;
                          case PhotoSelected.VIN:
                            vinPhotoBytes = compressedFile.readAsBytesSync();
                            vinPhotoId = await JobService.uploadPhoto(
                                vinPhotoBytes, widget.jobId, 'vin');
                            setState(() {});
                            break;
                          case PhotoSelected.PartNumber:
                            partNumberPhotoBytes =
                                compressedFile.readAsBytesSync();
                            partNumberPhotoId = await JobService.uploadPhoto(
                                partNumberPhotoBytes,
                                widget.jobId,
                                'partnumber');
                            setState(() {});
                            break;
                          case PhotoSelected.TrimName:
                            trimPhotoBytes = compressedFile.readAsBytesSync();
                            trimPhotoId = await JobService.uploadPhoto(
                                trimPhotoBytes, widget.jobId, 'trim');
                            setState(() {});
                            break;
                        }
                      });
                    },
                  ),
                ),
                InkWell(
                  child: ListTile(
                    leading: Icon(Icons.photo_album),
                    title: Text('CHOOSE EXISTING'),
                    onTap: () {
                      getImage(false).then((image) async {
                        Navigator.of(context).pop();

                        if ( image != null ) {
                          ImageProperties properties = await FlutterNativeImage.getImageProperties(image.path);

                          int width = properties.width;
                          int height = properties.height;

                          if ( properties.width > properties.height ){
                            if ( properties.width > 800 ){
                              width = 800;
                              height = width * properties.height ~/ properties.width;
                            }
                          }
                          else{
                            if ( properties.height > 800 ){
                              height = 800;
                              width = height * properties.width ~/ properties.height;
                            }
                          }

                          File compressedFile =
                          await FlutterNativeImage.compressImage(image.path, quality: 70, targetWidth: width, targetHeight: height);


                          switch (selectedPhoto) {
                            case PhotoSelected.Windshield:
                              windshieldPhotoBytes =
                                  compressedFile.readAsBytesSync();
                              windshieldPhotoId = await JobService.uploadPhoto(
                                  windshieldPhotoBytes,
                                  widget.jobId,
                                  'windshield');
                              setState(() {});
                              break;
                            case PhotoSelected.VIN:
                              vinPhotoBytes = compressedFile.readAsBytesSync();
                              vinPhotoId = await JobService.uploadPhoto(
                                  vinPhotoBytes, widget.jobId, 'vin');
                              setState(() {});
                              break;
                            case PhotoSelected.PartNumber:
                              partNumberPhotoBytes =
                                  compressedFile.readAsBytesSync();
                              partNumberPhotoId = await JobService.uploadPhoto(
                                  partNumberPhotoBytes,
                                  widget.jobId,
                                  'partnumber');
                              setState(() {});
                              break;
                            case PhotoSelected.TrimName:
                              trimPhotoBytes = compressedFile.readAsBytesSync();
                              trimPhotoId = await JobService.uploadPhoto(
                                  trimPhotoBytes, widget.jobId, 'trim');
                              setState(() {});
                              break;
                          }
                        }
                      });
                    },
                  ),
                ),
                InkWell(
                  child: ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text('CANCEL'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  _removePhoto(int photoId, PhotoSelected photoSelected) async {
    await JobService.removePhoto(photoId);

    switch (photoSelected) {
      case PhotoSelected.Windshield:
        windshieldPhotoBytes = new List<int>();
        windshieldPhotoId = 0;
        break;
      case PhotoSelected.PartNumber:
        partNumberPhotoBytes = new List<int>();
        partNumberPhotoId = 0;
        break;
      case PhotoSelected.VIN:
        vinPhotoBytes = new List<int>();
        vinPhotoId = 0;
        break;
      case PhotoSelected.TrimName:
        trimPhotoBytes = new List<int>();
        trimPhotoId = 0;
        break;
    }

    setState(() {});
  }

  _windshieldPhoto() {
    if (windshieldPhotoBytes.length == 0) {
      return GestureDetector(
        onTap: () {
          _showUploadOptions(PhotoSelected.Windshield);
        },
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: new Border.all(
                  color: Colors.blueAccent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                  icon:
                  Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                  onPressed: null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
            ),
            Text(
              "Windshield",
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: <Widget>[
              _cameraImage(
                  Image.memory(windshieldPhotoBytes, fit: BoxFit.contain)
                      .image),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
              ),
              Text(
                "Windshield",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blueAccent,

                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _removePhoto(windshieldPhotoId, PhotoSelected.Windshield);
            },
            child: Align(
              alignment: Alignment.center,
              child: Stack(children: [
                Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 30,
                ),
                Icon(
                  Icons.remove_circle_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ]),
            ),
          ),
        ],
      );
    }
  }

  _partNumberPhoto() {
    if (partNumberPhotoBytes.length == 0) {
      return GestureDetector(
        onTap: () {
          _showUploadOptions(PhotoSelected.PartNumber);
        },
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: new Border.all(
                  color: Colors.blueAccent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                  icon:
                  Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                  onPressed: null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
            ),
            Text(
              "Part Number",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: <Widget>[
              _cameraImage(
                  Image.memory(partNumberPhotoBytes, fit: BoxFit.contain)
                      .image),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
              ),
              Text(
                "Part Number",
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _removePhoto(partNumberPhotoId, PhotoSelected.PartNumber);
            },
            child: Align(
              alignment: Alignment.center,
              child: Stack(children: [
                Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 30,
                ),
                Icon(
                  Icons.remove_circle_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ]),
            ),
          ),
        ],
      );
    }
  }

  _vinPhoto() {
    if (vinPhotoBytes.length == 0) {
      return GestureDetector(
        onTap: () {
          _showUploadOptions(PhotoSelected.VIN);
        },
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: new Border.all(
                  color: Colors.blueAccent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                  icon:
                  Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                  onPressed: null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
            ),
            Text(
              "VIN",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: <Widget>[
              _cameraImage(
                  Image.memory(vinPhotoBytes, fit: BoxFit.contain).image),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
              ),
              Text(
                "VIN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _removePhoto(vinPhotoId, PhotoSelected.VIN);
            },
            child: Align(
              alignment: Alignment.center,
              child: Stack(children: [
                Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 30,
                ),
                Icon(
                  Icons.remove_circle_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ]),
            ),
          ),
        ],
      );
    }
  }

  _trimPhoto() {
    if (trimPhotoBytes.length == 0) {
      return GestureDetector(
        onTap: () {
          _showUploadOptions(PhotoSelected.TrimName);
        },
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: new Border.all(
                  color: Colors.blueAccent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                  icon:
                  Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                  onPressed: null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
            ),
            Text(
              "Trim Name",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: <Widget>[
              _cameraImage(
                  Image.memory(trimPhotoBytes, fit: BoxFit.contain).image),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
              ),
              Text(
                "Trim Name",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _removePhoto(trimPhotoId, PhotoSelected.TrimName);
            },
            child: Align(
              alignment: Alignment.center,
              child: Stack(children: [
                Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 30,
                ),
                Icon(
                  Icons.remove_circle_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ]),
            ),
          ),
        ],
      );
    }
  }

  _buildPhotoRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height:15),
            Row(
              children: <Widget>[
                Icon(
                  Icons.camera_alt,
                  color: Color(0xFF7D90B7),
                ),
                Text(
                  "  Add Photos",
                  style: TextStyle(
                    color: Color(0xFF7D90B7),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _windshieldPhoto(),
                ),
                Expanded(
                  child: _partNumberPhoto(),
                ),
                Expanded(
                  child: _vinPhoto(),
                ),
                Expanded(
                  child: _trimPhoto(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleClear() {
    setState(() {
      _padController.clear();
      isSignatureStarted = false;
    });
  }

  Future _handleSavePng() async {
    var tmp = await _padController.toPng();
    return tmp;
  }

  _buildSignatureRow() {
    var signaturePad = new SignaturePadWidget(
      _padController,
      new SignaturePadOptions(
          maxWidth: 1.0,
          penColor: "#000000",
          signatureText:
          "Signed by ${selectedCustomer!=null?selectedCustomer.name:""} on ${DateTime.now()}"),
    );

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      MdiIcons.pen,
                      color: Color(0xFF7D90B7),
                    ),
                    Text(
                      "  Signature",
                      style: TextStyle(
                        color: Color(0xFF7D90B7),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => _handleClear(),
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 200.0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: signaturePad,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _saveJobDetails(_context) async {
    var signatureBytes;
    var success = false;
    try {
      signatureBytes = await _padController.toPng();
      success = await JobService.saveJobDetails(signatureBytes, widget.jobId, notes: _noteController.text);
    }catch(e){
      print("saveJobDetails error:" + e.toString());
    }

    if (success) {
      isSubmitting = false;

      var snackBar = new SnackBar(
          content:
          new Text('Successfully Sent...'),
          duration: Duration(seconds: 2, milliseconds: 500));
      scaffoldKey.currentState.showSnackBar(snackBar);
      await Future.delayed(const Duration(seconds: 2), (){
      });

      setState(() {
        Navigator.of(_context).pop();
      });

    } else {
      isSubmitting = false;
      var snackBar = new SnackBar(
          content: new Text('An error occurred.  Try again.'),
          duration: Duration(seconds: 2, milliseconds: 500));
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  _sendTextWidget() {
    return Text(
      _sendText,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
  }

  _submittingWidget() {
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

  @override
  Widget build(BuildContext context) {
    const Color color_border = Color(0x30A4C6EB);
    const Color colorSubHeader = Color(0xFF7D90B7);

    var appTitle;
    if ( pageMode == 0 ){
      appTitle = Text("View Job", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else if ( pageMode == 1 ){
      appTitle = Text("Edit Job", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }
    else{
      appTitle = Text("Create Job", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0));
    }

    var ActionButtons = _buildActionButtons();


    List<DropdownMenuItem> _jobTypeMenuItems = new List();
    List<DropdownMenuItem> _jobStageMenuItems = new List();
    List<DropdownMenuItem> billingInfoItem = new List();
    List<DropdownMenuItem> jobPaymentItem = new List();
    List<DropdownMenuItem> accessoryItem = new List();
    List<DropdownMenuItem> jobTimeFrameItem = new List();
    List<DropdownMenuItem> vehicleDropDownItems = new List();


    vehicleDropDownItems.add(DropdownMenuItem(child: new Text("Select a Vehicle", textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,), value: "") );
    if ( vehicleItems.length == 0 && _selectedVehicle.length > 0 ){
      vehicleDropDownItems.add(DropdownMenuItem(child: new Text(
        _selectedVehicleText, textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,), value: _selectedVehicle));
    }
    else {
      for (var i = 0; i < vehicleItems.length; i++) {
        vehicleDropDownItems.add(DropdownMenuItem(child: new Text(
          vehicleItems[i].text, textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,), value: vehicleItems[i].id));
      }
    }

    var textNotificationCallback;
    bool enableControls = false;
    if ( pageMode > 0 )
    {
      enableControls = true;

      if ( Global.userAccess != "4" ) // Check User is not Installer
      {
        textNotificationCallback = (bool value) {
          setState(() {
            _isTextNotification = value;
          });
        };
      }

      _jobTypeMenuItems.add(DropdownMenuItem(child: new Text("Select one...", textAlign: TextAlign.center,), value: "") );
      for(var i=0;i<jobTypeItems.length;i++){
        _jobTypeMenuItems.add(DropdownMenuItem(child: new Text(jobTypeItems[i].text, textAlign: TextAlign.center,), value: jobTypeItems[i].id) );
      }

      _jobStageMenuItems.add(DropdownMenuItem(child: new Text("Select one...", textAlign: TextAlign.center,), value: "") );
      for(var i=0;i<jobStageItems.length;i++){
        _jobStageMenuItems.add(DropdownMenuItem(child: new Text(jobStageItems[i].text, textAlign: TextAlign.center,), value: jobStageItems[i].id) );
      }


      billingInfoItem.add(DropdownMenuItem(child: new Text("Select a billing option...", textAlign: TextAlign.center,), value: "") );
      billingInfoItem.add(DropdownMenuItem(child: new Text("Auto Glass Only", textAlign: TextAlign.center,), value: "Auto Glass Only") );
      billingInfoItem.add(DropdownMenuItem(child: new Text("CASH/CC", textAlign: TextAlign.center,), value: "CASH/CC") );
      billingInfoItem.add(DropdownMenuItem(child: new Text("Insurance", textAlign: TextAlign.center,), value: "Insurance") );
      billingInfoItem.add(DropdownMenuItem(child: new Text("Gerber", textAlign: TextAlign.center,), value: "Gerber") );
      billingInfoItem.add(DropdownMenuItem(child: new Text("Strategic Claims", textAlign: TextAlign.center,), value: "Strategic Claims") );

      jobPaymentItem.add(DropdownMenuItem(child: new Text("Unpaid", textAlign: TextAlign.center,), value: "0") );
      jobPaymentItem.add(DropdownMenuItem(child: new Text("Paid in Full", textAlign: TextAlign.center,), value: "1") );


      accessoryItem.add(DropdownMenuItem(child: new Text("Select...", textAlign: TextAlign.center,), value: "") );
      accessoryItem.add(DropdownMenuItem(child: new Text("Rain Sensor Pad", textAlign: TextAlign.center,), value: "rain_sensor_pad") );
      accessoryItem.add(DropdownMenuItem(child: new Text("Molding", textAlign: TextAlign.center,), value: "molding") );
      accessoryItem.add(DropdownMenuItem(child: new Text("Clips", textAlign: TextAlign.center,), value: "clips") );


      jobTimeFrameItem.add(DropdownMenuItem(child: new Text("Select hourly window...", textAlign: TextAlign.center,), value: "") );
      jobTimeFrameItem.add(DropdownMenuItem(child: new Text("9-12", textAlign: TextAlign.center,), value: "9-12") );
      jobTimeFrameItem.add(DropdownMenuItem(child: new Text("12-3", textAlign: TextAlign.center,), value: "12-3") );
      jobTimeFrameItem.add(DropdownMenuItem(child: new Text("3-6", textAlign: TextAlign.center,), value: "3-6") );
    }

    var fbody = Builder(builder: (BuildContext context) {
      _scaffoldContext = context;

      if (_dataLoaded && !_hasError) {
        List<Widget> accessoryWidget = [];
        for(var i=0;i<accessory_part_type.length;i++)
        {
          if ( accessory_part_type[i] == "rain_sensor_pad" )
          {
            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Rain Sensor Pad Part Number", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)
                ),
              )
            );
            accessoryWidget.add(
              pageMode==0?Text(accessory_part_number_controllers[i].text):
              TextField(
                controller: accessory_part_number_controllers[i],
                enabled: enableControls,
                autocorrect: false,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                  border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                          const Radius.circular(0.0)
                      ),
                      borderSide: const BorderSide(color: color_border, width: 1.0)
                  ),
                  hintText: '',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              )
            );

            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Rain Sensor Pad Cost", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)
                ),
              )

            );
            accessoryWidget.add(
                pageMode==0?Text(accessory_cost_controllers[i].text):
                TextField(
                  controller: accessory_cost_controllers[i],
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
            );
          }
          else if ( accessory_part_type[i] == "molding" )
          {
            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Molding Part Number", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)
                ),
              )

            );
            accessoryWidget.add(
                pageMode==0?Text(accessory_part_number_controllers[i].text):
                TextField(
                  controller: accessory_part_number_controllers[i],
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
            );

            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Molding Cost", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)
                ),
              )
            );
            accessoryWidget.add(
                pageMode==0?Text(accessory_cost_controllers[i].text):
                TextField(
                  controller: accessory_cost_controllers[i],
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
            );
          }
          else if ( accessory_part_type[i] == "clips" ){
            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Clips Part Number", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)),
              )
            );
            accessoryWidget.add(
                pageMode==0?Text(accessory_part_number_controllers[i].text):
                TextField(
                  controller: accessory_part_number_controllers[i],
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
            );

            accessoryWidget.add(
              Padding(
                padding: EdgeInsets.only(top:10),
                child: Text("Clips Cost", style: TextStyle(
                  color: colorSubHeader,
                  fontSize: 16,)),
              )
            );
            accessoryWidget.add(
                pageMode==0?Text(accessory_cost_controllers[i].text):
                TextField(
                  controller: accessory_cost_controllers[i],
                  enabled: enableControls,
                  autocorrect: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0)
                        ),
                        borderSide: const BorderSide(color: color_border, width: 1.0)
                    ),
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
            );
          }
        }

        var formatter = new DateFormat('MMM dd yyyy');
        DateTime tmpJobDate = null;
        try {
          tmpJobDate = formatter.parse(_selectedJobDate);
        }catch(err){
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // Sales Person
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
                        "Salesperson",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?selectedSalesPerson==null?Text(""):Text(selectedSalesPerson.text):
                    textFieldSalesperson,
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 15),
                child: Center(
                  child: Text("Customer / Job Info ", style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                )
              ),

              // Job Type
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
                        "Job Type *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_selectedJobTypeLabel):
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
                        value: _selectedJobType,
                        items: _jobTypeMenuItems,
                        onChanged: (newValue){
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            _selectedJobType = newValue;
                            for(var i=0; i <jobTypeItems.length; i++){
                              if ( jobTypeItems[i].id == newValue ){
                                _selectedJobTypeLabel = jobTypeItems[i].text;
                              }
                            }
                          });
                        }
                      ),
                    ),

                  ],
                ),
              ),

              // Job Stage
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
                        "Job Stage *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_selectedJobStageLabel):
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
                          value: _selectedJobStage,
                          items: _jobStageMenuItems,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedJobStage = newValue;

                              for(var i=0; i <jobStageItems.length; i++){
                                if ( jobStageItems[i].id == newValue ){
                                  _selectedJobStageLabel = jobStageItems[i].text;
                                }
                              }
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Customer
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
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex:3,
                            child: Text(
                              "Customer *",
                              style: TextStyle(
                                color: colorSubHeader,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          pageMode==0?Text(""):
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: (){
                                  showCustomerCreatePage();
                                },
                                child: Text("[+]", style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                          ),
                          pageMode==0?Text(""):
                          Expanded(
                            flex:5,
                            child: GestureDetector(
                                onTap: (){
                                  showCustomerSearch();
                                },
                                child: Text("Choose a Customer", style: TextStyle(decoration: TextDecoration.underline))
                            ),
                          )

                        ],
                      )
                    ),


                    selectedCustomer!=null?
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(selectedCustomer.name, style:TextStyle(fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: (){
                                launch("tel:${selectedCustomer.phone}");
                              },
                              child: Text(
                                "(" + selectedCustomer.phone + ")",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                )
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap:(){
                            MapUtils.openMapAddress(selectedCustomer.address1 + " " + selectedCustomer.city + " " + selectedCustomer.state + " " + selectedCustomer.zip );
                          },
                          child: Text(selectedCustomer.address1 + "\n" + selectedCustomer.city + " " + selectedCustomer.state + " " + selectedCustomer.zip,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              )
                          )
                        ),
                        Text(selectedCustomer.email)
                      ],
                    )
                    :
                    Text("")
                  ],
                ),
              ),

              // Vehicle
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
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Vehicle *",
                            style: TextStyle(
                              color: colorSubHeader,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width:5),
                          selectedCustomer==null||pageMode==0?Text(""):
                          GestureDetector(
                            onTap: (){
                              showCreateVehicleView();
                            },
                            child: Text("[+]", style: TextStyle(fontWeight: FontWeight.bold))
                          )
                        ]
                      )
                    ),
                    pageMode==0?Text(_selectedVehicleText):
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
                          value: _selectedVehicle,
                          items: vehicleDropDownItems,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedVehicle = newValue;
                              for(var i=0;i<vehicleItems.length;i++){
                                if ( vehicleItems[i].id == newValue ){
                                  _selectedVehicleText = vehicleItems[i].text;
                                  break;
                                }
                              }
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Billing Info
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
                        "Billing Info",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_selectedBillingInfo):
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
                          value: _selectedBillingInfo,
                          items: billingInfoItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedBillingInfo = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Cash/CC Paid
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
                        "Cash/CC Paid",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_cashController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _cashController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: 'If applicable',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: cashFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(deductibleFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Deductible
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
                        "Deductible",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_deductibleController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _deductibleController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: deductibleFocusNode,
                        onSubmitted: (newValue) {
                          //FocusScope.of(context).requestFocus(notesFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Job Payment Status
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
                        "Job Payment Status",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?_selectedJobPaymentStatus=="0"?Text("Unpaid"):Text("Paid in Full"):
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
                          value: _selectedJobPaymentStatus,
                          items: jobPaymentItem,
                          onChanged: (newValue){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedJobPaymentStatus = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Total Due
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
                        "Total Due",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_totalDueController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _totalDueController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: totalDueFocusNode,
                        onSubmitted: (newValue) {
                          //FocusScope.of(context).requestFocus(notesFocusNode);
                        }
                    ),
                  ],
                ),
              ),


              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Center(
                      child: Text("Distributor / Order Info", style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  )
              ),


              // Website Order / Dispatch #
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
                        "Website Order / Dispatch #",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_dispatchController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _dispatchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: dispatchFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(distributorOrderNumberFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Distributor
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
                        "Distributor *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?selectedDistributor!=null?Text(selectedDistributor.text):Text(""):
                    Container(
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: textFieldDistributor,
                            ),
                            IconButton(
                                icon: Icon(Icons.search, color: Colors.blueAccent),
                                onPressed: (){
                                  if ( _isDistributorSearching ){
                                    _distributorSearchKeyLater = textFieldDistributor.textField.controller.text;
                                  }
                                  else {
                                    distributorSuggestions.clear();
                                    textFieldDistributor.updateSuggestions(distributorSuggestions);
                                    searchDistributor(textFieldDistributor.textField.controller.text);
                                  }

                                }
                            )
                          ],
                        )
                    ),
                  ],
                ),
              ),

              // Distributor Order Number
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
                        "Distributor Order Number",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_distributorOrderNumberController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _distributorOrderNumberController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: distributorOrderNumberFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(partNumberFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Part Number
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
                        "Part Number",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_partNumberController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _partNumberController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: partNumberFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(dealerPartNumberFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Dealer Part Number
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
                        "Dealer Part Number",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_dealerPartNumberController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _dealerPartNumberController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: dealerPartNumberFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(glassOrderDateFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Glass Order Date
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
                        "Glass Order Date",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_glassOrderDateController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _glassOrderDateController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: 'Date when glass order was placed',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: glassOrderDateFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(glassArrivalDateFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Glass Arrival Date
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
                        "Glass Arrival Date",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_glassArrivalDateController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _glassArrivalDateController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: 'Estimated arrival',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: glassArrivalDateFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(glassCostFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Glass Cost
              Global.userAccess=="4"?Container():
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
                        "Glass Cost",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_glassCostController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _glassCostController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: glassCostFocusNode,
                        onSubmitted: (newValue) {
                          //FocusScope.of(context).requestFocus(notesFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Delivery Cost
              Global.userAccess=="4"?Container():
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
                        "Delivery Cost",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_deliveryCostController.text):
                    TextField(
                        enabled: enableControls,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.text,
                        controller: _deliveryCostController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0)
                              ),
                              borderSide: const BorderSide(color: color_border, width: 1.0)
                          ),
                          hintText: '',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        focusNode: deliveryCostFocusNode,
                        onSubmitted: (newValue) {
                          FocusScope.of(context).requestFocus(getInstallerByZipFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              // Add an Accessory
              pageMode==0?Container():
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
                        "Add an Accessory",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
                          value: _selectedAccessory,
                          items: accessoryItem,
                          onChanged: (newValue){
                            if ( newValue.toString().length > 0 ){
                              accessory_part_type.add(newValue);
                              TextEditingController partNumberController = new TextEditingController();
                              TextEditingController costController = new TextEditingController();

                              accessory_part_number_controllers.add(partNumberController);
                              accessory_cost_controllers.add(costController);
                            }

                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              _selectedAccessory = newValue;
                            });
                          }
                      ),
                    ),

                  ],
                ),
              ),

              // Accessories
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: accessoryWidget
                )
              ),



              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Center(
                      child: Text("Installation Details", style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  )
              ),

              // Installer *
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
                        "Installer *",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?selectedInstaller!=null?Text(selectedInstaller.text):Text(""):
                    Container(
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: textFieldInstaller,
                            ),
                            IconButton(
                                icon: Icon(Icons.search, color: Colors.blueAccent),
                                onPressed: (){
                                  if ( _isInstallerSearching ){
                                    _installerSearchKeyLater = textFieldInstaller.textField.controller.text;
                                  }
                                  else {
                                    installerSuggestions.clear();
                                    textFieldInstaller.updateSuggestions(installerSuggestions);
                                    searchInstaller(textFieldInstaller.textField.controller.text);
                                  }

                                }
                            )
                          ],
                        )
                    ),
                  ],
                ),
              ),


              // Get Installer by Zip
              pageMode==0?Container():
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
                        "Get Installer by Zip",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child:TextField(
                              enabled: enableControls,
                              autocorrect: false,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              keyboardType: TextInputType.text,
                              controller: _getInstallerByZipController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                                border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        const Radius.circular(0.0)
                                    ),
                                    borderSide: const BorderSide(color: color_border, width: 1.0)
                                ),
                                hintText: '',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),

                              focusNode: getInstallerByZipFocusNode,
                              onSubmitted: (newValue) {
                                FocusScope.of(context).requestFocus(noteFocusNode);
                              }
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.blueAccent),
                            onPressed: (){
                              textFieldInstaller.textField.controller.text = "";

                              if ( _isInstallerSearching ){
                                _installerSearchKeyLater = _getInstallerByZipController.text;
                              }
                              else {
                                searchInstaller(_getInstallerByZipController.text);
                              }

                            }
                          )
                        ],
                      )
                    ),


                  ],
                ),
              ),

              // Job Date
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
                        "Job Date",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_selectedJobDate):
                    new DateTimePickerFormField(
                      controller: _jobDateController,
                      initialValue: tmpJobDate,
                      inputType: InputType.date,
                      format: DateFormat("MMM dd yyyy"),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          labelText: 'Date/Time', hasFloatingPlaceholder: false
                      ),
                      focusNode: jobDateFocusNode,
                      onChanged:(dt){
                        if ( dt == null ){
                        }
                        else {
                          var formatter = new DateFormat('MMM dd yyyy');
                          String formatted = formatter.format(dt);
                          _selectedJobDate = formatted;
                        }
                        print("on changed=" + _selectedJobDate);
                      },
                    )
                    

                  ],
                ),
              ),

              // Job Time Frame
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
                        "Job Time Frame",
                        style: TextStyle(
                          color: colorSubHeader,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pageMode==0?Text(_timeFrameController.text):
                    TextField(
                      enabled: enableControls,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      keyboardType: TextInputType.text,
                      controller: _timeFrameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(0.0)
                            ),
                            borderSide: const BorderSide(color: color_border, width: 1.0)
                        ),
                        hintText: 'Time frame format ex. 8am-10am',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (newValue) {
                        //FocusScope.of(context).requestFocus(notesFocusNode);
                      }
                  ),

                  ],
                ),
              ),

              // Do not send customer notifications
              Global.userAccess == "4" ? Container():
              Container(
                margin: const EdgeInsets.only(left:10.0, right:0.0, top:0.0, bottom:0.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: _isTextNotification,
                        onChanged: textNotificationCallback,
                      ),
                      Expanded(
                        child: Text("Do not send customer text notifications",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0
                            )
                        )
                      )
                    ]
                ),
              ),

              Container(
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:10.0),
                child:Column(
                  children: _buildNotes(),
                ),
              ),

              // Add Note
              pageMode==0?Container():
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0),
                ),
                margin: const EdgeInsets.only(left:20.0, right:20.0, top:0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:0),
                      child: Text(
                        "Add Note",
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
                        maxLines: 5,
                        maxLength: 800,
                        controller: _noteController,
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
                        focusNode: noteFocusNode,
                        onSubmitted: (newValue) {
                          //FocusScope.of(context).requestFocus(payRateFocusNode);
                        }
                    ),
                  ],
                ),
              ),

              pageMode==2?Container():
              _buildPhotoRow(),

              pageMode==2?Container():
              _buildDivider(),

              pageMode==2?Container():
              _buildSignatureRow(),

              pageMode==2?Container():
              _buildDivider(),

              pageMode==2?Container():
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: RaisedButton(
                  child: isSubmitting ? _submittingWidget() : _sendTextWidget(),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: () {
                    if (isSubmitting) {
                      return null;
                    } else {
                      if (!isSignatureStarted ||
                          windshieldPhotoBytes.length == 0 ||
                          vinPhotoBytes.length == 0 ||
                          trimPhotoBytes.length == 0 ||
                          partNumberPhotoBytes.length == 0) {
                        return null;
                      } else {
                        isSubmitting = true;
                        setState(() {});
                        _saveJobDetails(context);
                      }
                    }
                  },
                  color: Colors.orangeAccent,
                ),
              ),

              SizedBox(height: 20,)

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

    executeAfterBuild();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        leading: GestureDetector(
            onTap: () {
              Map<String, dynamic> result;
              result = {
                "jobId": widget.jobId,
                "timeFrame": _savedTimeFrame
              };

              Navigator.pop(context, json.encode(result));
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )
        ),
        backgroundColor: Colors.white,
        title: appTitle,
        brightness: Brightness.light,
        centerTitle: true,
        actions: ActionButtons
      ),
      body: fbody
    );

  }

  Future<void> executeAfterBuild() async {
    if ( pageMode > 0 ) {
      if ( textFieldSalesperson.key.currentState == null || textFieldInstaller.key.currentState == null || textFieldDistributor.key.currentState == null ){
        Future.delayed(Duration(microseconds: 500), (){
          executeAfterBuild();
        });
        return;
      }

      if ( autocompleteFirst ) {
        if ( selectedSalesPerson != null ){
          textFieldSalesperson.textField.controller.text = selectedSalesPerson.text;
        }

        if (selectedDistributor != null) {
          textFieldDistributor.textField.controller.text = selectedDistributor.text;
        }

        if ( selectedInstaller != null ){
          textFieldInstaller.textField.controller.text = selectedInstaller.text;
        }

        autocompleteFirst = false;
      }
    }
  }
}

enum PhotoSelected { Windshield, PartNumber, VIN, TrimName }
