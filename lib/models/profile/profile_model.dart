class ProfileModel {
  String message;
  Data data;

  ProfileModel({required this.message, required this.data});

  ProfileModel copyWith({String? message, Data? data}) =>
      ProfileModel(message: message ?? this.message, data: data ?? this.data);

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    print('');
    print(json);
    print('');

    return ProfileModel(
      message: json["message"],
      data: Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  String fullName;
  String email;
  String? avatar;
  String role;

  Data({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.role,
  });

  Data copyWith({
    int? id,
    String? fullName,
    String? email,
    String? avatar,
    String? role,
  }) => Data(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    role: role ?? this.role,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    fullName: json["full_name"],
    email: json["email"],
    avatar: json["avatar"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "email": email,
    "avatar": avatar,
    "role": role,
  };
}
