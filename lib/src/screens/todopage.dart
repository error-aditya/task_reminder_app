import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newtodo/src/screens/login/login.dart';
import 'package:newtodo/src/features/location_picker.dart' as location_picker;
import 'package:newtodo/src/features/notificationn.dart';
import 'package:newtodo/src/screens/search_screen.dart';
import 'package:newtodo/src/screens/settings.dart';
import 'package:newtodo/model/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final NotificationService _notificationService = NotificationService();
  Box<Task>? taskk;
  List<Task> _tasks = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';
  SpeechToText speechToText = SpeechToText();
  String selectedFilter = 'All';
  String currentUserid = "";
  DateTime? filterDate;
  DateTime? startDate;
  DateTime? endDate;
  int selectedIndex = 0;

  Widget _buildFilterButton(String filterType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (filterType == 'Select Date') {
            _selectDate(context);
          } else {
            setState(() {
              selectedFilter = filterType;
            });
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: selectedFilter == filterType
                ? Colors.blueAccent
                : Colors.white),
        child: Text(filterType),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selected != null) {
      setState(() {
        filterDate = selected;
        selectedFilter = 'Select Date';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _notificationService.initNotification();
    _notificationService.requestExactAlarmPermission();
    checkMic();
    _checkLoginStatus();
    _loadTasks();
  }

  List<Task> _filteredTasks() {
    DateTime now = DateTime.now();
    return _tasks.where((task) {
      switch (selectedFilter) {
        case 'All':
          return true;
        case 'Today':
          return isSameDay(task.alertDate, now);
        case 'Completed':
          return task.status;
        case 'Pending':
          return !task.status && task.alertDate.isBefore(now);
        case 'Upcoming':
          return !task.status && task.alertDate.isAfter(now);
        case 'Overdue':
          return !task.status && task.alertDate.isBefore(now);
        case 'Select Date':
          if (filterDate != null) {
            return isSameDay(task.alertDate, filterDate!);
          }
          return false;
        default:
          if (filterDate != null) {
            return isSameDay(task.alertDate, filterDate!);
          }
          return true;
      }
    }).toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // mic check
  void checkMic() async {
    bool micAvailable = await speechToText.initialize();

    if (micAvailable) {
      print('Mic is available');
    } else {
      print('Mic is not available');
    }
  }

  Future<void> _initializeHive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserid = prefs.getString('loggedInUserEmail') ?? '';

    if (currentUserid.isEmpty) {
      debugPrint("No user logged in");
      return;
    }

    String boxName = 'taskk_${currentUserid}';

    if (!Hive.isBoxOpen(boxName)) {
      try {
        taskk = await Hive.openBox<Task>(boxName);
        debugPrint('Hive box for user $currentUserid opened successfully');
      } catch (e) {
        debugPrint("Error opening Hive box: $e");
      }
    } else {
      taskk = Hive.box<Task>(boxName);
      debugPrint('Hive box for user $currentUserid already open');
    }

    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserid = prefs.getString('loggedInUserEmail') ?? '';

    if (currentUserid.isNotEmpty && taskk != null) {
      setState(() {
        _tasks = taskk!.values
            .where((task) => task.userId == currentUserid)
            .toList();
      });
    }
  }

  void _deleteTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      await taskk!.deleteAt(index);

      setState(() {
        _loadTasks();
      });
    } else {
      debugPrint('Error At index: $index');
    }
  }

  void _toggleTaskStatus(int index) async {
    // Get the task from the box
    final task = taskk!.getAt(index);
    if (task != null) {
      task.status = !task.status;

      await taskk!.putAt(index, task);

      setState(() {});
    }
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserid = prefs.getString('loggedInUserEmail') ?? '';

    if (currentUserid.isEmpty) {
      Get.off(LoginScreen());
    } else {
      _loadTasks();
    }
  }

  Future<void> _showAddTaskDialog() async {
    _titleController.clear();
    _descriptionController.clear();

    DateTime selectedDateTime = DateTime.now();
    bool notifyUser = true;
    bool isLocationSelected = false; // Track if location is selected

    final TextEditingController _latitudeController = TextEditingController();
    final TextEditingController _longitudeController = TextEditingController();
    final TextEditingController _radiusController = TextEditingController();
    final TextEditingController _locationController = TextEditingController();

    Future<void> _pickDateTime() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );

        if (pickedTime != null) {
          setState(() {
            selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLocationSelected = false;
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'Must', child: Text('Must')),
                        DropdownMenuItem(
                            value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                          "Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDateTime)}"),
                      leading: const Icon(Icons.calendar_today),
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Notification For Task :'),
                      value: notifyUser,
                      onChanged: (bool value) {
                        setState(() {
                          notifyUser = value;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.location_on, color: Colors.grey),
                      label: const Text("Pick Location"),
                      onPressed: () async {
                        bool? shouldPickLocation = await Get.defaultDialog(
                          title: "Add Location?",
                          middleText:
                              "Do you want to add a location for this task?",
                          textConfirm: "Yes",
                          textCancel: "No",
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            Get.back(result: true);
                          },
                          onCancel: () {
                            Get.back(result: false);
                          },
                        );

                        if (shouldPickLocation == true) {
                          String? pickedAddress = await Get.to<String?>(
                            () => location_picker.LocationPickerScreen(
                              onLocationPicked: (selectedAddress) {
                                setState(() {
                                  _locationController.text =
                                      selectedAddress; // Store Address Instead
                                  isLocationSelected =
                                      true; // Update state properly
                                });
                              },
                            ),
                          );

                          if (pickedAddress != null) {
                            setState(() {
                              _locationController.text =
                                  pickedAddress; // Store Address
                              isLocationSelected = true;
                            });
                          }
                        }
                      },
                    ),
                    TextField(
                      controller: _locationController,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Selected Location',
                        prefixIcon: isLocationSelected
                            ? const Icon(Icons.location_on, color: Colors.red)
                            : const Icon(Icons.location_on, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    currentUserid = prefs.getString('loggedInUserEmail') ?? '';

                    String userBoxName = 'task_${currentUserid}';

                    DateTime finalDateTime = DateTime(
                      selectedDateTime.year,
                      selectedDateTime.month,
                      selectedDateTime.day,
                      selectedDateTime.hour,
                      selectedDateTime.minute,
                    );

                    if (notifyUser) {
                      NotificationService().initNotification();
                      NotificationService().scheduleNotification(
                        title: _titleController.text,
                        body: _descriptionController.text,
                        scheduleDate: finalDateTime,
                        AndroidScheduleMode: null,
                      );
                      NotificationService().requestExactAlarmPermission();
                    }

                    double? latitude =
                        double.tryParse(_latitudeController.text);
                    double? longitude =
                        double.tryParse(_longitudeController.text);
                    double? radius = double.tryParse(_radiusController.text);

                    final newTask = Task(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      priority: _priority,
                      status: false,
                      date: DateTime.now(),
                      alertDate: finalDateTime,
                      userId: currentUserid,
                      latitude: latitude,
                      longitude: longitude,
                      radius: radius,
                      locationAddress:
                          _locationController.text, // Save Location
                    );

                    var taskBox = await Hive.openBox<Task>(userBoxName);
                    await taskBox.add(newTask);

                    if (taskk != null) {
                      await taskk!.add(newTask);
                    }
                    _loadTasks();

                    // Clear the fields after saving the task
                    _titleController.clear();
                    _descriptionController.clear();
                    _priority = 'Medium';
                    _latitudeController.clear();
                    _longitudeController.clear();
                    _radiusController.clear();

                    Navigator.of(context).pop();
                    Get.snackbar(
                      "Congratulations",
                      "Task Added Successfully",
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      reverseAnimationCurve: Curves.bounceIn,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilterTile('Today', LucideIcons.calendar),
              _buildFilterTile('Completed', LucideIcons.checkCircle),
              _buildFilterTile('Pending', LucideIcons.clock),
              _buildFilterTile('Upcoming', LucideIcons.calendarClock),
              _buildFilterTile('Overdue', LucideIcons.alertTriangle),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    taskk?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (taskk == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("To-Do List")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: 0,
        onTap: (value) {
          selectedIndex = value;
          if (value == 1) {
            Get.to(const Settings());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      drawer: Drawer(
        surfaceTintColor: Colors.blueAccent,
        // backgroundColor: Colors.black,
        child: ListView(children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [Color(0xFF24C6DC), Color(0xFF514A9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.blue[200]!,
                child: Text(
                  'GoDo',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {},
          ),
        ]),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF24C6DC), Color(0xFF514A9D)], // Cool Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.blue[200]!,
          child: Text(
            'GoDo',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 26),
            splashRadius: 22,
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchScreen(tasks: _tasks),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterButton('All'),
                _buildFilterButton('Today'),
                _buildFilterButton('Select Date'),
                const SizedBox(
                  width: 25,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_alt),
                  onPressed: () => _showFilterOptions(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: taskk!.listenable(),
              builder: (context, Box<Task> box, _) {
                final tasks = _filteredTasks();
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: ListTile(
                          leading: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: IconButton(
                              key: ValueKey<bool>(task.status),
                              icon: Icon(
                                task.status
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task.status ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleTaskStatus(index),
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () => _showEditTaskDialog(index),
                            child: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.status
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showEditTaskDialog(index),
                                child: Text(task.description),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _showEditTaskDialog(index),
                                child: Text(
                                  'Priority: ${task.priority}',
                                  style: TextStyle(
                                    color: _getPriorityColor(task.priority),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _showEditTaskDialog(index),
                                child: Text(
                                  'Alert Date: ${DateFormat('yyyy-MM-dd HH:mm').format(task.alertDate)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              task.latitude != null && task.longitude != null
                                  ? Icon(Icons.location_on, color: Colors.red)
                                  : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Must':
        return Colors.red;
      case 'Medium':
        return Colors.green;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  void _showEditTaskDialog(int index) {
    final task = _tasks[index];
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _priority = task.priority;
    DateTime? selectedDate = task.alertDate;
    bool notify = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'Must', child: Text('Must')),
                        DropdownMenuItem(
                            value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                selectedDate ?? DateTime.now()),
                          );
                          if (pickedTime != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: const Text(
                        'Select Alert Date',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (selectedDate != null)
                      Text(
                        'Selected Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate!)}',
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Notification For Task: '),
                        Switch(
                          value: notify,
                          onChanged: (value) {
                            setDialogState(() {
                              notify = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    )),
                ElevatedButton(
                  onPressed: () async {
                    if (notify) {
                      NotificationService().initNotification();
                      NotificationService().scheduleNotification(
                        title: _titleController.text,
                        body: _descriptionController.text,
                        scheduleDate: selectedDate!,
                        AndroidScheduleMode: null,
                      );
                      NotificationService().requestExactAlarmPermission();
                    }
                    final updatedTask = Task(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      priority: _priority,
                      status: task.status,
                      date: task.date,
                      alertDate: selectedDate!,
                      userId: task.userId,
                      locationAddress: '',
                    );
                    await taskk!.putAt(index, updatedTask);
                    _loadTasks();
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Success',
                      'Task updated successfully!',
                      backgroundColor: Colors.green,
                    );
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
