

class DistributorListItem {
  String id;
  String name;
  String phone;
  String email;
  String location;

  DistributorListItem({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.location
  });

  factory DistributorListItem.fromJson(Map<String, dynamic> json) {
    var response = DistributorListItem(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      location: json['location'],
    );

    if (json['phone'] == null ){
      response.phone = "";
    }
    else{
      response.phone = response.phone.replaceAll("-", "");
      response.phone = response.phone.replaceAll("(", "");
      response.phone = response.phone.replaceAll(")", "");
      response.phone = response.phone.replaceAll(" ", "");
    }

    return response;
  }
}





