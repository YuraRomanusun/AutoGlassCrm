

class InstallerListItem {
  String id;
  String first_name;
  String last_name;
  String phone;
  String email;
  String location;

  InstallerListItem({
    this.id,
    this.first_name,
    this.last_name,
    this.phone,
    this.email,
    this.location
  });

  factory InstallerListItem.fromJson(Map<String, dynamic> json) {
    var response = InstallerListItem(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
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

    if (json['email'] == null ){
      response.email = "";
    }

    if (json['location'] == null ){
      response.location = "";
    }


    return response;
  }
}





