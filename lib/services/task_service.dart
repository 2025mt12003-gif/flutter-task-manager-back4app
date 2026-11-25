
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task.dart';

class TaskService {
  // Get the currently logged-in user
  Future<ParseUser> _getCurrentUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user;
  }

  // CREATE: Add a new task
  Future<void> createTask(
    String title,
    String description,
  ) async {
    final user = await _getCurrentUser();

    final task = ParseObject('Task')
      ..set<String>('title', title)
      ..set<String>('description', description)
      ..set<bool>('isCompleted', false)
      ..set<ParseUser>('owner', user);

    // Restrict task access to its owner
    final acl = ParseACL(owner: user);
    acl.setPublicReadAccess(allowed: false);
    acl.setPublicWriteAccess(allowed: false);

    task.setACL(acl);

    final response = await task.save();

    if (!response.success) {
      throw Exception(
        response.error?.message ?? 'Failed to create task',
      );
    }
  }

  // READ: Fetch tasks belonging to the logged-in user
  Future<List<Task>> getTasks() async {
    final user = await _getCurrentUser();

    final query = QueryBuilder<ParseObject>(
      ParseObject('Task'),
    )
      ..whereEqualTo('owner', user)
      ..orderByDescending('createdAt');

    final response = await query.query();

    if (!response.success) {
      throw Exception(
        response.error?.message ?? 'Failed to fetch tasks',
      );
    }

    return (response.results ?? [])
        .map((object) => Task.fromParse(object as ParseObject))
        .toList();
  }

  // UPDATE: Edit an existing task
  Future<void> updateTask(
    String objectId,
    String title,
    String description,
  ) async {
    await _getCurrentUser();

    final task = ParseObject('Task')
      ..objectId = objectId
      ..set<String>('title', title)
      ..set<String>('description', description);

    final response = await task.save();

    if (!response.success) {
      throw Exception(
        response.error?.message ?? 'Failed to update task',
      );
    }
  }

  // UPDATE: Mark task as completed or pending
  Future<void> toggleTaskStatus(
    String objectId,
    bool isCompleted,
  ) async {
    await _getCurrentUser();

    final task = ParseObject('Task')
      ..objectId = objectId
      ..set<bool>('isCompleted', isCompleted);

    final response = await task.save();

    if (!response.success) {
      throw Exception(
        response.error?.message ?? 'Failed to update task status',
      );
    }
  }

  // DELETE: Remove an existing task
  Future<void> deleteTask(String objectId) async {
    await _getCurrentUser();

    final task = ParseObject('Task')
      ..objectId = objectId;

    final response = await task.delete();

    if (!response.success) {
      throw Exception(
        response.error?.message ?? 'Failed to delete task',
      );
    }
  }
}
