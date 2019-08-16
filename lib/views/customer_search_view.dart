import 'dart:async';
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/distributor_list_item.dart';
import 'package:auto_glass_crm/services/job_service.dart';
import 'package:auto_glass_crm/views/distributor_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:string_mask/string_mask.dart';

import 'package:intl/intl.dart';

class CustomerSearchView extends StatefulWidget {
  _CustomerSearchViewState state;
  @override
  _CustomerSearchViewState createState() {
    state = new _CustomerSearchViewState();
    return state;
  }
}

class CustomerSearchItem {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  String id;
  String name;
  String phone;
  String email;
  String address1;
  String city;
  String state;
  String zip;

  CustomerSearchItem(this.id);
}

class _CustomerSearchViewState extends State<CustomerSearchView> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext _scaffoldContext;

  bool _isSearched = false;
  bool _isSearching = false;

  List<CustomerSearchItem> _customers = new List<CustomerSearchItem>();
  int _selectedCustomerId = 0;

  var unescape = new HtmlUnescape();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode zipFocus = FocusNode();

  TextEditingController _firstNameController = new TextEditingController(text: "");
  TextEditingController _lastNameController = new TextEditingController(text: "");
  TextEditingController _phoneController = new TextEditingController(text: "");
  TextEditingController _zipController = new TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  /* Search Customers */
  void searchData() async {
    var firstName = _firstNameController.text.trim();
    var lastName = _lastNameController.text.trim();
    var phoneNumber = _phoneController.text.trim();
    var zip = _zipController.text.trim();

    _customers.clear();
    var response = await JobService.searchCustomers(firstName, lastName, phoneNumber, zip );

    if ( response != null ){
        if ( response is List<dynamic> ){
          for (var i = 0; i < response.length; i++) {
            CustomerSearchItem item = new CustomerSearchItem(response[i]['id']);
            item.name =
                response[i]['first_name'] + " " + response[i]['last_name'];
            item.address1 = response[i]['address1'];
            item.email = response[i]['email'];
            item.phone = response[i]['phone'];
            item.city = response[i]['city'];
            item.state = response[i]['state'];
            item.zip = response[i]['zip'];

            if (item.email == null) {
              item.email = "";
            }

            _customers.add(item);
          }
        }
        else if ( response.containsKey("success") && response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
          Global.asyncAlertDialog(context, response['message']);

          setState(() {
            _isSearched = false;
            _isSearching = false;
          });
          return;

        }


    }

    if ( this.mounted ){
      setState(() {
        _isSearched = true;
        _isSearching = false;
      });
    }
  }

  _buildActionButtons(){
    var ActionButtons = <Widget>[];
    if ( _selectedCustomerId > 0 && _isSearching == false && _isSearched == true) {
      ActionButtons.add(new IconButton(
        icon: const Icon(Icons.check, color: Colors.black),
        onPressed: () {
          setState(() {
            Map<String, dynamic> result;
            for( var i=0;i<_customers.length;i++){
              if ( _customers[i].id == _selectedCustomerId.toString() ){
                result = {
                  "customer_id": _customers[i].id,
                  "name": _customers[i].name,
                  "phone": _customers[i].phone,
                  "email": _customers[i].email,
                  "address1": _customers[i].address1,
                  "city": _customers[i].city,
                  "state": _customers[i].state,
                  "zip": _customers[i].zip,
                };
                break;
              }
            }
            Navigator.pop(context, json.encode(result));
          });
        },
      ));
    }
    return ActionButtons;
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


  @override
  Widget build(BuildContext context) {
    const Color color_border = Color(0x30A4C6EB);
    const Color colorSubHeader = Color(0xFF7D90B7);

    FutureBuilder fbBody = new FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        _scaffoldContext = context;

        if ( _isSearched && _isSearching == false ){
          var children = List<Widget>();

          children.add(
            Padding(
              padding: EdgeInsets.only(left:10, right:10, top:10, bottom:5),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Text(_customers.length>0?"Choose a Customer":"No Result",
                        style:TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                        )
                    )
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap:(){
                        setState(() {
                          _isSearching = false;
                          _isSearched = false;
                          _selectedCustomerId = 0;
                          _customers.clear();

                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "back",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepOrangeAccent,
                              decoration: TextDecoration.underline
                          ),
                        )
                      )
                    ),
                  )



                ],
              ),
            )
          );

          for(var i=0;i<_customers.length;i++){
            Icon leadingIcon = Icon(Icons.check_circle_outline);
            if ( _selectedCustomerId.toString() == _customers[i].id ){
              leadingIcon = Icon(Icons.check_circle);
            }
            children.add(
              Container(
                color: Colors.black12,
                child: ListTile(
                    title: Text(_customers[i].name),
                    leading: leadingIcon,
                    onTap: (){
                      _selectedCustomerId = int.parse(_customers[i].id);
                      setState(() {
                      });
                    },
                )
              )
            );
          }
          return ListView(children: children);
        }
        else if ( _isSearching ){
          return ListView(children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBodySkeleton(0.7),
                  _buildBodySkeleton(0.65),
                  _buildBodySkeleton(0.60),
                  _buildBodySkeleton(0.55),
                  _buildBodySkeleton(0.50),
                  _buildBodySkeleton(0.45),
                  _buildBodySkeleton(0.40),
                ],
              ),
            ),
          ]);
        }
        else {
          return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    // First Name
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0),
                      ),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "First Name *",
                              style: TextStyle(
                                color: colorSubHeader,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          TextField(
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.text,
                            controller: _firstNameController,
                            focusNode: firstNameFocus,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0)
                                  ),
                                  borderSide: const BorderSide(
                                      color: color_border, width: 1.0)
                              ),
                              hintText: 'Enter First Name',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: (newValue) {
                              FocusScope.of(context).requestFocus(lastNameFocus);
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
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Last Name *",
                              style: TextStyle(
                                color: colorSubHeader,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          TextField(
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.text,
                            controller: _lastNameController,
                            focusNode: lastNameFocus,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0)
                                  ),
                                  borderSide: const BorderSide(
                                      color: color_border, width: 1.0)
                              ),
                              hintText: 'Enter Last Name',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: (newValue) {
                              FocusScope.of(context).requestFocus(phoneFocus);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Phone Number
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0),
                      ),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Phone Number",
                              style: TextStyle(
                                color: colorSubHeader,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          TextField(
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                            focusNode: phoneFocus,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0)
                                  ),
                                  borderSide: const BorderSide(
                                      color: color_border, width: 1.0)
                              ),
                              hintText: 'Enter Phone Number',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: (newValue) {
                              FocusScope.of(context).requestFocus(zipFocus);
                            },
                          ),
                        ],
                      ),
                    ),


                    // Zip
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0),
                      ),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Zip",
                              style: TextStyle(
                                color: colorSubHeader,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          TextField(
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.number,
                            controller: _zipController,
                            focusNode: zipFocus,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 4.0, bottom: 3.0, top: 3.0, right: 4.0),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0)
                                  ),
                                  borderSide: const BorderSide(
                                      color: color_border, width: 1.0)
                              ),
                              hintText: 'Enter Zip',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: (newValue) {

                            },
                          ),
                        ],
                      ),
                    ),

                    // Search Button
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
                                    child: Text(
                                      "Search",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                ),
                                onPressed: () {
                                  if (_isSearching == false) {
                                    _isSearched = false;
                                    _isSearching = true;
                                    setState(() {
                                    });
                                    searchData();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),


                  ]
              )
          );
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
            title: Text("Search Customer", style: TextStyle(color: Colors.black)),
            brightness: Brightness.light,
            centerTitle: true,
            actions: _buildActionButtons()
        ),
        body: fbBody
    );

  }
}
