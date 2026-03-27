import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup.g.dart';

class SignupState {
  final String language;
  final String userRole;
  final String companyCode;
  final String email;
  final String name;
  final String password;
  final String employeeId;
  final String deskLocation;
  final String department;
  final String deskRole;

  const SignupState({
    this.language = 'en',
    this.userRole = '',
    this.companyCode = '',
    this.email = '',
    this.name = '',
    this.password = '',
    this.employeeId = '',
    this.deskLocation = '',
    this.department = '',
    this.deskRole = '',
  });

  SignupState copyWith({
    String? language,
    String? userRole,
    String? companyCode,
    String? email,
    String? name,
    String? password,
    String? employeeId,
    String? deskLocation,
    String? department,
    String? deskRole,
  }) => SignupState(
    language: language ?? this.language,
    userRole: userRole ?? this.userRole,
    companyCode: companyCode ?? this.companyCode,
    email: email ?? this.email,
    name: name ?? this.name,
    password: password ?? this.password,
    employeeId: employeeId ?? this.employeeId,
    deskLocation: deskLocation ?? this.deskLocation,
    department: department ?? this.department,
    deskRole: deskRole ?? this.deskRole,
  );
}

@Riverpod(keepAlive: true)
class SignupNotifier extends _$SignupNotifier {
  @override
  SignupState build() => const SignupState();

  void setLanguage(String language) =>
      state = state.copyWith(language: language);

  void setUserRole(String role) =>
      state = state.copyWith(userRole: role);

  void setCompanyCode(String code) =>
      state = state.copyWith(companyCode: code);

  void setCredentials({
    required String email,
    required String name,
    required String password,
    required String employeeId,
  }) => state = state.copyWith(
    email: email,
    name: name,
    password: password,
    employeeId: employeeId,
  );

  void setWorkDetails({
    required String deskLocation,
    required String department,
    required String deskRole,
  }) => state = state.copyWith(
    deskLocation: deskLocation,
    department: department,
    deskRole: deskRole,
  );

  void reset() => state = const SignupState();
}
