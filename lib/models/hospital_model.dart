class HospitalModel {
  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  final String openingHours;
  final String imageUrl;
  final double latitude;
  final double longitude;

  HospitalModel({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.openingHours,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}
