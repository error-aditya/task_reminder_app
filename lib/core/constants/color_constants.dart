// // ignore_for_file: non_constant_identifier_names, constant_identifier_names

// import 'dart:math' as math;

// import 'package:flutter/material.dart';

// // class AppColors {
// //   AppColors._();
// //   static const Color white = Colors.white;
// //   static const Color black = Colors.black;
// //   static const MaterialColor grey = Colors.grey;
// //   static const Color bgColor = Color(0xffefefef);
// //   static const Color bgColorLight = Color(0xffeeeeee);
// //   static const Color theme = Color.fromARGB(255, 175, 0, 0);
// //   static const Color themeLight = Color.fromARGB(255, 253, 199, 199);
// //   static Color random = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
// // }

// extension GetInvertedColor on Color {
//   Color get inverted {
//     final r = 255 - red;
//     final g = 255 - green;
//     final b = 255 - blue;
//     return Color.fromARGB((opacity * 255).round(), r, g, b);
//   }
// }

// extension GetMaterialColor on Color {
//   MaterialColor get mapped {
//     Map<int, Color> colorMap = {
//       50: withOpacity(0.05),
//       100: withOpacity(0.1),
//       200: withOpacity(0.2),
//       300: withOpacity(0.3),
//       400: withOpacity(0.4),
//       500: withOpacity(0.5),
//       600: withOpacity(0.6),
//       700: withOpacity(0.7),
//       800: withOpacity(0.9),
//       900: withOpacity(1),
//     };

//     return MaterialColor(this.value, colorMap);
//   }
// }
