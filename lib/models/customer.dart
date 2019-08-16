class Customer {
  String name;
  String phone;
  String address1;
  String address2;
  String city;
  String state;
  String zip;

  Customer({
    this.name,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    var response = Customer(
      name: json['name'],
      phone: json['phone'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      zip: json['zip']
    );

    return response;
  }
}