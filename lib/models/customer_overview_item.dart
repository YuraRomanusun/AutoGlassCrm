class CustomerOverViewItem {
  String first_name;
  String last_name;
  String phone;
  String email;
  String address1;
  String address2;
  String city;
  String state;
  String zip;

  CustomerOverViewItem({
    this.first_name,
    this.last_name,
    this.phone,
    this.email,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip
  });

  factory CustomerOverViewItem.fromJson(Map<String, dynamic> json) {
    var response = CustomerOverViewItem(
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      zip: json['zip']
    );

    return response;
  }
}