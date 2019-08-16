import 'package:html_unescape/html_unescape.dart';

class JobListItem {
  String address1;
  String address2;
  String city;
  String state;
  String customerName;
  String date;
  String id;
  String phone;
  String timeframe;

  JobListItem({
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.customerName,
    this.date,
    this.id,
    this.phone,
    this.timeframe
  });

  factory JobListItem.fromJson(Map<String, dynamic> json) {
    var unescape = new HtmlUnescape();
    var response = JobListItem(
      address1: unescape.convert(json['address1']),
      address2: unescape.convert(json['address2']),
      city: unescape.convert(json['city']),
      state: json['state'],
      customerName: unescape.convert(json['customer_name']),
      date: json['date'],
      id: json['id'],
      phone: json['phone'],
      timeframe: json['timeframe']
    );

    return response;
  }
}





