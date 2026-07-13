import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class EditTaskScreen extends StatefulWidget {
  EditTaskScreen({super.key, required this.task});
  Task task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _titleController;
  DateTime? _selectedDate;
  late TextEditingController _dateController;
  String? _selectedPriority;

  @override
  void initState() {
    _selectedDate = widget.task.dueDate;

    // 2. Initialize the controller with the formatted existing date (if it exists)
    String initialDateText = '';
    if (_selectedDate != null) {
      initialDateText =
          "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
    }
    _dateController = TextEditingController(text: initialDateText);

    _selectedPriority = widget.task.priority;

    // 2. Initialize it with the existing task value
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
  }

  @override
  void dispose() {
    // 3. Always clean up controllers when the widget is destroyed
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _selectedDate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Edit Task'),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction
                    .next, // Moves cursor to description box automatically when clicking 'done'
                decoration: InputDecoration(
                  hintText: 'Enter task title...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Consistent premium curved edges
                  ),
                ),
              ),

              const SizedBox(height: 24.0),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _descriptionController,
                textInputAction:
                    TextInputAction.newline, // Allows multi-line input
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter task description...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              const Text(
                'Due Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),

              TextFormField(
                controller: _dateController, // Displays the value reliably
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDate ??
                        DateTime.now(), // Fallback to now if task had no date
                    firstDate: DateTime(
                      2000,
                    ), // Allowed past/current dates during edit if needed
                    lastDate: DateTime(2030),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      // Update the text field display dynamically
                      _dateController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Due Date', // Floating label looks more premium
                  hintText: 'Select a date...',
                  suffixIcon: const Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                // 1. FIX: Place the safety fallback check HERE on the Dropdown itself
                value: ['Low', 'Medium', 'High'].contains(_selectedPriority)
                    ? _selectedPriority
                    : null,
                hint: const Text(
                  'Select priority level...',
                  style: TextStyle(color: Colors.grey),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                // 2. FIX: Keep individual item values static and simple
                items: [
                  DropdownMenuItem(
                    value: 'Low',
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.green, size: 12),
                        SizedBox(width: 8),
                        Text('Low'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.amber, size: 12),
                        SizedBox(width: 8),
                        Text('Medium'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'High',
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.red, size: 12),
                        SizedBox(width: 8),
                        Text('High'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
              ),

              const SizedBox(height: 24.0),

              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return;
                  }

                  // ✅ FIX: Create a new task object with the updated values
                  final updatedTask = Task(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDate,
                    priority: _selectedPriority,
                    isCompleted: widget.task.isCompleted, // Preserve status
                    isFavourite: widget.task.isFavourite, // Preserve favourite
                  );

                  // Return the updated task
                  Navigator.pop(context, updatedTask);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save Task"),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // 1. (Optional) Show a confirmation dialog before deleting
                  // 2. Pop the context and pass back a signal (like 'true' or the task ID) to delete it
                  Navigator.pop(context, "delete");
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor:
                      Colors.red, // 👈 Good practice: Make delete buttons red
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Delete Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
