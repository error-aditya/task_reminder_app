import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newtodo/authentication/register_user.dart';
import 'package:newtodo/model/user.dart';
import 'package:newtodo/notificationn.dart';
// import 'package:newtodo/screens/splash_screen.dart';
import 'package:newtodo/model/task.dart';
import 'package:newtodo/screens/todopage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  NotificationService().initNotification();
  tz.initializeTimeZones();
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
    Hive.registerAdapter(UserAdapter());
  }
  await Hive.openBox<Task>('taskk');
  // await task.clear();
  await Hive.openBox<User>('users');
  // printAllUsers();
  print('Hive box opened: ${Hive.isBoxOpen('taskk')}');
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

// void printAllUsers() {
//   final usersBox = Hive.box<User>('users');

//   print("Total Users: ${usersBox.length}");

//   for (int i = 0; i < usersBox.length; i++) {
//     User? user = usersBox.getAt(i);

//     if (user != null) {
//       print("User $i:");
//       print("  UserName: ${user.username}");
//       print("  Email: ${user.email}");
//       // print("  Password: ${user.password}");
//     }
//   }
// }


class _MyAppState extends State<MyApp> {
  bool isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? ToDoPage() : RegisterUserScreen(),
    );
  }
}
