class Note {
  String id;
  String user;
  String date;
  String text;
  String name;

  Note({
    this.id,
    this.user,
    this.date,
    this.text,
    this.name
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    var response = Note(
      id: json['id'],
      user: json['user'],
      date: json['date'],
      text: json['text'],
      name: json['name']
    );

    return response;
  }
}