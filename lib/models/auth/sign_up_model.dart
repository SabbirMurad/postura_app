
class PrivateSignupModel {
  String message;
  int userId;
  String role;
  bool hasOnboarded;

  PrivateSignupModel({
    required this.message,
    required this.userId,
    required this.role,
    required this.hasOnboarded,
  });

  PrivateSignupModel copyWith({
    String? message,
    int? userId,
    String? role,
    bool? hasOnboarded,
  }) =>
      PrivateSignupModel(
        message: message ?? this.message,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      );

  factory PrivateSignupModel.fromJson(Map<String, dynamic> json) => PrivateSignupModel(
    message: json["message"],
    userId: json["user_id"],
    role: json["role"],
    hasOnboarded: json["has_onboarded"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "user_id": userId,
    "role": role,
    "has_onboarded": hasOnboarded,
  };
}
