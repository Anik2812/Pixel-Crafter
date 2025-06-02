import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ShapeType { rectangle, circle, text, path }

class CanvasShape {
  final String id;
  ShapeType type;
  Offset position;
  Size size;
  Color color;
  bool isSelected;
  Color? strokeColor;
  double? strokeWidth;
  bool isVisible;

  String? textContent;
  double? fontSize;
  FontWeight? fontWeight;
  FontStyle? fontStyle;

  List<Offset>? pathPoints;

  CanvasShape({
    String? id,
    required this.type,
    required this.position,
    required this.size,
    this.color = Colors.blue,
    this.isSelected = false,
    this.strokeColor,
    this.strokeWidth,
    this.isVisible = true,
    this.textContent,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.pathPoints,
  }) : id = id ?? const Uuid().v4();

  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  CanvasShape copyWith({
    ShapeType? type,
    Offset? position,
    Size? size,
    Color? color,
    bool? isSelected,
    Color? strokeColor,
    double? strokeWidth,
    bool? isVisible,
    String? textContent,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    List<Offset>? pathPoints,
  }) {
    return CanvasShape(
      id: id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isVisible: isVisible ?? this.isVisible,
      textContent: textContent ?? this.textContent,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      pathPoints: pathPoints ?? this.pathPoints,
    );
  }
}
