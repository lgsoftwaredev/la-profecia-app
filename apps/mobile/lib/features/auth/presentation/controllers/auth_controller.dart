import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, guest, authenticated, loading, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  StreamSubscription<AuthSession?>? _sessionSubscription;
  AuthSession? _session;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthSession? get session => _session;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _session != null;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> initialize() async {
    if (_sessionSubscription != null) {
      return;
    }

    _setStatus(AuthStatus.loading, clearError: true);
    try {
      _session = await _repository.restoreSession();
      _status = _session == null ? AuthStatus.guest : AuthStatus.authenticated;
      notifyListeners();
    } catch (error) {
      _setError(_resolveError(error));
    }

    _sessionSubscription = _repository.watchSession().listen(
      (session) {
        _session = session;
        _status = session == null ? AuthStatus.guest : AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _setError(_resolveError(error));
      },
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    _setStatus(AuthStatus.loading, clearError: true);
    try {
      await _repository.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        phone: phone,
      );
      try {
        await _repository.signOut();
      } catch (_) {
        // If there is no active session, continue.
      }
      _session = null;
      _status = AuthStatus.guest;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(_resolveError(error));
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      _session = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      return true;
    });
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      _session = await _repository.signInWithGoogle();
      return true;
    });
  }

  Future<bool> signInWithApple() async {
    return _runAuthAction(() async {
      _session = await _repository.signInWithApple();
      return true;
    });
  }

  Future<bool> sendPasswordResetCode({required String email}) async {
    return _runAuthAction(() async {
      await _repository.sendPasswordResetCode(email: email.trim());
      return true;
    });
  }

  Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return _runAuthAction(() async {
      await _repository.resetPasswordWithCode(
        email: email.trim(),
        code: code.trim(),
        newPassword: newPassword.trim(),
      );
      _session = null;
      return true;
    });
  }

  Future<void> signOut() async {
    _setStatus(AuthStatus.loading, clearError: true);
    try {
      await _repository.signOut();
      _session = null;
      _status = AuthStatus.guest;
      notifyListeners();
    } catch (error) {
      _setError(_resolveError(error));
    }
  }

  Future<bool> _runAuthAction(Future<bool> Function() action) async {
    _setStatus(AuthStatus.loading, clearError: true);
    try {
      final success = await action();
      _status = _session == null ? AuthStatus.guest : AuthStatus.authenticated;
      notifyListeners();
      return success;
    } catch (error) {
      _setError(_resolveError(error));
      return false;
    }
  }

  void _setStatus(AuthStatus status, {bool clearError = false}) {
    _status = status;
    if (clearError) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _resolveError(Object error) {
    final rawMessage = error is AppFailure ? error.message : error.toString();
    final normalized = rawMessage.toLowerCase();
    if (normalized.contains('confirmed') || normalized.contains('confirm')) {
      return 'Debe confirmar su email en su bandeja de correo';
    }

    if (error is AppFailure) {
      return error.message;
    }

    return 'Ocurrio un error de autenticacion.';
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
