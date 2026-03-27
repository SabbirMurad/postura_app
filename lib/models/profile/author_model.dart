class AuthorModel {
  String message;
  AuthorData data;

  AuthorModel({required this.message, required this.data});

  AuthorModel copyWith({String? message, AuthorData? data}) =>
      AuthorModel(message: message ?? this.message, data: data ?? this.data);

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      message: json["message"],
      data: AuthorData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class AuthorData {
  int id;
  String fullName;
  String email;
  String? avatar;
  String role;

  AuthorData({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.role,
  });

  AuthorData copyWith({
    int? id,
    String? fullName,
    String? email,
    String? avatar,
    String? role,
  }) => AuthorData(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    role: role ?? this.role,
  );

  factory AuthorData.fromJson(Map<String, dynamic> json) => AuthorData(
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
