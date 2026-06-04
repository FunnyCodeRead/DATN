import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kid_manager/background/native_watcher_service.dart';

enum _RuntimeState { stopped, starting, running, stopping }

class AuthRuntimeManager {
  static StreamSubscription<User?>? _sub;

  static _RuntimeState _state = _RuntimeState.stopped;

  static int _opToken = 0;
  static String? _lastAuthUid;

  static String? _parentId;
  static String? _displayName;

  static void start({required String parentId, required String displayName}) {
    _parentId = parentId;
    _displayName = displayName;

    unawaited(_sub?.cancel());

    final initialUser = FirebaseAuth.instance.currentUser;
    User? lastUser = initialUser;

    if (initialUser != null) {
      unawaited(_handleAuthChanged(initialUser));
    }

    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final sameUser = lastUser?.uid == user?.uid;
      if (sameUser) return;

      lastUser = user;
      unawaited(_handleAuthChanged(user));
    });
  }

  static Future<void> stop() async {
    _opToken++;
    await _safeLogout(_opToken);
  }

  static Future<void> _handleAuthChanged(User? user) async {
    final token = ++_opToken;
    final newUid = user?.uid;

    if (newUid != null &&
        _lastAuthUid == newUid &&
        _state == _RuntimeState.running) {
      return;
    }

    _lastAuthUid = newUid;

    if (user == null) {
      await _safeLogout(token);
    } else {
      await _safeLogin(user.uid, token);
    }
  }

  static Future<void> _safeLogin(String uid, int token) async {
    if (_state == _RuntimeState.starting) return;

    _state = _RuntimeState.starting;

    debugPrint('Runtime starting for $uid');

    try {
      if (token != _opToken) return;

      if (_parentId != null && _displayName != null) {
        final ok = await NativeWatcherService.saveWatcherConfig(
          userId: uid,
          parentId: _parentId,
          childName: _displayName,
        );

        debugPrint(
          ok
              ? 'Native watcher config saved'
              : 'Failed to save native watcher config',
        );
      }

      if (token != _opToken) return;

      debugPrint('Native usage worker started');
      _state = _RuntimeState.running;
      debugPrint('Runtime running');
    } catch (e) {
      debugPrint('Runtime start failed: $e');
      _state = _RuntimeState.stopped;
    }
  }

  static Future<void> _safeLogout(int token) async {
    try {
      await NativeWatcherService.saveWatcherConfig(
        userId: '',
        parentId: '',
        childName: '',
      );
    } catch (e) {
      debugPrint('Runtime stop error: $e');
    }

    if (_state == _RuntimeState.stopped || _state == _RuntimeState.stopping) {
      return;
    }

    _state = _RuntimeState.stopping;

    debugPrint('Runtime stopping');
    if (token != _opToken) return;

    _parentId = null;
    _state = _RuntimeState.stopped;

    debugPrint('Runtime stopped');
  }

  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;

    _opToken++;

    await _safeLogout(_opToken);
  }
}
