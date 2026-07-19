import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/helpers/date_extensions.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/firestore_service.dart';
import 'package:task_manager/screen/add_task.dart';
import 'package:task_manager/screen/task_details.dart';

class Home extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const Home({super.key, required this.onToggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

enum TaskStatus { all, pending, completed }

class CustomStatus extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomStatus({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(41.0)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? priority;
  final bool isCompleted;
  final bool isFavourite;

  final ValueChanged<bool?> onStatusChanged;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.onStatusChanged,
    required this.onFavouriteToggle,
    required this.onTap,
    this.dueDate,
    this.priority,
    this.isCompleted = false,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Checkbox(
                value: isCompleted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                onChanged: onStatusChanged,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: colorScheme.onSurface.withValues(alpha: 0.5),
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    if (dueDate != null)
                      Text(
                        "${DateFormat('MMMM dd, yyyy').format(dueDate!)} • ${dueDate!.toRelativeDateString()}",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavouriteToggle,
                icon: Icon(
                  isFavourite ? Icons.star : Icons.star_border,
                  color: isFavourite ? Colors.amber : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeState extends State<Home> {
  final _firestore = FirestoreService.instance;
  String selectedStatus = 'All';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomStatus(
                  title: 'All',
                  isSelected: selectedStatus == 'All',
                  onTap: () {
                    setState(() {
                      selectedStatus = 'All';
                    });
                  },
                ),
                CustomStatus(
                  title: 'Pending',
                  isSelected: selectedStatus == 'Pending',
                  onTap: () {
                    setState(() {
                      selectedStatus = 'Pending';
                    });
                  },
                ),
                CustomStatus(
                  title: 'Completed',
                  isSelected: selectedStatus == 'Completed',
                  onTap: () {
                    setState(() {
                      selectedStatus = 'Completed';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _firestore.streamTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data ?? [];
                  final filteredTasks = tasks.where((task) {
                    if (_searchQuery.isNotEmpty) {
                      final matchesSearch =
                          task.title.toLowerCase().contains(_searchQuery);
                      if (!matchesSearch) return false;
                    }
                    if (selectedStatus == 'Pending') {
                      return !task.isCompleted;
                    } else if (selectedStatus == 'Completed') {
                      return task.isCompleted;
                    }
                    return true;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No tasks match your search'
                            : selectedStatus == 'All'
                                ? 'No tasks yet. Tap + to add one!'
                                : 'No ${selectedStatus.toLowerCase()} tasks',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          title: task.title,
                          description: task.description,
                          dueDate: task.dueDate,
                          priority: task.priority,
                          isCompleted: task.isCompleted,
                          isFavourite: task.isFavourite,
                          onStatusChanged: (bool? value) {
                            if (value != null && task.uid != null) {
                              _firestore.toggleTaskStatus(task.uid!, value);
                            }
                          },
                          onFavouriteToggle: () {
                            if (task.uid != null) {
                              _firestore.toggleTaskFavourite(
                                task.uid!,
                                !task.isFavourite,
                              );
                            }
                          },
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetails(task: task),
                              ),
                            );

                            if (result == "delete" && task.uid != null) {
                              _firestore.deleteTask(task.uid!);
                            } else if (result != null && result is Task) {
                              _firestore.updateTask(result);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTask()),
          );

          if (newTask != null) {
            _firestore.addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
