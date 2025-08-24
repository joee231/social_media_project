class SocialUserModel {
  late String name;
  late String email;
  late String phone;
  late String uId;
  late String image;
  late String backgrounder;
  late String bio;
  late bool isEmailVerified;
  late List<String> photos;

  SocialUserModel({
     required this.name,
     required this.email,
     required this.phone,
     required this.uId,
     required this.isEmailVerified,
     this.image = '',
    this.backgrounder = '',
    this.bio = 'my bio is empty',
    this.photos = const [],
  });

  SocialUserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    phone = json['phone'] ?? '';
    uId = json['uId'] ?? '';
    image = json['image'] ?? '';
    backgrounder = json['backgrounder'] ?? '';
    bio = json['bio'] ?? 'my bio is empty';
    isEmailVerified = json['isEmailVerified'] ?? false;
    photos = (json['photos'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uId': uId,
      'isEmailVerified': isEmailVerified,
      'image': image,
      'backgrounder': backgrounder,
      'bio': bio,
      'photos': photos,
    };
  }
}
