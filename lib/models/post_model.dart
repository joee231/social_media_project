class PostModel {
  late String name;
  late String uId;
  late String image;
  late String dateTime;
  late String text;
  late String postImage;
   late String postId;
   late List<String?> tags;
  Map<String, bool>? likes;

  late bool isArchived;
  bool? isEmailVerified; // Add this field


  PostModel({
    required this.name,
    required this.uId,
    this.image = '',
    this.dateTime = '',
    this.text = '',
    this.postImage = '',
    required this.postId ,
    this.likes,
    this.isArchived = false,
    this.tags = const [],
    this.isEmailVerified = false, // Initialize with a default value

  });

  PostModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    uId = json['uId'] ?? '';
    image = json['image'] ?? '';
    dateTime = json['dateTime'] ?? '';
    text = json['text'] ?? '';
    postImage = json['postImage'] ?? '';
    postId = json['postId'] ?? '';
    likes = json['likes'] != null ? Map<String, bool>.from(json['likes']) : {};
    isArchived = json['isArchived'] ?? false;
tags = json['tags'] != null ? List<String>.from(json['tags']) : [];

    isEmailVerified = json['isEmailVerified'] ?? false; // Safely access the field
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uId': uId,
      'image': image,
      'dateTime': dateTime,
      'text': text,
      'postImage': postImage,
      'postId': postId,
      'likes': likes ?? {},
      'isArchived': isArchived,
      'tags': tags,
      'isEmailVerified': isEmailVerified ?? false, // Ensure it's not null
    };
  }
}
