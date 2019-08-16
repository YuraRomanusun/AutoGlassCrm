import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/vindecoder.dart';
import 'package:auto_glass_crm/services/vindecoder_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JobTypeDropDownItem{
  String id;
  String text;
  JobTypeDropDownItem(this.id, this.text);
}

class VindecoderView extends StatefulWidget {
  _VindecoderViewState state;
  @override
  _VindecoderViewState createState() {
    state = new _VindecoderViewState();
    return state;
  }
}

class _VindecoderViewState extends State<VindecoderView> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _dataLoaded = false;
  bool  _isLoading = false;
  bool _hasError = false;

  Color color_bg = Color(0xFFCCCCCC);
  VindecoderData _vindecoder = new VindecoderData();

  String topAlertText = "";
  String _searchKey = "";
  String _errorMsg = "";

  bool _isSendingHelpRequest = false;
  bool _isSentHelpRequest = false;
  bool _hasHelpRequestError = false;

  List<JobTypeDropDownItem> jobTypeItems = new List();
  String _selectedJobType = "4";

  @override
  void initState() {
    super.initState();

    jobTypeItems.add(JobTypeDropDownItem("1", "Back Glass"));
    jobTypeItems.add(JobTypeDropDownItem("2", "Door Glass"));
    jobTypeItems.add(JobTypeDropDownItem("21", "Partition Glass"));
    jobTypeItems.add(JobTypeDropDownItem("3", "Quarter Glass"));
    jobTypeItems.add(JobTypeDropDownItem("19", "Roof Glass"));
    jobTypeItems.add(JobTypeDropDownItem("20", "Side Glass"));
    jobTypeItems.add(JobTypeDropDownItem("22", "Vent Glass"));
    jobTypeItems.add(JobTypeDropDownItem("4", "Windshield Glass"));
    //loadData("JF2SJAGC4HH511141");
  }

  Future<VindecoderData> loadData(s) async {
    if ( _isSendingHelpRequest ){
      return null;
    }
    _isLoading = true;
    _dataLoaded = false;
    topAlertText = "";
    _hasHelpRequestError = false;
    _isSentHelpRequest = false;
    setState(() {});

    _vindecoder = null;
    var response = await VindecoderService.getVindecoder(s);

    if ( response == null){
      _errorMsg = "No results for this search";
    }
    else if ( response == "error"){
      _errorMsg = "Error has occurred";
    }else{
      if ( response.containsKey("success") && response["success"] == 0 ){
        Global.checkResponse(context, response["message"]);
      }
      else if ( response.containsKey("error") ) {
        _vindecoder = VindecoderData.fromJson(response);
        topAlertText = response["error"];
      }
      else{
        _vindecoder = VindecoderData.fromJson(response);

        if ( _vindecoder == null ){
          _errorMsg = "Error has occurred";
        }
      }
    }

    _isLoading = false;
    if (_vindecoder != null ) {
      _searchKey = s;

      bool showMessage = false;

      if ( _vindecoder != null ) {

        var windShieldCount = 0;
        for (var i = 0; i < _vindecoder.parts.length; i++) {
            if ( _vindecoder.parts[i].glass_type_id == "1" ){
              windShieldCount++;
            }
        }
        if ( windShieldCount > 1 ){
          showMessage = true;
        }
      }

      if ( showMessage && topAlertText == ""){
        topAlertText = "This VIN number has multiple windshield options, ask customer which trim they have, or description of windshield";
      }

      _hasError = false;
    } else {
      _hasError = true;
    }





    _dataLoaded = true;
    if ( this.mounted ) {
      setState(() {});
    }

    return _vindecoder;
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

  sendHelpRequest() async{
    if ( _isSendingHelpRequest || _vindecoder == null ){
      return;
    }

    _isSendingHelpRequest = true;
    _isSentHelpRequest = false;
    _hasHelpRequestError = false;

    setState(() {});

    String ret = await VindecoderService.sendHelpRequest(Global.userID, _searchKey, _vindecoder.searchid, _selectedJobType);
    if ( ret != null ){
      if ( ret == "true" ) {
        _hasHelpRequestError = false;
      }
      else{
        _hasHelpRequestError = true;
      }
    }

    _isSentHelpRequest = true;
    _isSendingHelpRequest = false;
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

  _buildTrims(){
    List<Widget> trimsWidget = new List();

    if ( _vindecoder != null )
    {
      if ( _vindecoder.parts.length == 0 ){
        trimsWidget.add(
            Container(
              child: Center(
                child: Text("Sorry, no validated results for your search",
                textAlign: TextAlign.center,)
              )
            )
        );
      }
      for (var i = 0; i < _vindecoder.parts.length; i++){
        var part = _vindecoder.parts[i];
        //List<DropdownMenuItem> _glassOptions = new List();
        String trim_seris = "";
        String glass = "";
        String part_number = "";
        String count = "";
        String description = "";

        String dealerPartNum = "";
        String accessories = "";

        if ( (part.trim != null && part.trim.length > 0) && (part.series != null && part.series.length > 0) ){
          trim_seris = part.trim + "/" + part.series;
        }
        else if ( part.trim != null && part.trim.length > 0 ){
          trim_seris = part.trim;
        }
        else if ( part.series != null && part.series.length > 0 ){
          trim_seris = part.series;
        }

        if ( part.glass != null ){
          glass = part.glass;
        }

        if ( part.part_number != null ){
          part_number = part.part_number;
        }

        if ( part.count != null ){
          count = part.count;
        }

        if ( part.description != null ){
          description = part.description;
        }

        if ( part.dealer_part_nums != null ){
          for( var j=0; j<part.dealer_part_nums.length;j++){
            if ( dealerPartNum == "" ){
              dealerPartNum = part.dealer_part_nums[j];
            }
            else{
              dealerPartNum += "\n" + part.dealer_part_nums[j];
            }
          }
        }

        if ( part.accessories != null ){
          for( var j=0; j<part.accessories.length;j++){
            if ( part.accessories[j].part_number != null && part.accessories[j].type != null ) {
              var tmp = part.accessories[j].part_number + "(" +
                  part.accessories[j].type + ")";
              if (accessories == "") {
                accessories = tmp;
              }
              else {
                accessories += "\n" + tmp;
              }
            }
          }
        }

        /*
        for (var j = 0; j < part.parts.length; j++) {
          _glassOptions.add(
              DropdownMenuItem(
                  child: new Text(trim.parts[j].glass,
                    textAlign: TextAlign.center,),
                  value: trim.parts[j].glass_type_id
              )
          );
        }
        */
        trimsWidget.add(
            Container(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                        children: <Widget>[
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Trim/Series',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          top: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(trim_seris,
                                        textAlign: TextAlign.start,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Glass Type',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(glass,
                                        textAlign: TextAlign.justify,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Part #',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(part_number,
                                        textAlign: TextAlign.justify,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /* Part # */
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Times Used',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(count,
                                        textAlign: TextAlign.start,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Description',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(description,
                                        textAlign: TextAlign.start,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),


                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Dealer Part #',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(

                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(dealerPartNum,
                                        textAlign: TextAlign.start,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),


                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text('Accessories',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color_bg,
                                        border: Border(
                                          right: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                          bottom: BorderSide(width: 1.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      child: Text(accessories,
                                        textAlign: TextAlign.left,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          )


                        ]
                    )
                )
            )
        );
      }
    }

    /*
    trimsWidget.add(
        Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: Center(
                child: Text(
                    _vindecoder.type == "aggregate"?
                    "These parts have been used for AutoGlassCRM jobs on vehicles of this year, make, model, and body. The correct part may vary depending on trim or other features. If you need help narrowing it down, click the button below for assistance from Vindecoder staff!":
                    "These parts have been verified as matching vehicles of this year, make, model, and body. The correct part may vary depending on trim or other features. If you need help narrowing it down, click the button below for assistance from Vindecoder staff!",
                    style: TextStyle(

                    )
                )
            )
        )
    );
    */

    List<DropdownMenuItem> _jobTypeMenuItems = new List();
    for(var i=0;i<jobTypeItems.length;i++){
      _jobTypeMenuItems.add(DropdownMenuItem(child: new Text(jobTypeItems[i].text, textAlign: TextAlign.center,), value: jobTypeItems[i].id) );
    }

    trimsWidget.add(
      SizedBox(height: 20.0)
    );

    trimsWidget.add(
      Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child:DropdownButton(
            isDense: true,
            isExpanded: true,
            value: _selectedJobType,
            items: _jobTypeMenuItems,
            onChanged: (newValue){
              setState(() {
                _selectedJobType = newValue;
              });
            }
        ),
      ),
    );

    trimsWidget.add(
        Container(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: MaterialButton(
                    color: Color(0xFF027BFF),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          _isSendingHelpRequest?
                          "Sending...":
                          "Tell me the right part number",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                    ),
                    onPressed: () {
                      sendHelpRequest();
                    }),
              ),
            ],
          ),
        )
    );

    if ( _isSentHelpRequest == true ) {
      trimsWidget.add(
          Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: Center(
                  child: Text(
                      _hasHelpRequestError==true?
                      "We're sorry.  We couldn't send your request.  Please try again!":
                      "Request submitted! Once we've checked on this VIN search for you, you will be notified by push notification (if you've enabled them) or email.",
                      style: TextStyle(
                      )
                  )
              )
          )
      );
    }
    return trimsWidget;
  }


  @override
  Widget build(BuildContext context) {
    FutureBuilder fbBody = new FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {


          if (_dataLoaded && !_hasError) {
            List<Widget> trimsWidget = _buildTrims();
            return ListView(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top:10, bottom: 0, left:10, right:10),
                      child:Center(
                          child:Text(topAlertText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.red
                            ),
                          )
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(top:10, bottom: 0, left:10, right:10),
                      child:Center(
                          child:Text( "Vehicle Data for " + _searchKey,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          )
                      )
                  ),
                  Container(
                      child: GridView.count(
                        shrinkWrap: true,
                        primary: false,
                        padding: const EdgeInsets.all(10.0),
                        crossAxisSpacing: 0.0,
                        childAspectRatio: 1.1,
                        crossAxisCount: 5,
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.0, color: Colors.black54),
                                  left: BorderSide(width: 1.0, color: Colors.black54),
                                  bottom: BorderSide(width: 1.0, color: Colors.black54),
                                ),
                              ),
                              child: Center(
                                child: Text('Year',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.0, color: Colors.black54),
                                  left: BorderSide(width: 1.0, color: Colors.black54),
                                  bottom: BorderSide(width: 1.0, color: Colors.black54),
                                ),
                              ),
                              child: Center(
                                child: Text('Make',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.0, color: Colors.black54),
                                  left: BorderSide(width: 1.0, color: Colors.black54),
                                  bottom: BorderSide(width: 1.0, color: Colors.black54),
                                ),
                              ),
                              child: Center(
                                child: Text('Model',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.0, color: Colors.black54),
                                  left: BorderSide(width: 1.0, color: Colors.black54),
                                  bottom: BorderSide(width: 1.0, color: Colors.black54),
                                ),
                              ),
                              child: Center(
                                child: Text('Body',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1.0, color: Colors.black54),
                                  left: BorderSide(width: 1.0, color: Colors.black54),
                                  right: BorderSide(width: 1.0, color: Colors.black54),
                                  bottom: BorderSide(width: 1.0, color: Colors.black54),
                                ),
                              ),
                              child: Center(
                                child: Text('Trim/Series',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.black54),
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  ),
                                  color: color_bg
                              ),
                              child: Center(
                                child: Text(_vindecoder.year!=null?_vindecoder.year:"", textAlign: TextAlign.center),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.black54),
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  ),
                                  color: color_bg
                              ),
                              child: Center(
                                child: Text(_vindecoder.make!=null?_vindecoder.make:"", textAlign: TextAlign.center),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.black54),
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  ),
                                  color: color_bg
                              ),
                              child: Center(
                                child: Text(_vindecoder.model!=null?_vindecoder.model:"", textAlign: TextAlign.center),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.black54),
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  ),
                                  color: color_bg
                              ),
                              child: Center(
                                child: Text(_vindecoder.body!=null?_vindecoder.body:"", textAlign: TextAlign.center),
                              )
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.black54),
                                    right: BorderSide(width: 1.0, color: Colors.black54),
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  ),
                                  color: color_bg
                              ),
                              child: Center(
                                child: Text("", textAlign: TextAlign.center),
                              )
                          ),
                        ],
                      )
                  ),

                  Container(
                      padding: EdgeInsets.only(top:10, bottom: 0, left:10, right:10),
                      child:Center(
                          child:Text( "Matching Parts Records",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          )
                      )
                  ),
                  Column(
                      children: trimsWidget
                  ),
                ]
            );
          } else if (_dataLoaded && _hasError) {
            return Center(
              child: Text(
                _errorMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          } else if ( _isLoading ){
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
          else if ( _dataLoaded == false && _isLoading == false ){
            return Center(
              child: Text(
                "Please search for VIN/Dealer Part Number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );

          }
          else{
            return Center(
                child: Text("")
            );
          }
        });

    return SafeArea(
      child: fbBody,
    );
  }
}

