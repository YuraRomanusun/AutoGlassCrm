import 'dart:async';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/models/job_list_item.dart';
import 'package:auto_glass_crm/models/job_count_item.dart';
import 'package:auto_glass_crm/services/job_service.dart';
import 'package:auto_glass_crm/views/job_create_view.dart';
import 'package:auto_glass_crm/views/job_overview_view.dart';
import 'package:auto_glass_crm/views/home_page.dart';
import 'package:auto_glass_crm/views/vindecoder_view.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:string_mask/string_mask.dart';
import 'package:intl/intl.dart';

class JobListView extends StatefulWidget {
  _JobListViewState state;
  @override
  _JobListViewState createState(){
    state = new _JobListViewState();
    return state;
  }
}

class _JobListViewState extends State<JobListView> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String searchKey = "";
  bool _dataLoaded = false;
  bool _dataLoading = false;
  bool _isFirstLoad = true;

  bool _dataOverdueJobsLoading = false;
  bool _dataDueTodayJobsLoading = false;
  bool _dataDueTomorrowJobsLoading = false;
  bool _dataDueThisWeekJobsLoading = false;
  bool _dataDueNextWeekJobsLoading = false;
  bool _dataDueLaterJobsLoading = false;

  bool _dataOverdueJobsLoaded = false;
  bool _dataDueTodayJobsLoaded = false;
  bool _dataDueTomorrowJobsLoaded = false;
  bool _dataDueThisWeekJobsLoaded = false;
  bool _dataDueNextWeekJobsLoaded = false;
  bool _dataDueLaterJobsLoaded = false;

  JobCountItem _jobCount;
  HomePageState parent;

  List<JobListItem> _overdueJobs = new List<JobListItem>();
  List<JobListItem> _duetodayJobs = new List<JobListItem>();
  List<JobListItem> _duetomorrowJobs = new List<JobListItem>();
  List<JobListItem> _duethisweekJobs = new List<JobListItem>();
  List<JobListItem> _duenextweekJobs = new List<JobListItem>();
  List<JobListItem> _duelaterJobs = new List<JobListItem>();
  List<JobListItem> _completedJobs = new List<JobListItem>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /* Get Job List */
  void loadData() async {
    _dataLoaded = false;
    _dataLoading = true;


    _dataOverdueJobsLoading = false;
    _dataDueTodayJobsLoading = false;
    _dataDueTomorrowJobsLoading = false;
    _dataDueThisWeekJobsLoading = false;
    _dataDueNextWeekJobsLoading = false;
    _dataDueLaterJobsLoading = false;

    _dataOverdueJobsLoaded = false;
    _dataDueTodayJobsLoaded = false;
    _dataDueTomorrowJobsLoaded = false;
    _dataDueThisWeekJobsLoaded = false;
    _dataDueNextWeekJobsLoaded = false;
    _dataDueLaterJobsLoaded = false;

    if ( this.mounted ) {
      setState(() {});
    }

    var response = await JobService.getJobList("", searchKey);

    _jobCount = new JobCountItem();
    _jobCount.countOverdue = "0";
    _jobCount.countToday = "0";
    _jobCount.countTomorrow = "0";
    _jobCount.countThisWeek = "0";
    _jobCount.countNextWeek = "0";
    _jobCount.countLater = "0";



    /*
    var now = new DateTime.now().toUtc();
    var tomorrow = now.add(new Duration(days:1));

    var thisWeekFirstDay = now.subtract(new Duration(days:now.weekday, hours: now.hour, minutes: now.minute, seconds: now.second));
    var thisWeekLastDay = now;
    if ( now.weekday < 7 ) {
      thisWeekLastDay = now.add(new Duration(days: (7 - now.weekday)));
      thisWeekLastDay = thisWeekLastDay.subtract(new Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    }
    var nextWeekFirstDay = thisWeekFirstDay.add(new Duration(days:7));
    var nextWeekNowDay = now.add(new Duration(days:7));
    var nextWeekLastDay = thisWeekLastDay.add(new Duration(days:7));
    var formatter = new DateFormat('MMM d y');
    String formmatedNow = formatter.format(now);
    String formattedTomorrow = formatter.format(tomorrow);

    String formattedThisWeekFirstDay = formatter.format(thisWeekFirstDay);
    String formattedThisWeekLastDay = formatter.format(thisWeekLastDay);
    */

    if ( response != null && response['success'] != 0 )
    {
      _overdueJobs.clear();
      _duetodayJobs.clear();
      _duetomorrowJobs.clear();
      _duethisweekJobs.clear();
      _duenextweekJobs.clear();
      _duelaterJobs.clear();
      _completedJobs.clear();

      response['overdue'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _overdueJobs.add(item);
      });

      response['today'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _duetodayJobs.add(item);
      });

      response['tomorrow'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _duetomorrowJobs.add(item);
      });

      response['thisWeek'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _duethisweekJobs.add(item);
      });

      response['nextWeek'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _duenextweekJobs.add(item);
      });

      response['later'].forEach((o) {
        var item = JobListItem.fromJson(o);
        _duelaterJobs.add(item);
      });

      if (response.containsKey('counts') && response['counts'].containsKey('countLater') ) {
        print(response['counts']);
        _jobCount.countLater = response['counts']['countLater'];
        _jobCount.countNextWeek = response['counts']['countNextWeek'];
        _jobCount.countOverdue = response['counts']['countOverdue'];
        _jobCount.countThisWeek = response['counts']['countThisWeek'];
        _jobCount.countToday = response['counts']['countToday'];
        _jobCount.countTomorrow = response['counts']['countTomorrow'];
      }
      else{
        _jobCount.countOverdue = _overdueJobs.length.toString();
        _jobCount.countToday = _duetodayJobs.length.toString();
        _jobCount.countTomorrow = _duetomorrowJobs.length.toString();
        _jobCount.countThisWeek = _duethisweekJobs.length.toString();
        _jobCount.countNextWeek = _duenextweekJobs.length.toString();
        _jobCount.countLater = _duelaterJobs.length.toString();
      }

      _dataLoaded = true;
      _dataLoading = false;
    }
    else {
      if ( response != null && response['success'] == 0 ) {
        Global.checkResponse(context, response['message']);
      }
    }

    if ( int.parse(_jobCount.countOverdue) <= _overdueJobs.length ){
      _dataOverdueJobsLoaded = true;
    }
    else{
      _dataOverdueJobsLoaded = false;
    }

    if ( int.parse(_jobCount.countToday) <= _duetodayJobs.length ){
      _dataDueTodayJobsLoaded = true;
    }
    else{
      _dataDueTodayJobsLoaded = false;
    }

    if ( int.parse(_jobCount.countTomorrow) <= _duetomorrowJobs.length ){
      _dataDueTomorrowJobsLoaded = true;
    }
    else{
      _dataDueTomorrowJobsLoaded = false;
    }

    if ( int.parse(_jobCount.countThisWeek) <= _duethisweekJobs.length ){
      _dataDueThisWeekJobsLoaded = true;
    }
    else{
      _dataDueThisWeekJobsLoaded = false;
    }

    if ( int.parse(_jobCount.countNextWeek) <= _duenextweekJobs.length ){
      _dataDueNextWeekJobsLoaded = true;
    }
    else{
      _dataDueNextWeekJobsLoaded = false;
    }

    if ( int.parse(_jobCount.countLater) <= _duelaterJobs.length ){
      _dataDueLaterJobsLoaded = true;
    }
    else{
      _dataDueLaterJobsLoaded = false;
    }



    if ( this.mounted ) {
      setState(() {});
    }
  }

  /* Get Job List */
  getParticularJobs(String range) async {
    if ( range == "overdue" ) {
      var response = await JobService.getJobList(range, searchKey);

      if ( response != null && response['success'] == 1 ) {
        _overdueJobs.clear();
        if (response != null) {
          response['overdue'].forEach((o) {
            var item = JobListItem.fromJson(o);
            _overdueJobs.add(item);
          });
        }
      }
      else if ( response != null && response['success'] == 0 ){
        if ( response != null && response['success'] == 0 ) {
          Global.checkResponse(context, response['message']);
        }
      }

      if ( int.parse(_jobCount.countOverdue) <= _overdueJobs.length ){
        _dataOverdueJobsLoaded = true;
      }
      else{
        _dataOverdueJobsLoaded = false;
      }
      _dataOverdueJobsLoading = false;
    }
    else if ( range == "today" ) {
      var response = await JobService.getJobList(range, searchKey);
      _duetodayJobs.clear();
      if (  response!= null ) {
        response['today'].forEach((o) {
          var item = JobListItem.fromJson(o);
          _duetodayJobs.add(item);
        });

        if ( response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
        }
      }


      if ( int.parse(_jobCount.countToday) <= _duetodayJobs.length ){
        _dataDueTodayJobsLoaded = true;
      }
      else{
        _dataDueTodayJobsLoaded = false;
      }

      _dataDueTodayJobsLoading = false;
    }
    else if ( range == "tomorrow" ) {
      var response = await JobService.getJobList(range, searchKey);
      _duetomorrowJobs.clear();
      if (  response!= null ) {
        response['tomorrow'].forEach((o) {
          var item = JobListItem.fromJson(o);
          _duetomorrowJobs.add(item);
        });

        if ( response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
        }
      }

      if ( int.parse(_jobCount.countTomorrow) <= _duetomorrowJobs.length ){
        _dataDueTomorrowJobsLoaded = true;
      }
      else{
        _dataDueTomorrowJobsLoaded = false;
      }

      _dataDueTomorrowJobsLoading = false;
    }
    else if ( range == "thisWeek"){
      var response = await JobService.getJobList(range, searchKey);
      _duethisweekJobs.clear();
      if (  response!= null ) {
        response['thisWeek'].forEach((o) {
          var item = JobListItem.fromJson(o);
          _duethisweekJobs.add(item);
        });

        if ( response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
        }
      }

      if ( int.parse(_jobCount.countThisWeek) <= _duethisweekJobs.length ){
        _dataDueThisWeekJobsLoaded = true;
      }
      else{
        _dataDueThisWeekJobsLoaded = false;
      }

      _dataDueThisWeekJobsLoading = false;
    }
    else if ( range == "nextWeek"){
      var response = await JobService.getJobList(range, searchKey);
      _duenextweekJobs.clear();
      if (  response!= null ) {
        response['nextWeek'].forEach((o) {
          var item = JobListItem.fromJson(o);
          _duenextweekJobs.add(item);
        });

        if ( response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
        }
      }

      if ( int.parse(_jobCount.countNextWeek) <= _duenextweekJobs.length ){
        _dataDueNextWeekJobsLoaded = true;
      }
      else{
        _dataDueNextWeekJobsLoaded = false;
      }

      _dataDueNextWeekJobsLoading = false;
    }
    else if ( range == "later"){
      var response = await JobService.getJobList(range, searchKey);
      _duelaterJobs.clear();
      if (  response!= null ) {
        response['later'].forEach((o) {
          var item = JobListItem.fromJson(o);
          _duelaterJobs.add(item);
        });

        if ( response['success'] == 0 ){
          Global.checkResponse(context, response['message']);
        }
      }

      if ( int.parse(_jobCount.countLater) <= _duelaterJobs.length ){
        _dataDueLaterJobsLoaded = true;
      }
      else{
        _dataDueLaterJobsLoaded = false;
      }

      _dataDueLaterJobsLoading = false;
    }

    if ( this.mounted ) {
      setState(() {});
    }
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

  Future<Null> _handleRefresh() async {
    final Completer<Null> completer = new Completer<Null>();
    searchKey = "";
    await loadData();

    if (true) {
      completer.complete(null);
    }

    return completer.future.then((_) {
      SnackBar(
          content: const Text('Refresh complete'),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }));
    });
  }

  void handleRefresh() async{
    if ( _isFirstLoad ) {
      _isFirstLoad = false;
      loadData();
    }
  }

  void showJobDetail(BuildContext context, _jobId) async{
    final result = await Navigator.push(context,
        MaterialPageRoute(
          builder: (BuildContext context) => JobCreateView(jobId: _jobId, pageMode: 0,)
        )
    );

    if ( result != null ) {
      var jsonResult = json.decode(result);
      if (jsonResult != null) {
        if ( jsonResult.containsKey("jobId") && jsonResult.containsKey("timeFrame") ) {
          var jobId = jsonResult['jobId'];
          var timeFrame = jsonResult['timeFrame'];
          if ( timeFrame.length > 0 ){
            _overdueJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            _duetodayJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            _duetomorrowJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            _duethisweekJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            _duenextweekJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            _duelaterJobs.forEach((job) {
              if ( job.id == jobId ){
                job.timeframe = timeFrame;
              }
            });

            setState(() {
            });
          }
        }
      }
    }
  }

  List<Widget> _buildJobs(BuildContext context) {
    var headerColor = Color(0xFFD2670B);
    var countBgColor = Color(0xFFE2E2E2);

    var formatter = new StringMask("(###) ###-####");
    var items = new List<Widget>();

    var now = new DateTime.now();
    var tomorrow = now.add(new Duration(days:1));

    // Overdue Jobs
    items.add(
        Container(
            margin: EdgeInsetsDirectional.only(top: 10),
            child: Center(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Overdue Jobs ",
                        style:TextStyle(
                            color: headerColor,
                            fontSize: Global.fontSizeNormal
                        )
                    ),
                    Container(
                      color: countBgColor,
                      padding: EdgeInsets.only(left:3, right:3),
                      child:Text(_jobCount.countOverdue,
                          style:TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeNormal
                          )
                      ),
                    ),

                    _dataOverdueJobsLoaded || _jobCount.countOverdue == "0"?Text(""):
                    _dataOverdueJobsLoading?
                    Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "loading...",
                          style: TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeSmall
                          ),
                        )
                    )
                    :
                    GestureDetector(
                      child:Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "load more",
                          style: TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeSmall,
                              decoration: TextDecoration.underline
                          ),
                        )
                      ),
                      onTap:(){
                        setState(() {
                          _dataOverdueJobsLoading = true;
                        });
                        getParticularJobs("overdue");
                      },
                    )

                  ],
                ),
            )
        )
    );
    if ( _overdueJobs.length > 0 ) {
      _overdueJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countOverdue == "0" ){
      items.add(new Container(
        child:Center(
          child: Text("No overdue jobs")
        )
      ));
    }


    // Due Today Jobs
    items.add(
        Container(
            margin: EdgeInsetsDirectional.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Due Today (" + DateFormat('EEE').format(now) + " " +  now.month.toString() + "/" + now.day.toString()  +  ") ",
                    style:TextStyle(
                      color: headerColor,
                      fontSize: Global.fontSizeNormal,
                    )
                ),
                Container(
                  color: countBgColor,
                  padding: EdgeInsets.only(left:3, right:3),
                  child:Text(_jobCount.countToday,
                      style:TextStyle(
                        color: headerColor,
                        fontSize: Global.fontSizeNormal,
                      )
                  ),
                ),

                _dataDueTodayJobsLoaded || _jobCount.countToday == "0"?Text(""):
                _dataDueTodayJobsLoading?
                Padding(
                    padding: EdgeInsets.only(left:10),
                    child:Text(
                      "loading...",
                      style: TextStyle(
                        color: headerColor,
                        fontSize: Global.fontSizeSmall
                      ),
                    )
                )
                    :
                GestureDetector(
                  child:Padding(
                      padding: EdgeInsets.only(left:10),
                      child:Text(
                        "load more",
                        style: TextStyle(
                            color: headerColor,
                            fontSize: Global.fontSizeSmall,
                            decoration: TextDecoration.underline
                        ),
                      )
                  ),
                  onTap:(){
                    setState(() {
                      _dataDueTodayJobsLoading = true;
                    });
                    getParticularJobs("today");
                  },
                )

              ],
            ),
        )
    );
    if ( _duetodayJobs.length > 0 ) {
      _duetodayJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countToday == "0" ){
      items.add(new Container(
          child:Center(
              child: Text("No jobs due today")
          )
      ));
    }



    // Due Tomorrow Jobs
    items.add(
        Container(
          margin: EdgeInsetsDirectional.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Due Tomorrow (" + DateFormat('EEE').format(tomorrow) + " " +  tomorrow.month.toString() + "/" + tomorrow.day.toString()  +  ") ",
                  style:TextStyle(
                    color: headerColor,
                    fontSize: Global.fontSizeNormal,
                  )
              ),
              Container(
                color: countBgColor,
                padding: EdgeInsets.only(left:3, right:3),
                child:Text(_jobCount.countTomorrow,
                    style:TextStyle(
                      color: headerColor,
                      fontSize: Global.fontSizeNormal,
                    )
                ),
              ),

              _dataDueTomorrowJobsLoaded || _jobCount.countTomorrow == "0"?Text(""):
              _dataDueTomorrowJobsLoading?
              Padding(
                  padding: EdgeInsets.only(left:10),
                  child:Text(
                    "loading...",
                    style: TextStyle(
                      color: headerColor,
                      fontSize: Global.fontSizeSmall,
                    ),
                  )
              )
                  :
              GestureDetector(
                child:Padding(
                    padding: EdgeInsets.only(left:10),
                    child:Text(
                      "load more",
                      style: TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeSmall,
                          decoration: TextDecoration.underline
                      ),
                    )
                ),
                onTap:(){
                  setState(() {
                    _dataDueTomorrowJobsLoading = true;
                  });
                  getParticularJobs("tomorrow");
                },
              )

            ],
          ),
        )
    );

    if ( _duetomorrowJobs.length > 0 ) {
      _duetomorrowJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countTomorrow == "0" ){
      items.add(new Container(
          child:Center(
              child: Text("No jobs due tomorrow")
          )
      ));
    }


    // Due This Week Jobs
    items.add(
        Container(
            margin: EdgeInsetsDirectional.only(top: 10),
            child: Center(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Due This Week ",
                      style:TextStyle(
                        color: headerColor,
                        fontSize: Global.fontSizeNormal,
                      )
                  ),
                  Container(
                    color: countBgColor,
                    padding: EdgeInsets.only(left:3, right:3),
                    child:Text(_jobCount.countThisWeek,
                        style:TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeNormal,
                        )
                    ),
                  ),
                  _dataDueThisWeekJobsLoaded || _jobCount.countThisWeek=="0"?Text(""):
                  _dataDueThisWeekJobsLoading?
                  Padding(
                      padding: EdgeInsets.only(left:10),
                      child:Text(
                        "loading...",
                        style: TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeSmall,
                        ),
                      )
                  )
                      :
                  GestureDetector(
                    child:Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "load more",
                          style: TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeSmall,
                              decoration: TextDecoration.underline
                          ),
                        )
                    ),
                    onTap:(){
                      setState(() {
                        _dataDueThisWeekJobsLoading = true;
                      });
                      getParticularJobs("thisWeek");
                    },
                  )

                ],
              ),
            )
        )
    );
    if ( _duethisweekJobs.length > 0 ) {
      _duethisweekJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countThisWeek == "0" ){
      items.add(new Container(
          child:Center(
              child: Text("No jobs due this week")
          )
      ));
    }

    // Due Next Week Jobs
    items.add(
        Container(
            margin: EdgeInsetsDirectional.only(top: 10),
            child: Center(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Due Next Week ",
                      style:TextStyle(
                        color: headerColor,
                        fontSize: Global.fontSizeNormal,
                      )
                  ),
                  Container(
                    color: countBgColor,
                    padding: EdgeInsets.only(left:3, right:3),
                    child:Text(_jobCount.countNextWeek,
                        style:TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeNormal,
                        )
                    ),
                  ),
                  _dataDueNextWeekJobsLoaded || _jobCount.countNextWeek == "0"?Text(""):
                  _dataDueNextWeekJobsLoading?
                  Padding(
                      padding: EdgeInsets.only(left:10),
                      child:Text(
                        "loading...",
                        style: TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeSmall,
                        ),
                      )
                  )
                      :
                  GestureDetector(
                    child:Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "load more",
                          style: TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeSmall,
                              decoration: TextDecoration.underline
                          ),
                        )
                    ),
                    onTap:(){
                      setState(() {
                        _dataDueNextWeekJobsLoading = true;
                      });
                      getParticularJobs("nextWeek");
                    },
                  )

                ],
              ),
            )
        )
    );
    if ( _duenextweekJobs.length > 0 ) {
      _duenextweekJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countNextWeek == "0" ){
      items.add(new Container(
          child:Center(
              child: Text("No jobs due next week")
          )
      ));
    }


    // Due Later Jobs
    items.add(
        Container(
            margin: EdgeInsetsDirectional.only(top: 10),
            child: Center(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Due Later ",
                      style:TextStyle(
                        color: headerColor,
                        fontSize: Global.fontSizeNormal,
                      )
                  ),
                  Container(
                    color: countBgColor,
                    padding: EdgeInsets.only(left:3, right:3),
                    child:Text(_jobCount.countLater,
                        style:TextStyle(
                          color: headerColor,
                          fontSize: Global.fontSizeNormal,
                        )
                    ),
                  ),
                  _dataDueLaterJobsLoaded || _jobCount.countLater == "0"?Text(""):
                  _dataDueLaterJobsLoading?
                  Padding(
                      padding: EdgeInsets.only(left:10),
                      child:Text(
                        "loading...",
                        style: TextStyle(
                            color: headerColor,
                          fontSize: Global.fontSizeSmall,
                        ),
                      )
                  )
                      :
                  GestureDetector(
                    child:Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Text(
                          "load more",
                          style: TextStyle(
                              color: headerColor,
                              fontSize: Global.fontSizeSmall,
                              decoration: TextDecoration.underline
                          ),
                        )
                    ),
                    onTap:(){
                      setState(() {
                        _dataDueLaterJobsLoading = true;
                      });
                      getParticularJobs("later");
                    },
                  )

                ],
              ),
            )
        )
    );
    if ( _duelaterJobs.length > 0 ) {
      _duelaterJobs.forEach((job) {
        items.add(GestureDetector(
          onTap: () {
            showJobDetail(context, job.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //"John Doe",
                          job.customerName,
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "From ${job.timeframe}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*
                        Expanded(
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue,
                          ),
                        ),
                        */
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                                job.address1 + " " + job.address2 + " " +
                                    job.city + "," + job.state,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: Global.fontSizeTiny,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.apply(job.phone),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: Global.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
    }else if ( _jobCount.countLater == "0" ){
      items.add(new Container(
          child:Center(
              child: Text("No jobs due after next week")
          )
      ));
    }

    items.add(SizedBox(height:10));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder fbBody = new FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if ( _dataLoading ){
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
      else if (_dataLoaded) {
        var jobList = _buildJobs(context);

        if (jobList.length > 0) {
          return ListView(
            children: jobList,
          );
        } else {
          return Center(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                  child: Text(
                    "No jobs are assigned.",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return Center(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(
                child: Text(
                  "Refresh View",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SafeArea(
        child: fbBody,
      ),
    );
  }
}
