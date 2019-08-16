import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auto_glass_crm/models/job_overview.dart';
import 'package:auto_glass_crm/services/job_service.dart';
import 'package:auto_glass_crm/views/job_list_view.dart';
import 'package:auto_glass_crm/views/job_create_view.dart';
import 'package:auto_glass_crm/services/map_utils.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:signature_pad/signature_pad.dart';
import 'package:auto_glass_crm/code/signature_pad/signature_pad_controller.dart';
import 'package:string_mask/string_mask.dart';
import 'package:html_unescape/html_unescape.dart';



class JobOverviewView extends StatefulWidget {
  final String jobId;
  bool refreshData;

  JobOverviewView({this.jobId, this.refreshData});

  @override
  _JobOverviewViewState createState() => new _JobOverviewViewState();
}

class _JobOverviewViewState extends State<JobOverviewView> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var unescape = new HtmlUnescape();

  bool _dataLoaded = false;
  bool _hasError = false;
  JobOverview _jobDetails = new JobOverview();
  final notesController = new TextEditingController();
  SignaturePadController _padController;
  bool isSignatureStarted = false;
  List<int> windshieldPhotoBytes = new List<int>();
  List<int> vinPhotoBytes = new List<int>();
  List<int> partNumberPhotoBytes = new List<int>();
  List<int> trimPhotoBytes = new List<int>();
  List<int> signatureBytes = new List<int>();
  int windshieldPhotoId = 0;
  int vinPhotoId = 0;
  int partNumberPhotoId = 0;
  int trimPhotoId = 0;
  bool isSubmitting = false;
  String _sendText = "Send";

  @override
  void initState() {
    super.initState();
    loadData();
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
    _jobDetails = await JobService.getJobDetails(widget.jobId);

    if (_jobDetails != null) {
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

  _buildTitleRow() {
    return Container(
      height: 100,
      color: Color(0xFFF1F4F8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _jobDetails.type,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child:Text(
                "[" + _jobDetails.stage + "]",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  _buildCustomerInfoRow() {
    var formatter = new StringMask("(###) ###-####");

    return Container(
      color: Color(0xFF),
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
                  unescape.convert(_jobDetails.customerName),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "from ${_jobDetails.timeFrame}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.pin_drop,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new InkWell(
                        child: Text(
                          //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                          "${_jobDetails.customerAddress1} ${_jobDetails.customerAddress2}",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue
                          ),
                        ),
                        onTap: () {
                          MapUtils.openMapAddress("${_jobDetails.customerAddress1} ${_jobDetails.customerAddress2} ${_jobDetails.customerCity} ${_jobDetails.customerState}");
                        },
                      ),

                      new InkWell(
                        child: Text(
                          //"3025 W Christoffersen Pkwy Apt H302 Durlock CA 95382",
                          "${_jobDetails.customerCity} ${_jobDetails.customerState} ${_jobDetails.customerZip}",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue
                          ),
                        ),
                        onTap: () {
                          MapUtils.openMapAddress("${_jobDetails.customerAddress1} ${_jobDetails.customerAddress2} ${_jobDetails.customerCity} ${_jobDetails.customerState}");
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () => launch("tel:${_jobDetails.customerPhone}"),
                  child: Text(
                    formatter.apply(_jobDetails.customerPhone),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
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

  _buildVehicleInfoRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Vehicle",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5),
            ),
            Text(
              //"2011 Honda Ridgeline RTL",
              unescape.convert("${_jobDetails.vehicle.year} ${_jobDetails.vehicle.make} ${_jobDetails.vehicle.model}"),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              //"(5FPYK1F55BB002554)",
              unescape.convert("(${_jobDetails.vehicle.vin})"),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDeductibleRow() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Deductible",
                      style: TextStyle(
                        color: Color(0xFF7D90B7),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "\$ ${_jobDetails.deductible ?? "N/A"}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildDistributorOrderNumRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Distributor Order #",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Text(
              unescape.convert("${_jobDetails.distributorOrderNum.isEmpty ? "N/A" : _jobDetails.distributorOrderNum}"),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDistributorRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Distributor",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Text(
              unescape.convert("${_jobDetails.distributorName ?? 'N/A'}"),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDealerPartNumberRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Dealer Part #",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Text(
              unescape.convert("${_jobDetails.dealerPartNum.isEmpty ? "N/A" : _jobDetails.dealerPartNum}"),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildPartNumberRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Part #",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5)),
            Text(
              unescape.convert("${_jobDetails.partNumber.isEmpty ? "N/A" : _jobDetails.partNumber}"),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildNotes() {
    var noteRows = List<Widget>();

    _jobDetails.notes
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

  _buildNotesRow() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Notes",
              style: TextStyle(
                color: Color(0xFF7D90B7),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
            ),
            Column(
              children: _buildNotes(),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: notesController,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your notes',
                      hintStyle: TextStyle(color: Colors.grey),
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

  Future<File> getImage(bool fromCamera) async {
    /*
    var image = await ImagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 400,
        maxWidth: 600);

    return image;
    */
    return null;
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

                        File compressedFile =
                            await FlutterNativeImage.compressImage(image.path);

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

                        File compressedFile =
                            await FlutterNativeImage.compressImage(image.path);

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
    signatureBytes = await _padController.toPng();
    return signatureBytes;
  }

  _buildSignatureRow() {
    var signaturePad = new SignaturePadWidget(
      _padController,
      new SignaturePadOptions(
          maxWidth: 1.0,
          penColor: "#000000",
          signatureText:
              "Signed by ${_jobDetails.customerName} on ${DateTime.now()}"),
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

  _saveJobDetails() async {
    var signatureBytes = await _handleSavePng();
    var success = await JobService.saveJobDetails(signatureBytes, widget.jobId,
        notes: notesController.text);

    if (success) {
      var snackBar = new SnackBar(
          content:
              new Text('Successfully Sent... Redirecting back to jobs page.'),
          duration: Duration(seconds: 2, milliseconds: 500));
      scaffoldKey.currentState.showSnackBar(snackBar);

      await Future.delayed(const Duration(seconds: 2), () => "2");

      Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  JobListView()));
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
    if (widget.refreshData != null && widget.refreshData) {
      _dataLoaded = false;
      loadData();
      widget.refreshData = false;
    }

    FutureBuilder fbBody = new FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (_dataLoaded && !_hasError) {
        return ListView(
          children: <Widget>[
            _buildTitleRow(),
            _buildCustomerInfoRow(),
            Divider(
              color: Colors.grey,
            ),
            _buildVehicleInfoRow(),
            _buildDivider(),
            _buildDeductibleRow(),
            _buildDivider(),
            _buildDistributorRow(),
            _buildDivider(),
            _buildDistributorOrderNumRow(),
            _buildDivider(),
            _buildDealerPartNumberRow(),
            _buildDivider(),
            _buildPartNumberRow(),
            _buildDivider(),
            _buildNotesRow(),
            _buildDivider(),
            _buildPhotoRow(),
            _buildDivider(),
            _buildSignatureRow(),
            _buildDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RaisedButton(
                child: isSubmitting ? _submittingWidget() : _sendTextWidget(),
                padding: EdgeInsets.symmetric(vertical: 15),
                onPressed: () async {
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
                      _saveJobDetails();
                    }
                  }
                },
                color: Colors.orangeAccent,
              ),
            )
          ],
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
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              print(widget.jobId);
              Map<String, dynamic> result;
              result = {
                "id": widget.jobId
              };
              Navigator.pop(context, json.encode(result));
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Job Overview",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          brightness: Brightness.light,
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                setState(() {
                });
              },
            )
          ],
        ),
        //drawer:
        body: SafeArea(
          child: fbBody,
        ));
  }
}

enum PhotoSelected { Windshield, PartNumber, VIN, TrimName }
