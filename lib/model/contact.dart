class Contact {
  int? id;
  String name;
  String phoneNumber;
  String email;
  String? photoUrl;
  String? address;
  String? company;
  String? jobTitle;
  DateTime? birthday;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.photoUrl,
    this.address,
    this.company,
    this.jobTitle,
    this.birthday,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'address': address,
      'company': company,
      'jobTitle': jobTitle,
      'birthday': birthday?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      address: map['address'],
      company: map['company'],
      jobTitle: map['jobTitle'],
      birthday: map['birthday'] != null 
          ? DateTime.parse(map['birthday']) 
          : null,
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    String? address,
    String? company,
    String? jobTitle,
    DateTime? birthday,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      birthday: birthday ?? this.birthday,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}