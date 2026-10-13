class UserModels {
  final String uid;

  UserModels({required this.uid});
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final int defaultSugars;
  final String defaultMilk;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.defaultSugars,
    required this.defaultMilk,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      defaultSugars: (data['defaultSugars'] as num?)?.toInt() ?? 0,
      defaultMilk: data['defaultMilk'] as String? ?? 'Whole milk',
    );
  }
}

// Kept for the legacy settings screen until that screen is retired.
class UserData {
  final String uid;
  final String name;
  final String sugars;
  final int strength;

  const UserData({
    required this.uid,
    required this.name,
    required this.sugars,
    required this.strength,
  });
}
