// ignore_for_file: file_names

class PostModel {
  final String uId;
  final String province;
  final String city;
  final String destination;
  final String airline;
  final String startDate;
  final String endDate;
  final String experience;
  final List<String> imageUrls;
  final List<String> tags;          // ← was String, now List<String>
  final String name;
  final bool allowcontact;
  final String? devicetoken;
  final String? status;            // lowercase “s” to match toMap key
  final String? country;           // lowercase “c” to match toMap key

  PostModel({
    required this.uId,
    required this.province,
    required this.city,
    required this.destination,
    required this.airline,
    required this.startDate,
    required this.endDate,
    required this.experience,
    required this.imageUrls,
    required this.tags,           // ← list
    required this.allowcontact,
    required this.name,
    this.devicetoken,
    this.status,
    this.country,
  });

  /* ───────────── convert to Map (for Firestore) ───────────── */
  Map<String, dynamic> toMap() => {
    'uId': uId,
    'province': province,
    'city': city,
    'destination': destination,
    'airline': airline,
    'startDate': startDate,
    'endDate': endDate,
    'experience': experience,
    'imageUrls': imageUrls,
    'tags': tags,                 // stays a list
    'allowcontact': allowcontact,
    'devicetoken': devicetoken,
    'name': name,
    'status': status,
    'country': country,
  };

  /* ───────────── create from Map (reading) ───────────── */
  factory PostModel.fromMap(Map<String, dynamic> json) => PostModel(
    uId: json['uId'] ?? '',
    province: json['province'] ?? '',
    city: json['city'] ?? '',
    destination: json['destination'] ?? '',
    airline: json['airline'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    experience: json['experience'] ?? '',
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),   // ← parse list
    allowcontact: json['allowcontact'] ?? false,
    devicetoken: json['devicetoken'],
    name: json['name'] ?? '',
    status: json['status'],
    country: json['country'],
  );
}
