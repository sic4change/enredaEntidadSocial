// import 'dart:async';
//
// import 'package:enreda_app/services/auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class SignInManager {
//   SignInManager({required this.auth, required this.isLoading});
//   final AuthBase auth;
//   final ValueNotifier<bool> isLoading;
//
//   Future<User?> _signIn(Future<User?> Function() signInMethod) async {
//     try {
//       isLoading.value = true;
//       return await signInMethod();
//     } catch(e) {
//       isLoading.value = false;
//       rethrow;
//     }
//   }
//
//   Future<User?> signInAnonymously() async => await _signIn(auth.signInAnonymously);
//
//   Future<User?> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);
//
// }