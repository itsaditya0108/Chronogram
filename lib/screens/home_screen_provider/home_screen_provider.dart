import 'dart:io';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreenProvider extends ChangeNotifier {
  UserDetailModal? _user;
  String _userName = "User";
  bool _isLoading = false;
  
  // Storage state
  Map<String, dynamic>? _storageUsage;
  Map<String, dynamic>? _storageDetails;
  
  // Sync state
  bool _isSyncing = false;
  double _syncProgress = 0.0;
  String _syncMessage = "";
  String _syncMode = "WIFI_ONLY";
  bool _isSyncUpdating = false;

  // Profile state
  String? _profileUrlMedium;
  String? _profileUrlSmall;
  List<dynamic> _profileHistory = [];
  bool _isProfileLoading = false;

  // Loading state
  bool _isStorageLoading = false;

  // Getters
  UserDetailModal? get user => _user;
  String get userName => _userName;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get storageUsage => _storageUsage;
  Map<String, dynamic>? get storageDetails => _storageDetails;
  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;
  String get syncMessage => _syncMessage;
  String get syncMode => _syncMode;
  bool get isSyncUpdating => _isSyncUpdating;
  bool get isStorageLoading => _isStorageLoading;
  String? get profileUrl => _profileUrlMedium; // Default to medium for profile screen
  String? get profileUrlSmall => _profileUrlSmall;
  List<dynamic> get profileHistory => _profileHistory;
  bool get isProfileLoading => _isProfileLoading;

  double get storageUsed => (_storageUsage?['used'] as num?)?.toDouble() ?? 0.0;
  double get storageLimit => (_storageUsage?['limit'] as num?)?.toDouble() ?? 10.0;
  double get photosStorage => (_storageDetails?['photos'] as num?)?.toDouble() ?? 0.0;
  double get videosStorage => (_storageDetails?['videos'] as num?)?.toDouble() ?? 0.0;

  /// Fetch User Profile
  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null) {
        _user = profile;
        _userName = profile.name ?? profile.mobileNumber ?? "User";
      }
    } catch (e) {
      print("Error fetching user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Storage Usage
  Future<void> fetchStorageUsage() async {
    _isStorageLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.getStorageUsage();
      if (resp["status"] == "success") {
        _storageUsage = resp;
      }
    } catch (e) {
      print("Error fetching storage usage: $e");
    } finally {
      _isStorageLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Storage Details
  Future<void> fetchStorageDetails() async {
    try {
      final resp = await ApiService.getStorageDetails();
      if (resp["status"] == "success") {
        _storageDetails = resp;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching storage details: $e");
    }
  }

  /// Upload Images Bulk (Sync)
  Future<Map<String, dynamic>> syncImages(List<File> files) async {
    _isSyncing = true;
    _syncProgress = 0.0;
    _syncMessage = "Starting sync...";
    notifyListeners();

    try {
      // For now, we use the bulk API directly. 
      // In a more advanced version, we can chunk the files here and update progress.
      final result = await ApiService.uploadImagesBulk(files: files);
      
      if (result["status"] == "success") {
        _syncMessage = "Sync completed successfully!";
        _syncProgress = 1.0;
        // Refresh storage data after upload
        fetchStorageUsage();
        fetchStorageDetails();
      } else {
        _syncMessage = result["message"] ?? "Sync failed.";
      }
      return result;
    } catch (e) {
      _syncMessage = "Error during sync: $e";
      return {"status": "error", "message": e.toString()};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Upload Videos Bulk (Sync)
  Future<Map<String, dynamic>> syncVideos(List<File> files) async {
    _isSyncing = true;
    _syncProgress = 0.0;
    _syncMessage = "Starting video sync...";
    notifyListeners();

    try {
      final result = await ApiService.uploadVideosBulk(files: files);
      
      if (result["status"] == "success") {
        _syncMessage = "Video sync completed successfully!";
        _syncProgress = 1.0;
        fetchStorageUsage();
        fetchStorageDetails();
      } else {
        _syncMessage = result["message"] ?? "Video sync failed.";
      }
      return result;
    } catch (e) {
      _syncMessage = "Error during video sync: $e";
      return {"status": "error", "message": e.toString()};
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }


  /// Fetch Sync Preference
  Future<void> fetchSyncPreference() async {
    try {
      final res = await ApiService.getSyncPreference();
      if (res["status"] == "success" && res["mode"] != null) {
        _syncMode = res["mode"];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching sync preference: $e");
    }
  }

  /// Update Sync Preference
  Future<bool> updateSyncPreference(String mode) async {
    if (_isSyncUpdating || _syncMode == mode) return false;
    _isSyncUpdating = true;
    notifyListeners();
    try {
      final res = await ApiService.updateSyncPreference(mode);
      if (res["status"] == "success") {
        _syncMode = mode;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isSyncUpdating = false;
      notifyListeners();
    }
  }

  /// Logout and Clear State
  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _userName = "User";
    _storageUsage = null;
    _storageDetails = null;
    notifyListeners();
  }

  /// Refresh User Profile (e.g. after photo upload)
  Future<void> refreshUser() async {
    await fetchUser();
    // Short delay to ensure backend has finished processing history record
    await Future.delayed(const Duration(milliseconds: 500));
    await fetchProfileHistory();
  }

  /// PROFILES: Fetch history and current photo
  Future<void> fetchProfileHistory() async {
    _isProfileLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.getProfileHistory();
      if (res["status"] == "success") {
        _profileHistory = (res["history"] as List? ?? []).reversed.toList();
        final ts = DateTime.now().millisecondsSinceEpoch;
        _profileUrlMedium = "${ApiService.getActiveProfileUrl(size: 'medium')}?t=$ts";
        _profileUrlSmall = "${ApiService.getActiveProfileUrl(size: 'small')}?t=$ts";
      }
    } catch (e) {
      print("Error fetching profile history: $e");
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  /// PROFILES: Upload new photo
  Future<Map<String, dynamic>> uploadProfilePicture(File file) async {
    _isProfileLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.uploadProfilePicture(file);
      if (result["status"] == "success") {
        await refreshUser();
      }
      return result;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  /// PROFILES: Set an old photo as active
  Future<Map<String, dynamic>> setActiveProfilePicture(int id) async {
    _isProfileLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.setActiveProfilePicture(id);
      if (result["status"] == "success") {
        await refreshUser();
      }
      return result;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }
}