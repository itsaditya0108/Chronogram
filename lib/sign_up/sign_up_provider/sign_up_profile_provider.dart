
import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../token_saver_helper/token_saver_helper.dart';

class SignUpProfileProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String? nameError;
  String? dobError;

  bool isValid = false;
  bool isLoading = false;

  void validateName() {
    String name = nameController.text.trim();

    if (name.isEmpty) {
      nameError = "Enter full name";
    } else {
      nameError = null;
    }

    checkAllValid();
    notifyListeners();
  }

  void validateDob() {
    String dob = dobController.text.trim();

    if (dob.isEmpty) {
      dobError = "Select DOB";
    } else {
      dobError = null;
    }

    checkAllValid();
    notifyListeners();
  }

  void checkAllValid() {
    isValid =
        nameError == null &&
        dobError == null &&
        nameController.text.isNotEmpty &&
        dobController.text.isNotEmpty;
  }

  /// 🔥 FINAL COMPLETE PROFILE API
  Future<bool> completeProfileApi(String mobile) async {
    validateName();
    validateDob();

    if (!isValid) return false;

    isLoading = true;
    notifyListeners();

    String name = nameController.text.trim();
    String dob = dobController.text.trim();

    final result = await ApiService.completeProfile(
      name: name,
      dob: dob,
      mobile: mobile,
    );

    isLoading = false;
    notifyListeners();

   
    if (result != null) {
      print("FULL RESPONSE: $result");

      String finalToken = result["accessToken"];
      await TokenHelper.saveToken(finalToken);

      print("FINAL LOGIN TOKEN: $finalToken");

      /// USER DATA PRINT (safe parsing)
      if (result.containsKey("user")) {
        var user = result["user"];

        print("USER NAME: ${user["name"]}");
        print("USER EMAIL: ${user["email"]}");
        print("USER MOBILE: ${user["mobileNumber"]}");
      } else {
        // agar direct response me aaye
        print("USER NAME: ${result["name"]}");
        print("USER EMAIL: ${result["email"]}");
        print("USER MOBILE: ${result["mobileNumber"]}");
      }

      return true;
    } else {
      print("PROFILE API FAILED");
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}
