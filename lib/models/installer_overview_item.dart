
import 'package:auto_glass_crm/models/distributor_overview_item.dart';

class InstallerOverviewItem {
  String id;
  String user_id;
  String first_name;
  String last_name;
  String phone;
  String email;
  String address1;
  String address2;
  String city;
  String state;
  String zip;
  String type;
  String priority;
  String payment_method;
  String pay_rate;
  String pay_rate_per;
  String is_will_call;
  String is_delivery;
  String delivery_address;
  String text_work_order;
  String tax_id;
  String company_name;
  String to_delete;
  String notes;
  List<DistributorOverviewItem> distributors;


  InstallerOverviewItem({
    this.id,
    this.user_id,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip,
    this.type,
    this.priority,
    this.payment_method,
    this.pay_rate,
    this.pay_rate_per,
    this.is_will_call,
    this.is_delivery,
    this.delivery_address,
    this.notes,
    this.text_work_order,
    this.to_delete,
    this.first_name,
    this.last_name,
    this.phone,
    this.email,
    this.tax_id,
    this.company_name,
    this.distributors
  });

  factory InstallerOverviewItem.fromJson(Map<String, dynamic> json) {
    var response = InstallerOverviewItem(
      id: json['id'],
      user_id: json['user_id'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      type: json['type'],
      priority: json['priority'],
      payment_method: json['payment_method'],
      pay_rate: json['pay_rate'],
      pay_rate_per: json['pay_rate_per'],
      is_will_call: json['is_will_call'],
      is_delivery: json['is_delivery'],
      delivery_address: json['delivery_address'],
      notes: json['notes'],
      text_work_order: json['text_work_order'],
      to_delete: json['to_delete'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      tax_id: json['tax_id'],
      company_name: json['company_name'],
    );

    if ( response.phone == null ){
      response.phone = "";
    }else {
      //response.phone = response.phone.replaceAll("-", "");
    }
    if ( json['pay_rate'] == null ){
      response.pay_rate = "";
    }

    return response;
  }
}





