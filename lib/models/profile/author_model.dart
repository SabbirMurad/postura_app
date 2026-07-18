import 'package:posture_detector_app/models/media/image.dart';

/// The authenticated user's profile, parsed from the flat `/me` payload:
/// `{ uuid, full_name, email, avatar, role, company_code, has_onboarded }`.
class AuthorModel {
  final String id;
  final String fullName;
  final String email;
  final ImageModel? avatar;
  final String role;
  final String companyCode;
  final bool hasOnboarded;

  AuthorModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.role,
    this.companyCode = '',
    this.hasOnboarded = false,
  });

  factory AuthorModel.empty() =>
      AuthorModel(id: '', fullName: '', email: '', role: '');

  AuthorModel copyWith({
    String? id,
    String? fullName,
    String? email,
    ImageModel? avatar,
    String? role,
    String? companyCode,
    bool? hasOnboarded,
  }) => AuthorModel(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    role: role ?? this.role,
    companyCode: companyCode ?? this.companyCode,
    hasOnboarded: hasOnboarded ?? this.hasOnboarded,
  );

  // Backend sends a UUID string for id; `avatar` is the full image metadata
  // object ({ uuid, blur_hash, width, height }) or null when unset.
  factory AuthorModel.fromJson(Map<String, dynamic> json) => AuthorModel(
    id: json["uuid"]?.toString() ?? json["id"]?.toString() ?? '',
    fullName: json["full_name"] ?? '',
    email: json["email"] ?? '',
    avatar: json["avatar"] is Map<String, dynamic>
        ? ImageModel.fromJson(json["avatar"])
        : null,
    role: json["role"] ?? '',
    companyCode: json["company_code"]?.toString() ?? '',
    hasOnboarded: json["has_onboarded"] == true,
  );

  Map<String, dynamic> toJson() => {
    "uuid": id,
    "full_name": fullName,
    "email": email,
    "avatar": avatar?.toJson(),
    "role": role,
    "company_code": companyCode,
    "has_onboarded": hasOnboarded,
  };
}
