import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser();

      if (token != null && user != null) {
        ApiService().setToken(token);
        _currentUser = user;
        SocketService().connect(token);

        // Fetch fresh profile from /me
        try {
          final res = await ApiService().get('/auth/me');
          if (res != null && res['user'] != null) {
            _currentUser = UserModel.fromJson(res['user']);
            await AuthService.saveSession(token, _currentUser!);
          }
        } catch (_) {}
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String displayName,
    required String email,
    required String password,
    String? interests,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().post('/auth/register', {
        'username': username,
        'display_name': displayName,
        'email': email,
        'password': password,
        'interests': interests ?? 'Gaming,Tech',
      });

      final token = res['token'] as String;
      final user = UserModel.fromJson(res['user']);

      _currentUser = user;
      await AuthService.saveSession(token, user);
      SocketService().connect(token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String login,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().post('/auth/login', {
        'login': login,
        'password': password,
      });

      final token = res['token'] as String;
      final user = UserModel.fromJson(res['user']);

      _currentUser = user;
      await AuthService.saveSession(token, user);
      SocketService().connect(token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> quickLogin([String username = 'kaelen_vr']) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().post('/auth/quick-login', {
        'username': username,
      });

      final token = res['token'] as String;
      final user = UserModel.fromJson(res['user']);

      _currentUser = user;
      await AuthService.saveSession(token, user);
      SocketService().connect(token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await AuthService.clearSession();
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}
    SocketService().disconnect();
    notifyListeners();
  }

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _signInClient => _googleSignIn ??= GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _signInClient.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final res = await ApiService().post('/auth/google', {
        'email': googleUser.email,
        'display_name': googleUser.displayName ?? googleUser.email.split('@')[0],
        'photo_url': googleUser.photoUrl,
        'google_id': googleUser.id,
      });

      final token = res['token'] as String;
      final user = UserModel.fromJson(res['user']);

      _currentUser = user;
      await AuthService.saveSession(token, user);
      SocketService().connect(token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google Sign In exception: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogleAccount({
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().post('/auth/google', {
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'google_id': 'g_${DateTime.now().millisecondsSinceEpoch}',
      });

      final token = res['token'] as String;
      final user = UserModel.fromJson(res['user']);

      _currentUser = user;
      await AuthService.saveSession(token, user);
      SocketService().connect(token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? status,
    String? customStatus,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      if (bio != null) body['bio'] = bio;
      if (status != null) body['status'] = status;
      if (customStatus != null) body['custom_status'] = customStatus;
      final res = await ApiService().put('/auth/profile', body);

      if (res != null && res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        final token = await AuthService.getToken();
        if (token != null) {
          await AuthService.saveSession(token, _currentUser!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
