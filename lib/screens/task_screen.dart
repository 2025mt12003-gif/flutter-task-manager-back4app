
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import 'login_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];

  bool _isLoading = true;
  bool _isBusy = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Fetch tasks from Back4App
  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await _taskService.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Display success or error messages
  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red : Colors.green,
      ),
    );
  }

  // Execute database operations safely
  Future<void> _performAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isBusy || !mounted) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await action();

      if (!mounted) return;

      _showMessage(successMessage);

      await _loadTasks();
    } catch (e) {
      if (mounted) {
        _showMessage(
          e.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // Add or edit task using a dedicated dialog widget
  Future<void> _showTaskDialog({Task? task}) async {
    if (_isBusy || _isLoading || !mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _TaskEditorDialog(task: task),
    );

    if (result == null || !mounted) return;

    final title = result['title']!;
    final description = result['description']!;

    if (task == null) {
      await _performAction(
        () => _taskService.createTask(
          title,
          description,
        ),
        'Task created successfully!',
      );
    } else {
      await _performAction(
        () => _taskService.updateTask(
          task.objectId!,
          title,
          description,
        ),
        'Task updated successfully!',
      );
    }
  }

  // Mark task as completed or pending
  Future<void> _toggleTask(Task task) async {
    await _performAction(
      () => _taskService.toggleTaskStatus(
        task.objectId!,
        !task.isCompleted,
      ),
      task.isCompleted
          ? 'Task marked as pending!'
          : 'Task completed successfully!',
    );
  }

  // Delete task with confirmation
  Future<void> _deleteTask(Task task) async {
    if (_isBusy || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _performAction(
      () => _taskService.deleteTask(
        task.objectId!,
      ),
      'Task deleted successfully!',
    );
  }

  // Logout from application
  Future<void> _logout() async {
    if (_isBusy || !mounted) return;

    setState(() {
      _isBusy = true;
    });

    try {
      final user =
          await ParseUser.currentUser() as ParseUser?;

      if (user != null) {
        final response = await user.logout();

        if (!response.success) {
          throw Exception(
            response.error?.message ?? 'Logout failed',
          );
        }
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showMessage(
          e.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // Dashboard summary card
  Widget _summaryCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),

              const SizedBox(height: 8),

              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Display individual task
  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: _isBusy
              ? null
              : (_) => _toggleTask(task),
        ),

        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(task.description),

            const SizedBox(height: 6),

            Text(
              task.isCompleted
                  ? 'Completed'
                  : 'Pending',

              style: TextStyle(
                color: task.isCompleted
                    ? Colors.green
                    : Colors.orange,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              tooltip: 'Edit Task',

              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),

              onPressed: _isBusy
                  ? null
                  : () => _showTaskDialog(task: task),
            ),

            IconButton(
              tooltip: 'Delete Task',

              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),

              onPressed: _isBusy
                  ? null
                  : () => _deleteTask(task),
            ),
          ],
        ),
      ),
    );
  }

  // Main dashboard UI
  @override
  Widget build(BuildContext context) {
    final completed = _tasks
        .where((task) => task.isCompleted)
        .length;

    final pending = _tasks.length - completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            tooltip: 'Refresh',

            icon: const Icon(Icons.refresh),

            onPressed: _isBusy || _isLoading
                ? null
                : _loadTasks,
          ),

          IconButton(
            tooltip: 'Logout',

            icon: const Icon(Icons.logout),

            onPressed: _isBusy
                ? null
                : _logout,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBusy || _isLoading
            ? null
            : () => _showTaskDialog(),

        icon: const Icon(Icons.add),

        label: const Text('Add Task'),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'My Tasks',

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Task statistics
                Row(
                  children: [
                    _summaryCard(
                      'Total',
                      _tasks.length,
                      Colors.blue,
                      Icons.assignment,
                    ),

                    _summaryCard(
                      'Pending',
                      pending,
                      Colors.orange,
                      Icons.pending_actions,
                    ),

                    _summaryCard(
                      'Completed',
                      completed,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (_isBusy)
                  const LinearProgressIndicator(),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )

                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Text(_error!),

                                  const SizedBox(height: 12),

                                  ElevatedButton(
                                    onPressed: _isBusy
                                        ? null
                                        : _loadTasks,

                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )

                          : _tasks.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 70,
                                        color: Colors.grey,
                                      ),

                                      SizedBox(height: 16),

                                      Text(
                                        'No tasks available',

                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      Text(
                                        'Click Add Task to create one.',
                                      ),
                                    ],
                                  ),
                                )

                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    bottom: 80,
                                  ),

                                  itemCount: _tasks.length,

                                  itemBuilder: (context, index) {
                                    return _buildTaskCard(
                                      _tasks[index],
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// Dedicated Add/Edit Task Dialog
// Controllers are owned and disposed by the dialog itself.
// ==========================================================

class _TaskEditorDialog extends StatefulWidget {
  final Task? task;

  const _TaskEditorDialog({
    this.task,
  });

  @override
  State<_TaskEditorDialog> createState() =>
      _TaskEditorDialogState();
}

class _TaskEditorDialogState
    extends State<_TaskEditorDialog> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  // Dispose controllers only when Flutter removes the dialog
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // Validate and return task data
  void _save() {
    if (_isClosing) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isClosing = true;

    final result = <String, String>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    // Remove keyboard focus before closing dialog
    FocusScope.of(context).unfocus();

    // Return values instead of disposing controllers here
    Navigator.of(context).pop(result);
  }

  // Cancel without saving changes
  void _cancel() {
    if (_isClosing) return;

    _isClosing = true;

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Task' : 'Add Task',
      ),

      content: SizedBox(
        width: 400,

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(
                  controller: _titleController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,

                  maxLines: 3,

                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _save,

          child: Text(
            isEditing ? 'Save' : 'Add',
          ),
        ),
      ],
    );
  }
}
