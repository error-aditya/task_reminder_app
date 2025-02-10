import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newtodo/src/screens/login/login.dart';
import 'package:newtodo/src/features/notificationn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _isDarkTheme = true;
  // String _userEmail = '';
  // String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    bool isDarkTheme = prefs.getBool('isDarkTheme') ?? true;

    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _isDarkTheme = isDarkTheme;
    });
  }

  Future<void> toggleNotification(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
    await _notificationService.toggleNotification(value);
  }

  Future<void> toggleTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', value);
  }

  // it won't show the back option or route will be closed
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserEmail');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 138, 186),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text(
              'Enable Notifications For Tasks',
              style:
                  TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              toggleNotification(value);
            },
            subtitle: Text(
              _notificationsEnabled
                  ? 'Notifications Are On'
                  : 'Notifications Are Off',
            ),
          ),
          ListTile(
            title: const Text(
              "Account Settings",
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.light_mode),
            title: Text('Light Theme'),
            onTap: () {
              Get.changeTheme(ThemeData.light());
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Theme'),
            onTap: () {
              Get.changeTheme(ThemeData.dark());
            },
          ),
          ListTile(
            title: const Text(
              "Task Settings",
            ),
            onTap: () {},
          ),
          Column(
            children: [
              ListTile(
                title: const Text(
                  "Backup and Restore",
                ),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            title: const Text(
              "Help & Support",
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              "Log Out",
              style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
