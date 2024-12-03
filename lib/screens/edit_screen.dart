import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/home_screen.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController dueDateController;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.task.dueDate.toUtc()),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate.toUtc());
    }
  }

  Future<bool> updateTask(String objectId, String title, DateTime dueDate) async {
    final parseObject = ParseObject('Task')
      ..objectId = objectId
      ..set('title', title)
      ..set('dueDate', DateTime.utc(dueDate.year, dueDate.month, dueDate.day));

    final response = await parseObject.save();
    return response.success;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Task',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: dueDateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              labelText: 'Due Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
          SizedBox(height: 20),
          MouseRegion(
            onEnter: (_) => setState(() => isHovering = true),
            onExit: (_) => setState(() => isHovering = false),
            child: ElevatedButton(
              onPressed: () async {
                final updatedTitle = titleController.text.trim();
                final updatedDueDate = DateTime.parse(dueDateController.text.trim()).toUtc();

                final success = await updateTask(widget.task.objectId, updatedTitle, DateTime.utc(updatedDueDate.year, updatedDueDate.month, updatedDueDate.day));

                if (success) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update task.')),
                  );
                }
              },
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isHovering ? Colors.tealAccent : Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}