import 'package:flutter/material.dart';
import 'package:newtodo/model/task.dart';

class SearchScreen extends SearchDelegate {
  final List<Task> tasks;

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  SearchScreen({required this.tasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredTasks = tasks
        .where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase().trim()))
        .toList();

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text('No tasks found.'),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Text(
            'Priority: ${task.priority}',
            style: TextStyle(color: _getPriorityColor(task.priority)),
          ),
          onTap: () {
            // Add any functionality for the task when tapped
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink(); // Blank screen before search
    }

    return buildResults(context);
  }
}
