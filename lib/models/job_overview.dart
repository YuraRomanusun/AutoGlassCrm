import 'package:auto_glass_crm/models/customer.dart';
import 'package:auto_glass_crm/models/note.dart';
import 'package:auto_glass_crm/models/accessory.dart';
import 'package:auto_glass_crm/models/vehicle.dart';

class JobOverview {
  String id;
  String created;
  String salesperson;
  String deductible;
  String orderNum;
  String type;
  String stage;
  String vehicleId;
  String billingInfo;
  String cashCCPaid;
  String totalDue;
  String totalDuePaid;
  String partNumber;
  String dealerPartNum;
  String glassOrderDate;
  String glassArrivalDate;
  String distributorID;
  String distributorOrderNum;
  String costGlass;
  String costDelivery;
  String installerID;
  String date;
  String timeFrame;
  String timeframe_start;
  String timeframe_end;
  String noTexts;
  String userName;
  String salespersonName;
  String customerID;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerAddress1;
  String customerAddress2;
  String customerCity;
  String customerState;
  String customerZip;
  String customerNotes;
  String installerName;
  String installerPhone;
  String distributorName;
  String type_label;
  String stage_label;
  List<Accessory> accessories;
  List<Note> notes;
  Vehicle vehicle;

  JobOverview({
    this.id,
    this.created,
    this.salesperson,
    this.deductible,
    this.orderNum,
    this.type,
    this.stage,
    this.vehicleId,
    this.billingInfo,
    this.cashCCPaid,
    this.totalDue,
    this.totalDuePaid,
    this.partNumber,
    this.dealerPartNum,
    this.glassOrderDate,
    this.glassArrivalDate,
    this.distributorID,
    this.distributorOrderNum,
    this.costGlass,
    this.costDelivery,
    this.installerID,
    this.date,
    this.timeFrame,
    this.timeframe_start,
    this.timeframe_end,
    this.noTexts,
    this.userName,
    this.salespersonName,
    this.customerID,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerAddress1,
    this.customerAddress2,
    this.customerCity,
    this.customerState,
    this.customerZip,
    this.customerNotes,
    this.installerName,
    this.installerPhone,
    this.distributorName,
    this.type_label,
    this.stage_label,
    this.accessories,
    this.notes,
    this.vehicle
  });

  factory JobOverview.fromJson(Map<String, dynamic> json) {
    var response = JobOverview(
      id: json['id'],
      created: json['created'],
      salesperson: json['salesperson'],
      deductible: json['deductible'],
      orderNum: json['order_num'],
      type: json['type'],
      stage: json['stage'],
      vehicleId: json['vehicle_id'],
      billingInfo: json['billing_info'],
      cashCCPaid: json['cashccpaid'],
      totalDue: json['total_due'],
      totalDuePaid: json['total_due_paid'],
      partNumber: json['part_number'],
      dealerPartNum: json['dealer_part_num'],
      glassOrderDate: json['glass_order_date'],
      glassArrivalDate: json['glass_arrival_date'],
      distributorID: json['distributor'],
      distributorOrderNum: json['distributor_order_num'],
      costGlass: json['cost_glass'],
      costDelivery: json['cost_delivery'],
      installerID: json['installer'],
      date: json['date'],
      timeFrame: json['timeframe'],
      timeframe_start: json['timeframe_start'],
      timeframe_end: json['timeframe_end'],
      noTexts: json['no_texts'],
      userName: json['user_name'],
      salespersonName: json['salesperson_name'],
      customerID: json['customer'],
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],
      customerAddress1: json['customer_address1'],
      customerAddress2: json['customer_address2'],
      customerCity: json['customer_city'],
      customerState: json['customer_state'],
      customerZip: json['customer_zip'],
      customerNotes: json['customer_notes'],
      installerName: json['installer_name'],
      installerPhone: json['installer_phone'],
      distributorName: json['distributor_name'],
      type_label: json['type_label'],
      stage_label: json['stage_label'],
    );

    if ( response.salespersonName == null ){
      response.salespersonName = "";
    }

    if ( response.installerID == null ){
      response.installerID = "";
    }

    if ( response.installerName == null ){
      response.installerName = "";
    }

    if ( response.vehicleId == null ){
      response.vehicleId = "";
    }

    if ( response.distributorID == null ){
      response.distributorID = "";
    }

    if ( response.timeFrame == null ){
      response.timeFrame = "";
    }

    if ( response.timeframe_start == null ){
      response.timeframe_start = "";
    }

    if ( response.timeframe_end == null ){
      response.timeframe_end = "";
    }

    if ( response.customerID == null ){
      response.customerID = "";
    }

    response.vehicle = Vehicle.fromJson(json['vehicle']);


    if (json['accessories'] != null) {
      response.accessories = List<Accessory>();
      json['accessories'].forEach((p) {
        response.accessories.add(Accessory.fromJson(p));
      });
    }

    if (json['notes'] != null) {
      response.notes = List<Note>();
      json['notes'].forEach((p) {
        response.notes.add(Note.fromJson(p));
      });
    }


    return response;
  }
}





