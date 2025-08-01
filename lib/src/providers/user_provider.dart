import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _profile;
  User? get profile => _profile;

  Future<void> fetchProfile() async {
    final response = await ApiService.get('/auth/profile');
    if (response['success'] == true) {
      _profile = User.fromJson(response['data']);
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    final response = await ApiService.put('/auth/profile', body: updates);
    if (response['success'] == true) {
      _profile = User.fromJson(response['data']);
      notifyListeners();
      return true;
    }
    return false;
  }
} 