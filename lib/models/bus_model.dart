import 'package:latlong2/latlong.dart';

/// Model สำหรับเก็บข้อมูลรถบัส
class Bus {
  final String id;
  final String name;
  final LatLng position;
  double? distanceToUser; // ระยะห่างจากผู้ใช้ (เมตร)
  double speedKmh; // ความเร็วรถ (km/h) - ค่าเริ่มต้น 40 km/h

  Bus({
    required this.id,
    required this.name,
    required this.position,
    this.distanceToUser,
    this.speedKmh = 40.0,
  });

  /// สร้างจาก Firebase snapshot
  factory Bus.fromFirebase(String id, Map<dynamic, dynamic> data) {
    return Bus(
      id: id,
      name: data['name']?.toString() ?? 'สาย $id',
      position: LatLng(
        double.parse(data['lat'].toString()),
        double.parse(data['lng'].toString()),
      ),
      speedKmh: double.tryParse(data['speed']?.toString() ?? '') ?? 40.0,
    );
  }

  /// คำนวณ ETA (วินาที) จากระยะทางและความเร็ว
  int? calculateETASeconds() {
    if (distanceToUser == null || speedKmh <= 0) return null;
    // เวลา = ระยะทาง(km) / ความเร็ว(km/h) * 3600 = วินาที
    double distanceKm = distanceToUser! / 1000;
    double etaHours = distanceKm / speedKmh;
    return (etaHours * 3600).round();
  }

  /// Format ETA เป็นข้อความ เช่น "2:30" หรือ "45 วินาที"
  String formatETA() {
    final seconds = calculateETASeconds();
    if (seconds == null) return 'N/A';

    if (seconds < 60) {
      return '~$seconds วินาที';
    } else {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')} นาที';
    }
  }

  /// Copy with distance
  Bus copyWithDistance(double distance) {
    return Bus(
      id: id,
      name: name,
      position: position,
      distanceToUser: distance,
      speedKmh: speedKmh,
    );
  }
}
