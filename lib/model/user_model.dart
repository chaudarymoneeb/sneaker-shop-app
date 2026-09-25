class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.name = '',
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
}

typedef UserModel = AppUser;
