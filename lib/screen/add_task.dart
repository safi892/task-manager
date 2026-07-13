import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  DateTime? _selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _selectedPriority;
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
        title: const Text('Add Task'),
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
                controller: titleController,
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
                controller: descriptionController,
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
                readOnly: true, // Prevents keyboard from showing up
                onTap: () async {
                  // 1. Opens the native, premium Material calendar pop-up
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(), // Prevents picking past dates
                    lastDate: DateTime(2030), // Maximum year boundary
                  );

                  // 2. If the user didn't cancel, save the date and refresh the UI
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                decoration: InputDecoration(
                  // Displays the chosen date formatted, or a placeholder if empty
                  hintText: _selectedDate == null
                      ? 'Select a date...'
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  hintStyle: TextStyle(
                    color: _selectedDate == null
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today_rounded,
                  ), // Adds a calendar icon on the right side
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 24.0),

              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                hint: const Text(
                  'Select priority level...',
                  style: TextStyle(color: Colors.grey),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
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
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return;
                  }

                  // 2. Create the task object with all the collected data
                  final task = Task(
                    title: titleController.text,
                    description: descriptionController.text,
                    dueDate: _selectedDate, // Passed the picked date
                    priority: _selectedPriority, // Passed the picked priority
                  );

                  // 3. Return the complete task object back to the previous screen
                  Navigator.pop(context, task);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
