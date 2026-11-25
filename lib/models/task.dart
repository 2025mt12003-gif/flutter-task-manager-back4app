
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  final String? objectId;
  final String title;
  final String description;
  final bool isCompleted;
  final ParseUser? owner;
  final DateTime? createdAt;

  Task({
    this.objectId,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.owner,
    this.createdAt,
  });

  // Convert Back4App object into a Task model
  factory Task.fromParse(ParseObject object) {
    return Task(
      objectId: object.objectId,
      title: object.get<String>('title') ?? '',
      description: object.get<String>('description') ?? '',
      isCompleted: object.get<bool>('isCompleted') ?? false,
      owner: object.get<ParseUser>('owner'),
      createdAt: object.createdAt,
    );
  }

  // Convert Task model into a Back4App object
  ParseObject toParse() {
    final object = ParseObject('Task');

    if (objectId != null) {
      object.objectId = objectId;
    }

    object.set<String>('title', title);
    object.set<String>('description', description);
    object.set<bool>('isCompleted', isCompleted);

    if (owner != null) {
      object.set<ParseUser>('owner', owner!);
    }

    return object;
  }
}
