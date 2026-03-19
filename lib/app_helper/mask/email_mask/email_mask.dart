class EmailMask {
  static String maskEmail(String email) {
    if (email.isEmpty || !email.contains("@")) return email;

    List<String> parts = email.split("@");
    String name = parts[0];
    String domain = parts[1];

    // agar name chota hai to mask mat karo
    if (name.length <= 5) return email;

    String firstPart = name.substring(0, 2); // starting show
    String lastPart = name.substring(name.length - 2); // last 2 show

    // Limit stars to max 6 to prevent UI overflow
    int starCount = name.length - 4;
    if (starCount > 6) starCount = 6;
    
    String stars = "*" * starCount; // middle mask

    return "$firstPart$stars$lastPart@$domain";
  }

  /// Reduces consecutive asterisks in a string to a maximum of 6.
  /// Useful for sanitizing masked emails received from the backend.
  static String sanitizeMaskedEmail(String maskedEmail) {
    if (maskedEmail.isEmpty) return maskedEmail;
    
    // Replace 7 or more consecutive asterisks with exactly 6 asterisks
    return maskedEmail.replaceAll(RegExp(r'\*{7,}'), '******');
  }
}