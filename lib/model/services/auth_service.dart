import 'package:supabase_flutter/supabase_flutter.dart';

import '../user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    return user == null ? null : _toAppUser(user);
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = response.user;
    if (user == null) return null;
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'name': name,
    });
    return _toAppUser(user, name: name);
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return _toAppUser(
      user,
      name:
          profile?['name'] as String? ?? user.userMetadata?['name'] as String?,
      photoUrl: profile?['photo_url'] as String?,
    );
  }

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<void> signOut() => _client.auth.signOut();

  AppUser _toAppUser(User user, {String? name, String? photoUrl}) => AppUser(
    uid: user.id,
    email: user.email ?? '',
    name: name ?? user.userMetadata?['name'] as String? ?? '',
    photoUrl: photoUrl ?? user.userMetadata?['avatar_url'] as String?,
  );
}
