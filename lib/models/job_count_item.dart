class JobCountItem {
  String countLater;
  String countNextWeek;
  String countOverdue;
  String countThisWeek;
  String countToday;
  String countTomorrow;


  JobCountItem({
    this.countLater,
    this.countNextWeek,
    this.countOverdue,
    this.countThisWeek,
    this.countToday,
    this.countTomorrow,
  });

  factory JobCountItem.fromJson(Map<String, dynamic> json) {
    var response = JobCountItem(
      countLater: json['countLater'],
      countNextWeek: json['countNextWeek'],
      countOverdue: json['countOverdue'],
      countThisWeek: json['countThisWeek'],
      countToday: json['countToday'],
      countTomorrow: json['countTomorrow'],
    );

    return response;
  }
}





