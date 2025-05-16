class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final DateTime? dateOfBirth;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    String? confirmPassword,
    this.dateOfBirth,
  }) : confirmPassword = confirmPassword ?? password;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth!.toUtc().toIso8601String();
    }

    return data;
  }
}

class User {
  final String email;
  final String userName;
  final List<String> roles;

  User({required this.email, required this.userName, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      userName: json['userName'] as String,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'userName': userName, 'roles': roles};
  }

  String get fullName => userName;
}

class LoginResponse {
  final bool isSuccess;
  final String message;
  final String token;
  final String refreshToken;
  final DateTime expiration;
  final String userName;
  final String email;
  final List<String> roles;

  LoginResponse({
    required this.isSuccess,
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.expiration,
    required this.userName,
    required this.email,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isSuccess: json['isSuccess'] as bool,
      message: json['message'] as String,
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiration: DateTime.parse(json['expiration']).toUtc(),
      userName: json['userName'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'expiration': expiration.toUtc().toIso8601String(),
      'userName': userName,
      'email': email,
      'roles': roles,
    };
  }

  User toUser() {
    return User(email: email, userName: userName, roles: roles);
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth!.toUtc().toIso8601String();
    }

    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'token': token, 'newPassword': newPassword};
  }
}

class AuthError {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  AuthError({required this.message, this.code, this.details});

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] as String,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
