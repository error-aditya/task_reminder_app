import 'package:flutter/material.dart';
import 'package:newtodo/authentication/login.dart';
import 'package:newtodo/notificationn.dart';
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
      backgroundColor: _isDarkTheme ? Colors.black : Colors.white,
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
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              toggleNotification(value);
            },
            subtitle: Text(
              _notificationsEnabled
                  ? 'Notifications Are On'
                  : 'Notifications Are Off',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text(
              "Account Settings",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          SwitchListTile(
              title: const Text(
                'Dark Theme',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              value: _isDarkTheme,
              onChanged: (bool value) {
                toggleTheme(value);
              }),
          ListTile(
            title: Text(
              "Task Settings",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              "Backup and Restore",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              "Help & Support",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
