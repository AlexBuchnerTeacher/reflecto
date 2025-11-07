class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.createdAt,
  });

  /// Serializes only non-null fields to avoid overwriting existing values with nulls.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'uid': uid};
    if (displayName != null) map['displayName'] = displayName;
    if (email != null) map['email'] = email;
    if (photoUrl != null) map['photoUrl'] = photoUrl;
    if (createdAt != null) map['createdAt'] = createdAt;
    return map;
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}
