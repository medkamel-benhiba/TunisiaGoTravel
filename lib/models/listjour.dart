class Listjour {
  final Map<String, dynamic> listparjours;
  final dynamic dipart;
  final dynamic arriver;
  final String startDate;
  final String endDate;
  final String room;
  final String children;
  final String adults;

  Listjour({
    required this.listparjours,
    this.dipart,
    this.arriver,
    required this.startDate,
    required this.endDate,
    required this.room,
    required this.children,
    required this.adults,
  });

  factory Listjour.fromJson(Map<String, dynamic> json) {
    return Listjour(
      listparjours: json['listparjours'] ?? {},
      dipart: json['dipart'],
      arriver: json['arriver'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      room: json['room'] ?? '',
      children: json['children'] ?? '',
      adults: json['adults'] ?? '',
    );
  }
}