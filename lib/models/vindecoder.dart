class VindecoderAccessoryData{
  String type;
  String part_number;
}

class VindecoderPartData{
  String id;
  String part_number;
  String glass;
  String glass_type_id;
  String description;
  String count;
  List<String> dealer_part_nums;
  List<VindecoderAccessoryData> accessories;
  String trim;
  String series;
}

class VindecoderData {
  String searchid;
  String squishvin;
  String year;
  String make;
  String model;
  String body;

  List<VindecoderPartData> parts;
  VindecoderData({
    this.searchid,
    this.squishvin,
    this.year,
    this.make,
    this.model,
    this.body
  });

  static VindecoderPartData getPart(Map<String, dynamic> p){
    VindecoderPartData part = new VindecoderPartData();
    part.id = p['id'];
    part.part_number = p['part_number'];
    part.glass = p['glass'];
    part.glass_type_id = p['glass_type_id'];
    part.description = p['description'];
    part.count = p['count'];
    part.trim = p['trim'];
    part.series = p['series'];

    part.dealer_part_nums = List<String>();
    if ( p['dealer_part_nums'] != null && p['dealer_part_nums'] is List<dynamic> ) {
      for (var i = 0; i < p['dealer_part_nums'].length; i++) {
        part.dealer_part_nums.add(p['dealer_part_nums'][i]);
      }
    }

    part.accessories = List<VindecoderAccessoryData>();

    if ( p['accessories'] != null && p['accessories'] is List<dynamic>){
      for (var i = 0; i < p['accessories'].length; i++) {
        VindecoderAccessoryData access = new VindecoderAccessoryData();
        access.type = p['accessories'][i]['type'];
        access.part_number = p['accessories'][i]['part_number'];

        part.accessories.add(access);
      }
    }

    return part;
  }
  factory VindecoderData.fromJson(Map<String, dynamic> json) {
    VindecoderData response = VindecoderData(
        searchid: json['searchid'],
        squishvin: json['squishvin'],
        year: json['year'],
        make: json['make'],
        model: json['model'],
        body: json['body']
    );

    response.parts = List<VindecoderPartData>();
    if ( json['parts'] is List<dynamic> ) {
      for(var i=0; i<json['parts'].length;i++){
        var p = json['parts'][i];
        VindecoderPartData part = VindecoderData.getPart(p);
        response.parts.add(part);
      }
    }
    else{
      json['parts'].forEach((k, v) {
        VindecoderPartData part = VindecoderData.getPart(v);
        response.parts.add(part);
      });
    }

    return response;
  }
}








