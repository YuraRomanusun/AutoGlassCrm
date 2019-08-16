import 'package:auto_glass_crm/models/customer.dart';
import 'package:auto_glass_crm/models/note.dart';
import 'package:auto_glass_crm/models/vehicle.dart';

class DistributorOverviewItem {
  String id;
  String name;
  String type;
  String phone;
  String fax;
  String managerName;
  String managerEmail;
  String address1;
  String address2;
  String city;
  String state;
  String zip;
  String payment_net30;
  String payment_cod;
  String notes;
  String to_delete;

  DistributorOverviewItem({
    this.id,
    this.name,
    this.type,
    this.phone,
    this.fax,
    this.managerName,
    this.managerEmail,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip,
    this.payment_net30,
    this.payment_cod,
    this.notes,
    this.to_delete
  });

  factory DistributorOverviewItem.fromJson(Map<String, dynamic> json) {
    var response = DistributorOverviewItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      phone: json['phone'],
      fax: json['fax'],
      managerName: json['manager'],
      managerEmail: json['email'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      payment_net30: json['payment_net30'],
      payment_cod: json['payment_cod'],
      notes: json['notes'],
      to_delete: json['to_delete'],
    );



    return response;
  }
}





