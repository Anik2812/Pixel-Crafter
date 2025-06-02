import 'package:replica/models/shape.dart';
import 'package:uuid/uuid.dart';

enum ProjectType { file, template }

class Project {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime lastModified;
  final ProjectType type;
  List<CanvasShape> canvasShapes;

  String? thumbnailUrl;

  Project({
    String? id,
    required this.name,
    DateTime? createdAt,
    DateTime? lastModified,
    this.type = ProjectType.file,
    List<CanvasShape>? canvasShapes,
    this.thumbnailUrl,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        canvasShapes = canvasShapes ?? [];

  Project copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastModified,
    ProjectType? type,
    List<CanvasShape>? canvasShapes,
    String? thumbnailUrl,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      type: type ?? this.type,
      canvasShapes: canvasShapes ?? this.canvasShapes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
