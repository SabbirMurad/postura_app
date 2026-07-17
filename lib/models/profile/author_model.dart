class AuthorModel {
  String message;
  AuthorData data;

  AuthorModel({required this.message, required this.data});

  AuthorModel copyWith({String? message, AuthorData? data}) =>
      AuthorModel(message: message ?? this.message, data: data ?? this.data);

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return AuthorModel(
      message: json["message"]?.toString() ?? '',
      data: data is Map<String, dynamic>
          ? AuthorData.fromJson(data)
          : AuthorData.empty(),
    );
  }

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class AuthorData {
  String id;
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

  factory AuthorData.empty() =>
      AuthorData(id: '', fullName: '', email: '', avatar: null, role: '');

  AuthorData copyWith({
    String? id,
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

  // Backend sends a UUID string for id; toString keeps it robust to either type.
  factory AuthorData.fromJson(Map<String, dynamic> json) => AuthorData(
    id: json["id"]?.toString() ?? '',
    fullName: json["full_name"] ?? '',
    email: json["email"] ?? '',
    avatar: json["avatar"],
    role: json["role"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "email": email,
    "avatar": avatar,
    "role": role,
  };
}
