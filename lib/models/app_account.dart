/// A local account row.
///
/// Mirrors the prototype's `appState.accounts[]` entries (`index.html`
/// lines 735-766) with one deliberate change: the password is never stored in
/// clear text — only a salted hash and its salt live in the database.
class AppAccount {
  const AppAccount({
    required this.id,
    required this.userId,
    required this.email,
    required this.username,
    required this.passwordHash,
    required this.passwordSalt,
    required this.gender,
    required this.dobDay,
    required this.dobMonth,
    required this.dobYear,
    required this.weightKg,
    required this.heightCm,
    required this.personalDetailsComplete,
    required this.createdAt,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String email;
  final String username;

  /// SHA-256 digest of `salt::password`.
  final String passwordHash;

  /// Hex encoded random salt.
  final String passwordSalt;

  final String gender;
  final String dobDay;
  final String dobMonth;
  final String dobYear;
  final String weightKg;
  final String heightCm;

  /// `false` until the personal-details step has been completed.
  final bool personalDetailsComplete;

  /// Human readable join date, e.g. "October 2026".
  final String createdAt;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  AppAccount copyWith({
    String? username,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    String? gender,
    String? dobDay,
    String? dobMonth,
    String? dobYear,
    String? weightKg,
    String? heightCm,
    bool? personalDetailsComplete,
    String? updatedAtUtc,
  }) {
    return AppAccount(
      id: id,
      userId: userId,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      gender: gender ?? this.gender,
      dobDay: dobDay ?? this.dobDay,
      dobMonth: dobMonth ?? this.dobMonth,
      dobYear: dobYear ?? this.dobYear,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      personalDetailsComplete:
          personalDetailsComplete ?? this.personalDetailsComplete,
      createdAt: createdAt,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc,
    );
  }

  /// The serialisable form used by the document store.
  ///
  /// The password hash and salt are intentionally **not** part of it — they
  /// live in the `accounts` table only.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'email': email,
        'username': username,
        'gender': gender,
        'dobDay': dobDay,
        'dobMonth': dobMonth,
        'dobYear': dobYear,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'personalDetailsComplete': personalDetailsComplete,
        'createdAt': createdAt,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory AppAccount.fromJson(Map<String, dynamic> json) => AppAccount(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        passwordHash: (json['passwordHash'] ?? '').toString(),
        passwordSalt: (json['passwordSalt'] ?? '').toString(),
        gender: (json['gender'] ?? 'Prefer not to say').toString(),
        dobDay: (json['dobDay'] ?? '').toString(),
        dobMonth: (json['dobMonth'] ?? '').toString(),
        dobYear: (json['dobYear'] ?? '').toString(),
        weightKg: (json['weightKg'] ?? '').toString(),
        heightCm: (json['heightCm'] ?? '').toString(),
        personalDetailsComplete: json['personalDetailsComplete'] == true,
        createdAt: (json['createdAt'] ?? '').toString(),
        createdAtUtc: (json['createdAtUtc'] ?? '').toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? '').toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}
