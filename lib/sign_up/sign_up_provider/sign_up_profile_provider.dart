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

//// Name Validation
  void validateName() {
  String name = nameController.text.trim();

  RegExp nameRegex = RegExp(r"^[a-zA-Z ]{2,25}$");

  if (name.isEmpty) {
    nameError = "Enter full name";
  } else if (!nameRegex.hasMatch(name)) {
    nameError = "Enter valid name (only letters)";
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
      DateTime selectedDate = DateTime.parse(dob);
      DateTime today = DateTime.now();

      int age = today.year - selectedDate.year;

      if (today.month < selectedDate.month ||
          (today.month == selectedDate.month && today.day < selectedDate.day)) {
        age--;
      }

      if (age < 12) {
        dobError = "You must be at least 12 years old";
      } else {
        dobError = null;
      }
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

  Future<bool> completeProfileApi(String mobile) async {
    validateName();
    validateDob();

    if (!isValid) return false;

    isLoading = true;
    notifyListeners();

    final result = await ApiService.completeProfile(
      name: nameController.text.trim(),
      dob: dobController.text.trim(),
      mobile: mobile,
    );

    isLoading = false;

    if (result == null) {
      dobError = "Something went wrong";
      notifyListeners();
      return false;
    }

    int statusCode = result["statusCode"];
    var data = result["data"];

    if (statusCode == 200) {
      String finalToken = data["accessToken"];
      await TokenHelper.saveToken(finalToken);
      notifyListeners();
      return true;
    }

    if (statusCode == 400) {
      dobError = data["message"] ?? "You must be at least 12 years old";
      notifyListeners();
      return false;
    }

    if (statusCode == 429) {
      dobError = "Too many attempts. Please try again later.";
      notifyListeners();
      return false;
    }

    dobError = "Server error. Try again.";
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}
