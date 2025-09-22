import 'destination.dart';

class CircuitManuel {

  final String? circuitId;
  final String? villeDepart;
  final String? villeArrive;
  final String? startDate;
  final String? endDate;
  final int? adults;
  final int? children;
  final int? rooms;
  final double? budget;
  final int? duree;
  final String? name;
  final List<dynamic>? destinations;

  CircuitManuel({
    this.circuitId,
    this.villeDepart,
    this.villeArrive,
    this.startDate,
    this.endDate,
    this.adults,
    this.children,
    this.rooms,
    this.budget,
    this.duree,
    this.name,
    this.destinations,
  });


  factory CircuitManuel.fromJson(Map<String, dynamic> json) {
    return CircuitManuel(
      destinations: (json['alldestinationnew'] as List?)
          ?.map((d) => Destination.fromJson(d))
          .toList() ?? [],
    );
  }


}