class Accessory {
  String type;
  String partNumber;
  String cost;

  Accessory({
    this.type,
    this.partNumber,
    this.cost,
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    var response = Accessory(
      type: json['type'],
      partNumber: json['part_number'],
      cost: json['cost'],
    );

    return response;
  }
}