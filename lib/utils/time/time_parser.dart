class TimeParser {
  String toFormat(String time) {
    String datePart = time.substring(0, 10);
    String timePart = time.substring(11, 16);

    return "$datePart $timePart";
  }
}
