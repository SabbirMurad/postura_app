class PrivateSignInModel {
  String message;
  String accessToken;
  String refreshToken;
  int expiresIn;
  int expiresAt;
  User user;

  PrivateSignInModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.expiresAt,
    required this.user,
  });

  PrivateSignInModel copyWith({
    String? message,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    int? expiresAt,
    User? user,
  }) =>
      PrivateSignInModel(
        message: message ?? this.message,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresIn: expiresIn ?? this.expiresIn,
        expiresAt: expiresAt ?? this.expiresAt,
        user: user ?? this.user,
      );

  factory PrivateSignInModel.fromJson(Map<String, dynamic> json) => PrivateSignInModel(
    message: json["message"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    expiresIn: json["expires_in"],
    expiresAt: json["expires_at"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "expires_in": expiresIn,
    "expires_at": expiresAt,
    "user": user.toJson(),
  };
}

class User {
  int id;
  String email;
  String fullName;
  String role;
  String language;
  bool hasOnboarded;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.language,
    required this.hasOnboarded,
  });

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    String? language,
    bool? hasOnboarded,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        language: language ?? this.language,
        hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    email: json["email"],
    fullName: json["full_name"],
    role: json["role"],
    language: json["language"],
    hasOnboarded: json["has_onboarded"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "full_name": fullName,
    "role": role,
    "language": language,
    "has_onboarded": hasOnboarded,
  };
}
