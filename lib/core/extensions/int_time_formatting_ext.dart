// extension FormatTime on int {
//   String get toMMSS {
//     int sec = this % 60;
//     int min = (this / 60).floor();
//     String minute = min.toString().length <= 1 ? "0$min" : "$min";
//     String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
//     return "$minute : $second";
//   }
//   String get toHHMMSS {
//     int hours = (this / 3600).floor();
//     int remainingSeconds = this % 3600;
//     int minutes = (remainingSeconds / 60).floor();
//     int seconds = remainingSeconds % 60;

//     String hourStr = hours.toString().length <= 1 ? "0$hours" : "$hours";
//     String minuteStr = minutes.toString().length <= 1 ? "0$minutes" : "$minutes";
//     String secondStr = seconds.toString().length <= 1 ? "0$seconds" : "$seconds";

//     return "$hourStr : $minuteStr : $secondStr";
//   }

// }