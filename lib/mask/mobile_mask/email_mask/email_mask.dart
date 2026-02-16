class EmailMask {
  static String maskEmail(String email) {
    if (email.isEmpty) return "";

    List parts = email.split("@");
    if (parts.length != 2) return email;

    String name = parts[0];
    String domain = parts[1];

    if (name.length <= 2) {
      return "$name****@$domain";
    }

    String firstTwo = name.substring(0, 2);
    return "$firstTwo****@$domain";
  }
}
