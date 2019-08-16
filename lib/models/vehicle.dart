class Vehicle {
  String make;
  String model;
  String year;
  String vin;

  Vehicle({
    this.make,
    this.model,
    this.year,
    this.vin
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    var response = Vehicle(
      make: json['make'],
      model: json['model'],
      year: json['year'],
      vin: json['vin']
    );

    return response;
  }
}