import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TaskDialogController extends GetxController {
  var taskTitle = ''.obs;
  var taskDescription = ''.obs;
  var taskPriority = 'Medium'.obs;
  var alertDateTime = DateTime.now().obs;
  var selectedLocation = LatLng(0, 0).obs;
  var selectedLocationText = ''.obs;
  var notifyUser = true.obs;
}

Future<void> showTaskDialog(BuildContext context) {
  final TaskDialogController controller = Get.put(TaskDialogController());

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Field
              TextField(
                decoration: InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.taskTitle.value = value,
              ),
              const SizedBox(height: 12),

              // Description Field
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Task Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.taskDescription.value = value,
              ),
              const SizedBox(height: 12),

              // Priority Dropdown
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.taskPriority.value,
                  decoration: InputDecoration(
                    labelText: "Task Priority",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ["High", "Medium", "Low"]
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) => controller.taskPriority.value = value!,
                ),
              ),
              const SizedBox(height: 12),

              // Date-Time Picker
              Obx(
                () => ListTile(
                  leading: const Icon(Icons.notifications_active_rounded,
                      color: Colors.blue),
                  title: const Text("Alert Date & Time",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                      .format(controller.alertDateTime.value)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.alertDateTime.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              controller.alertDateTime.value),
                        );
                        if (pickedTime != null) {
                          controller.alertDateTime.value = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notification Toggle
              Obx(
                () => SwitchListTile(
                  title: const Text("Enable Notification"),
                  value: controller.notifyUser.value,
                  onChanged: (value) => controller.notifyUser.value = value,
                ),
              ),
              const SizedBox(height: 12),

              // Location Picker
              Obx(
                () => ListTile(
                  leading: const Icon(Icons.location_pin, color: Colors.red),
                  title: const Text("Select Task Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(controller.selectedLocationText.value.isEmpty
                      ? "No location selected"
                      : controller.selectedLocationText.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () async {
                      Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      controller.selectedLocation.value =
                          LatLng(position.latitude, position.longitude);
                      controller.selectedLocationText.value =
                          "Lat: ${position.latitude}, Lng: ${position.longitude}";
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Save Task Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.snackbar(
                    "Task Saved!",
                    "Task '${controller.taskTitle.value}' has been added successfully.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade200,
                    borderRadius: 12,
                  );
                },
                child: const Center(
                  child: Text(
                    "Save Task",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
