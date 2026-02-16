class MobileMask {
     String maskNumber(String number) {
    // empty me bhi +91 show
    if (number.isEmpty) {
      return "+91 ";
    }

    // typing time
    if (number.length < 10) {
      return "+91 $number";
    }

    // 10 digit complete → mask
    return "+91 ${number.substring(0, 5)}*****";
  }
}