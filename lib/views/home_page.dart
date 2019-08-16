import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/views/job_list_view.dart';
import 'package:auto_glass_crm/views/job_create_view.dart';
import 'package:auto_glass_crm/views/distributor_list_view.dart';
import 'package:auto_glass_crm/views/distributor_detail_view.dart';
import 'package:auto_glass_crm/views/installer_detail_view.dart';
import 'package:auto_glass_crm/views/installer_list_view.dart';
import 'package:auto_glass_crm/views/vindecoder_view.dart';
import 'package:auto_glass_crm/views/history_view.dart';
import 'package:auto_glass_crm/views/settings_view.dart';
import 'package:auto_glass_crm/views/account_warning_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:auto_glass_crm/services/push_notification_service.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';



class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  //Fragments
  JobListView mJobListView = new JobListView();
  InstallerListView mInstallerListView = new InstallerListView();
  DistributorListView mDistributorListView = new DistributorListView();
  VindecoderView mVindecoderView = new VindecoderView();
  HistoryView mHistoryView = new HistoryView();

  TextEditingController _menuSearchQuery;
  String menuSearchQuery = "Search query";

  int _selectedDrawerIndex = 0;

  FirebaseMessaging _fireBaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _fireBaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        if ( Platform.isAndroid ) {
          showNotification(message['notification']['title'], message['notification']['body'], json.encode(message) );
        }
        else{
          showNotification(message['aps']['alert']['title'], message['aps']['alert']['body'], json.encode(message) );
        }

      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
        handleNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
        handleNotification(message);
      },

    );

    _fireBaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _fireBaseMessaging.getToken().then((token){
      print("notification token=" + token);
      Global.pushNotificationToken = token;
      if (Global.userToken.isNotEmpty) {
        if ( Global.notificationStatus == "1" ) {
          PushNotificationService.sendPushToken(token);
        }
        else{
          PushNotificationService.sendPushToken("");
        }
      }
    });
    _menuSearchQuery = new TextEditingController();
    _vinSearchQuery = new TextEditingController();
    _jobSearchQuery = new TextEditingController();
    _installerSearchQuery = new TextEditingController();
    _distributorSearchQuery = new TextEditingController();
    _historySearchQuery = new TextEditingController();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    initPlatformState();
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await initPlatformStateForUriUniLinks();
  }

  initPlatformStateForUriUniLinks() async {

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print("Uri =" + uri.toString() );
      handleInitialUri(uri);
    }, onError: (err) {});

    // Get the latest Uri
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print("initialUri =" + initialUri.toString() );
    } on PlatformException {
      initialUri = null;
    } on FormatException {
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if ( initialUri != null ){
      handleInitialUri(initialUri);
    }
  }

  handleInitialUri(Uri uri){
    var currentHost = Global.domainPrefix + Global.domainSurfix;
    if ( currentHost != uri.host ) {
      return;
    }

    if ( uri.pathSegments.length == 1 ){
      var type = uri.pathSegments[0];
      if ( type == "job"){
        var jobId = uri.queryParameters["view"];
        if ( jobId != null && jobId.length > 0 ){
          // Job Detail Page
          if ( Global.vindecoderOnly == "0" ) {
            new Timer(const Duration(milliseconds: 300), () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      JobCreateView(jobId: jobId.toString(), pageMode: 0,)));
            });
          }
        }
        else {
          // Job List Page
          if ( Global.vindecoderOnly == "0" ) {
            new Timer(const Duration(milliseconds: 300), () {
              if (_selectedDrawerIndex != 0) {
                _selectedDrawerIndex = 0;
                setState(() {});
              }
            });
          }
        }
      }
      else if ( type == "installer" ){
        // Installer Page
        if ( Global.vindecoderOnly == "0" && Global.userAccess != "4" ) {
          new Timer(const Duration(milliseconds: 300), () {
            if (_selectedDrawerIndex != 1) {
              _selectedDrawerIndex = 1;
              setState(() {});
            }
          });
        }
      }
      else if ( type == "distributor" ){
        // Distributor Page
        if ( Global.vindecoderOnly == "0" && Global.userAccess != "4" ) {
          new Timer(const Duration(milliseconds: 300), () {
            if (_selectedDrawerIndex != 2) {
              _selectedDrawerIndex = 2;
              setState(() {});
            }
          });
        }
      }
      else if ( type == "vindecoder" ){
        // Vindecoder Page
        new Timer(const Duration(milliseconds: 300), () {
          if ( _selectedDrawerIndex != 3 ) {
            _selectedDrawerIndex = 3;
            setState(() { });
          }
        });
      }
    }
    else if ( uri.pathSegments.length == 2 ){
      var type = uri.pathSegments[0];
      var type2 = uri.pathSegments[1];
      if ( type == "vindecoder" && type2 == "history"){
        // Vindecoder History Page
        new Timer(const Duration(milliseconds: 300), () {
          if ( _selectedDrawerIndex != 4 ) {
            _selectedDrawerIndex = 4;
            setState(() { });
          }
        });
      }
      else if ( type == "user" && type2 == "profile"){
        // Settings Page
        new Timer(const Duration(milliseconds: 300), () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SettingsView()));
        });
      }
    }
    else if ( uri.pathSegments.length == 3 ){
      var type = uri.pathSegments[0];
      if ( type == "vindecoder" ){
        var type2 = uri.pathSegments[1];
        if ( type2 == "answer"){
          var id = uri.pathSegments[2];

          new Timer(const Duration(milliseconds: 300), () {
            if ( _selectedDrawerIndex == 4 ){
              mHistoryView.state.showAnswer(id);
            }
            else{
              _selectedDrawerIndex = 4;
              mHistoryView.answerId = id;
              setState(() { });
            }
          });
        }
      }
    }
  }






  showNotification(String title, String body, String payLoad) async{
    print(title + "," + body + "," + payLoad);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'autoglasscrm', 'autoglasscrm', 'autoglasscrm',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: payLoad);

  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {

      print("onDidReceiveLocalNotification");

      Map map = json.decode(payload);
      handleNotification(map);
  }

  Future<void> onSelectNotification(String payload) async {
    print("onSelectNotification" + payload);

    Map map = json.decode(payload);
    handleNotification(map);
  }

  handleNotification(Map<String, dynamic> message){
    print("handleNotification=" + message.toString() );

    var type = "";
    var id = "";
    if ( Platform.isAndroid ) {
      type = message['data']['type'];
      id = message['data']['id'];
    }
    else{
      id = message['id'];
      type = message['type'];
    }

    if ( type == "decode" ){
      new Timer(const Duration(milliseconds: 300), () {
        if ( _selectedDrawerIndex == 4 ){
          mHistoryView.state.showAnswer(id.toString());
        }
        else{
          _selectedDrawerIndex = 4;
          mHistoryView.answerId = id.toString();
          setState(() { });
        }
      });
    }
    else if ( type == "job" ){
      new Timer(const Duration(milliseconds: 300), () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                JobCreateView(jobId: id.toString(), pageMode: 0,)));
      });
    }
  }

  showSettingsPage(){
    /*
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            AccountWarningPage()
    ));
    */

    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            SettingsView()
    ));
  }


  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return mJobListView;
      case 1:
        return mInstallerListView;
      case 2:
        return mDistributorListView;
      case 3:
        return mVindecoderView;
      case 4:
        return mHistoryView;


      default:
        return new Text("Error");
    }
  }


  _getAppBar(int pos){
    switch(pos) {
      case 0:
        //Jobs
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black87, //change your color here
          ),

          backgroundColor: Colors.white,
          leading: _jobIsSearching ? const BackButton() : null,
          title: _jobIsSearching ? _jobBuildSearchField() : _jobBuildTitle(context),
          brightness: Brightness.light,
          centerTitle: true,
          actions: buildActionButtons()
        );
      case 1:
        //Installers
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black87, //change your color here
          ),
          backgroundColor: Colors.white,
          leading: _installerIsSearching ? const BackButton() : null,
          title: _installerIsSearching ? _installerBuildSearchField() : _installerBuildTitle(context),
          brightness: Brightness.light,
          centerTitle: true,
          actions: buildActionButtons()
        );
      case 2:
        //Distributors
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black87, //change your color here
          ),
          backgroundColor: Colors.white,
          leading: _distributorIsSearching ? const BackButton() : null,
          title: _distributorIsSearching ? _distributorBuildSearchField() : _distributorBuildTitle(context),
          brightness: Brightness.light,
          centerTitle: true,
          actions: buildActionButtons()
        );
      case 3:
        // Vindecoder
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          leading: _vinIsSearching ? const BackButton() : null,
          title: _vinIsSearching ? _vinBuildSearchField() : _vinBuildTitle(context),
          brightness: Brightness.light,
          actions: _vinBuildActions(),
        );
      case 4:
      // History
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          leading: _historyIsSearching ? const BackButton() : null,
          title: _historyIsSearching ? _historyBuildSearchField() : _historyBuildTitle(context),
          brightness: Brightness.light,
          actions: _historyBuildActions(),
        );
      default:
        return new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black87, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text("Title",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              )
          ),
          brightness: Brightness.light,
          centerTitle: true,
        );
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  void menuUpdateSearchQuery(String newQuery) {
    setState(() {
      menuSearchQuery = newQuery;
    });
  }

  /* Create Action Buttons on the right of AppBar*/
  List<Widget> buildActionButtons() {
    if ( _selectedDrawerIndex == 0 ){
      return _jobBuildActions();
    }
    else if ( _selectedDrawerIndex == 1 ){
      return _installerBuildActions();
    }
    else if ( _selectedDrawerIndex == 2 ){
      return _distributorBuildActions();
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.black),
        onPressed: () {
          if ( _selectedDrawerIndex == 0 ) // Jobs
          {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    JobCreateView(jobId: "0", pageMode: 2)));
          }
          //asyncCreateMenuDialog(context);
        },
      ),
    ];

  }

  /* CreateMenu Dialog */
  Future<ConfirmAction> asyncCreateMenuDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          title: const Text('Add New...'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Job'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        InstallerDetailView(installerId: "0", pageMode: 2)));

              },
              child: const Text('Installer'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        DistributorDetailView(distributorId: "0", pageMode: 2,)));
              },
              child: const Text('Distributor'),
            ),
            SizedBox(
                height:0.0
            ),
            Divider(color: Colors.black54, height: 1),
            SimpleDialogOption(
                onPressed: () { Navigator.pop(context); },
                child: Center(
                  child: Text('Cancel', style:TextStyle(color:Colors.red)),
                )
            ),
          ],
        );
      },
    );
  }

  /* Job Action Buttons */
  Widget jobAppTitle = new Text("Jobs");
  TextEditingController _jobSearchQuery;
  bool _jobIsSearching = false;
  String jobSearchQuery = "";

  void _jobStartSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _jobStopSearching));
    setState(() {
      _jobIsSearching = true;
    });
  }

  void _jobStopSearching() {
    //_clearSearchQuery();
    setState(() {
      _jobIsSearching = false;
    });
  }

  void _jobClearSearchQuery() {
    setState(() {
      _jobSearchQuery.clear();
    });
  }

  Widget _jobBuildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Jobs', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _jobBuildSearchField() {
    return new TextField(
      controller: _jobSearchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: null,
      onSubmitted: (newValue){
        jobUpdateSearchQuery(newValue);
        Navigator.pop(context);
      },
    );
  }

  void jobUpdateSearchQuery(String newQuery) {
    setState(() {
      jobSearchQuery = newQuery;
    });

    print("job new query:" + newQuery);
    mJobListView.state.searchKey = newQuery;
    mJobListView.state.loadData();
  }

  List<Widget> _jobBuildActions() {
    if (_jobIsSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            jobUpdateSearchQuery(_jobSearchQuery.text);
            Navigator.pop(context);
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.black),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  JobCreateView(jobId: "0", pageMode: 2,)));
        },
      ),
      new IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: _jobStartSearch,
      ),
    ];
  }


  /* Installer Action Buttons */
  Widget installerAppTitle = new Text("Installers");
  TextEditingController _installerSearchQuery;
  bool _installerIsSearching = false;
  String installerSearchQuery = "";

  void _installerStartSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _installerStopSearching));
    setState(() {
      _installerIsSearching = true;
    });
  }

  void _installerStopSearching() {
    //_clearSearchQuery();
    setState(() {
      _installerIsSearching = false;
    });
  }

  void _installerClearSearchQuery() {
    setState(() {
      _installerSearchQuery.clear();
    });
  }

  Widget _installerBuildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Installers', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _installerBuildSearchField() {
    return new TextField(
      controller: _installerSearchQuery,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: null,
      onSubmitted: (newValue){
        installerUpdateSearchQuery(newValue);
        Navigator.pop(context);
      },
    );
  }

  void installerUpdateSearchQuery(String newQuery) {
    setState(() {
      installerSearchQuery = newQuery;
    });

    print("installer new query:" + newQuery);
    mInstallerListView.state.searchKey = newQuery;
    mInstallerListView.state.loadData(false);
  }

  List<Widget> _installerBuildActions() {
    if (_installerIsSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            installerUpdateSearchQuery(_installerSearchQuery.text);
            Navigator.pop(context);
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.black),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  InstallerDetailView(installerId: "0", pageMode: 2,)));
        },
      ),
      new IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: _installerStartSearch,
      ),
    ];
  }


  /* Distributor Action Buttons */
  Widget distributorAppTitle = new Text("Distributors");
  TextEditingController _distributorSearchQuery;
  bool _distributorIsSearching = false;
  String distributorSearchQuery = "";

  void _distributorStartSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _distributorStopSearching));
    setState(() {
      _distributorIsSearching = true;
    });
  }

  void _distributorStopSearching() {
    //_clearSearchQuery();
    setState(() {
      _distributorIsSearching = false;
    });
  }

  void _distributorClearSearchQuery() {
    setState(() {
      _distributorSearchQuery.clear();
    });
  }

  Widget _distributorBuildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Distributors', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _distributorBuildSearchField() {
    return new TextField(
      controller: _distributorSearchQuery,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: null,
      onSubmitted: (newValue){
        distributorUpdateSearchQuery(newValue);
        Navigator.pop(context);
      },
    );
  }

  void distributorUpdateSearchQuery(String newQuery) {
    setState(() {
      distributorSearchQuery = newQuery;
    });

    print("distributor new query:" + newQuery);
    mDistributorListView.state.searchKey = newQuery;
    mDistributorListView.state.loadData(false);
  }

  List<Widget> _distributorBuildActions() {
    if (_distributorIsSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            distributorUpdateSearchQuery(_distributorSearchQuery.text);
            Navigator.pop(context);
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.black),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  DistributorDetailView(distributorId: "0", pageMode: 2,)));
        },
      ),
      new IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: _distributorStartSearch,
      ),
    ];
  }


  /* Vindecoder Search Bar */
  Widget vindecoderAppTitle = new Text("Vindecoder");
  TextEditingController _vinSearchQuery;
  bool _vinIsSearching = false;
  String vinSearchQuery = "";

  void _vinStartSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _vinStopSearching));
    setState(() {
      _vinIsSearching = true;
    });
  }

  void _vinStopSearching() {
    //_clearSearchQuery();
    setState(() {
      _vinIsSearching = false;
    });
  }

  void _vinClearSearchQuery() {
    setState(() {
      _vinSearchQuery.clear();
    });
  }

  Widget _vinBuildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Vindecoder Search', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _vinBuildSearchField() {
    return new TextField(
      controller: _vinSearchQuery,
      autofocus: false,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: null,
      onSubmitted: (newValue){
        vinUpdateSearchQuery(newValue);
        Navigator.pop(context);
      },
    );
  }

  void vinUpdateSearchQuery(String newQuery) {
    setState(() {
      vinSearchQuery = newQuery;
    });
    if ( newQuery.length > 0 ) {
      mVindecoderView.state.loadData(newQuery);
    }
  }

  List<Widget> _vinBuildActions() {
    if (_vinIsSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            vinUpdateSearchQuery(_vinSearchQuery.text);
            Navigator.pop(context);
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: _vinStartSearch,
      ),
    ];
  }



  /* History search Bar */
  TextEditingController _historySearchQuery;
  bool _historyIsSearching = false;
  String historySearchQuery = "";

  void _historyStartSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _historyStopSearching));
    setState(() {
      _historyIsSearching = true;
    });
  }

  void _historyStopSearching() {
    //_clearHistorySearchQuery();
    setState(() {
      _historyIsSearching = false;
    });
  }

  void _clearHistorySearchQuery() {
    setState(() {
      _historySearchQuery.clear();
    });
  }

  Widget _historyBuildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Search for VIN in history', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _historyBuildSearchField() {
    return new TextField(
      controller: _historySearchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: null,
      onSubmitted: (newValue){
        historyUpdateSearchQuery(newValue);
        Navigator.pop(context);
      },
    );
  }

  void historyUpdateSearchQuery(String newQuery) {
    setState(() {
      historySearchQuery = newQuery;
    });
    if ( newQuery.length > 0 ) {
      mHistoryView.state.loadData(newQuery);
    }
  }

  List<Widget> _historyBuildActions() {
    if (_historyIsSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            historyUpdateSearchQuery(_historySearchQuery.text);
            Navigator.pop(context);
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search, color: Colors.black),
        onPressed: _historyStartSearch,
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    const Color color_bg = Color(0xFF1E3C6B);
    const Color color_divider = Color(0x30A4C6EB);//Color(0xFF484848);
    const Color color_text = Colors.white;

    List<Widget> menus = List<Widget>();
    var menuJobs = GestureDetector(
      onTap: (){
        _onSelectItem(0);
      },
      child:Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.assignment, color: color_text),
                      onPressed: () => {  print("tap jobs") },
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Jobs",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ],
                )
              ]
          )
      )
    );
    var menuInstallers = GestureDetector(
      onTap: (){
        _onSelectItem(1);
      },
      child:Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.group_add, color: color_text),
                      onPressed: () => {},
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Installers",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ],
                )
              ]
          )
      )
    );
    var menuDistributors = GestureDetector(
      onTap:(){
        _onSelectItem(2);
      },
      child: Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.group, color: color_text),
                      onPressed: () => {},
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Distributors",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ],
                )
              ]
          )
      )
    );
    var menuVindecoder = GestureDetector(
      onTap:() {
        _onSelectItem(3);
      },
      child: Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.event, color: color_text),
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Vindecoder",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ],
                )
              ]
          )
      ),
    );

    var menuHistory = GestureDetector(
      onTap:() {
        _onSelectItem(4);
      },
      child: Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.history, color: color_text),
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Search History",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ],
                )
              ]
          )
      ),
    );

    var menuLogout = GestureDetector(
      onTap:(){
        Navigator.of(context).pop();
        Global.asyncLgoutDialog(context);
      },
      child: Container(
          padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
          margin: EdgeInsets.symmetric(vertical: 0.0),
          decoration: BoxDecoration(
          ),
          child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.exit_to_app, color: color_text),
                    ),
                    Padding(padding: EdgeInsets.only(left: 0.0)),
                    Text("Log out",
                        style: TextStyle(
                            color: color_text,
                            fontWeight: FontWeight.bold
                        )
                    )

                  ],
                )
              ]
          )
      ),
    );

    if ( Global.vindecoderOnly == "0" ) {
      menus.add(menuJobs);
      if (Global.userAccess != "4") {
        menus.add(menuInstallers);
        menus.add(menuDistributors);
      }
    }

    menus.add(menuVindecoder);
    menus.add(menuHistory);
    // menus.add(Divider(color: color_divider, height: 2));
    menus.add(menuLogout);

    var drawer = Drawer(
      // column holds all the widgets in the drawer
      child: Column(
        children: <Widget>[
          Container(
              color: color_bg,
              // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.topCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: <Widget>[
                          new Container (
                              decoration: new BoxDecoration (
                                  color: color_bg
                              ),
                              child: new ListTile (
                                leading: Image.asset('assets/ic_logo_blue.png', width: 40, height:  40),
                                title: Text('AutoGlassCRM',
                                    style: TextStyle(
                                        color: color_text,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19
                                    )
                                ),
                              )
                          ),
                          Divider(color: color_divider, height: 2),
                          new Container(
                            padding: const EdgeInsets.only(left: 14.0, bottom: 2.0, top: 2.0, right: 14.0),
                            decoration: new BoxDecoration(
                              color:color_bg,
                            ),
                            child: new TextField(
                              controller: _menuSearchQuery,
                              autofocus: false,
                              decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: color_bg,
                                  contentPadding: const EdgeInsets.only(left: 4.0, bottom: 0.0, top: 0.0, right: 4.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0)
                                      ),
                                      borderSide: const BorderSide(color: color_divider, width: 1.0)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0)
                                      ),
                                      borderSide: const BorderSide(color: color_divider, width: 1.0)
                                  ),
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  hintStyle: const TextStyle(color: color_text),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 18.0,
                                    color: color_text,
                                  )
                              ),
                              style: const TextStyle(color: color_text, fontSize: 16.0),
                              onChanged: menuUpdateSearchQuery,
                            ),
                          ),
                          Divider(color: color_divider, height: 2),
                        ],
                      )
                  )
              )
          ),
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
              child: Container(
                color: color_bg,
                child:ListView(
                    children: menus
                ),
              )
          ),
          // This container holds the align
          Container(
              color: color_bg,
              // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Divider(color: color_divider, height: 2),
                          GestureDetector(
                            onTap:(){
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
                                margin: EdgeInsets.symmetric(vertical: 0.0),
                                decoration: BoxDecoration(
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.supervised_user_circle, color: color_text),
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 0.0)),
                                        new Flexible(
                                          child: new Container(
                                            padding: new EdgeInsets.only(right: 13.0),
                                            child: new Text(
                                                Global.currentUserName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: color_text,
                                                  fontWeight: FontWeight.bold,

                                                )
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                            showSettingsPage();
                                          },
                                          icon: Icon(Icons.settings, color: color_text),
                                        )
                                      ],
                                    )
                                  ]
                                )
                            ),
                          )
                        ],
                      )
                  )
              )
          )
        ],
      ),
    );

    var fbody = _getDrawerItemWidget(_selectedDrawerIndex);

    return new Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFF1F4F8),
      appBar: _getAppBar(_selectedDrawerIndex),
      drawer: new SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,//20.0, ,
          child: drawer
      ),
      body: fbody,
    );
  }
}