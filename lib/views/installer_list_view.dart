import 'dart:async';

import 'package:auto_glass_crm/code/global.dart';
import 'package:auto_glass_crm/views/installer_detail_view.dart';

import 'package:auto_glass_crm/models/installer_list_item.dart';
import 'package:auto_glass_crm/services/installer_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:string_mask/string_mask.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

class InstallerListView extends StatefulWidget {
  _InstallerListViewState state;
  @override
  _InstallerListViewState createState() {
    state = new _InstallerListViewState();
    return state;
  }
}

class _InstallerListViewState extends State<InstallerListView> {
  var unescape = new HtmlUnescape();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String searchKey = "";
  bool _dataLoaded = false;
  bool _dataLoading = false;
  bool _dataLoadingMore = false;
  List<InstallerListItem> _installers = new List<InstallerListItem>();

  int currentPageNum = 1;
  int defaultPageSize = 15;
  bool bLoadMore = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();


  @override
  void initState() {
    super.initState();
    loadData(false);
  }

  /* Get Distributor List */
  Future<List<InstallerListItem>> loadData(bool _loadMore) async {
    if ( _loadMore ){
      currentPageNum++;
      _dataLoadingMore = true;
    }
    else {
      currentPageNum = 1;
      _installers.clear();
      _dataLoaded = false;
      _dataLoading = true;
    }

    if ( this.mounted ) {
      setState(() {});
    }
    List<InstallerListItem> _installersResult = new List<InstallerListItem>();

    var response = await InstallerService.getInstallerList(currentPageNum.toString(), defaultPageSize.toString(), searchKey);
    if ( response != null ){
      if ( response is List<dynamic> ){
        response.forEach((o) {
          var item = InstallerListItem.fromJson(o);
          _installersResult.add(item);
        });
      }
      else if ( response.containsKey("success") && response['success'] == 0) {
        Global.checkResponse(context, response['message']);
      }
    }


    if ( _installersResult != null ){
      _installers.addAll(_installersResult);
      if ( _installersResult.length == defaultPageSize ){
        bLoadMore = true;
      }
      else
      {
        bLoadMore = false;
      }
    }else {
      bLoadMore = false;
    }

    if ( _loadMore ) {
      _dataLoadingMore = false;
    }
    else {
      _dataLoaded = true;
      _dataLoading = false;
    }

    if ( this.mounted ) {
      setState(() {});
    }
    return _installers;
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
    await loadData(false);
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

  List<Widget> _buildInstallers(BuildContext context) {
    var headerColor = Color(0xFFD2670B);
    var formatter = new StringMask("(###) ###-####");
    var items = new List<Widget>();

    _installers.forEach((installer) {
      items.add(GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  InstallerDetailView(installerId: installer.id, pageMode: 0,)));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
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
                      Expanded(
                        flex: 1,
                        child: Text(
                          //"John Doe",
                          unescape.convert(installer.first_name + " " + installer.last_name),
                          style: TextStyle(
                            fontSize: Global.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
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
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                              unescape.convert(installer.location),
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: Global.fontSizeTiny,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        //"8168358121",
                        formatter.apply(installer.phone),
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

    if ( bLoadMore ) {
      if (_dataLoadingMore) {
        items.add(
            Container(
                margin: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 0),
                child: MaterialButton(
                    color: Color(0xFF027BFF),
                    child: SizedBox(
                      height: 25.0,
                      width: 25.0,
                      child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFEFEFEF)),
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    )
                )
            )
        );
      } else {
        items.add(
            Container(
                margin: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 0),
                child: MaterialButton(
                    color: Color(0xFF027BFF),
                    child: Center(
                        child: Text(
                          "Load More ...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                    ),
                    onPressed: () {
                      loadData(true);
                    }
                )
            )
        );
      }
    }



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
      else if (_dataLoaded || _dataLoadingMore) {
        var installerList = _buildInstallers(context);

        if (installerList.length > 0) {
          return ListView(
            children: installerList,
          );
        } else {
          return Center(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                  child: Text(
                    "No Installers are assigned.",
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
