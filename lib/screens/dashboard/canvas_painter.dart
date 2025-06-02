import 'package:flutter/material.dart';
import 'package:replica/models/shape.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';

class CanvasPainter extends CustomPainter {
  final List<CanvasShape> shapes;
  final Offset canvasOffset;
  final double canvasScale;
  final bool isDarkMode;
  final List<Offset> currentPathPoints;
  final bool isDrawingMode;

  CanvasPainter({
    required this.shapes,
    required this.canvasOffset,
    required this.canvasScale,
    required this.isDarkMode,
    required this.currentPathPoints,
    required this.isDrawingMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = isDarkMode
          ? AppColors.canvasBackgroundDark
          : AppColors.canvasBackgroundLight;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(canvasScale);

    final gridPaint = Paint()
      ..color = isDarkMode
          ? AppColors.canvasGridLineDark
          : AppColors.canvasGridLineLight
      ..strokeWidth = 1;

    const double gridSize = 20.0;
    for (double i = 0;
        i < size.width * (1 / canvasScale) + gridSize;
        i += gridSize) {
      canvas.drawLine(Offset(i, 0),
          Offset(i, size.height * (1 / canvasScale) + gridSize), gridPaint);
    }
    for (double i = 0;
        i < size.height * (1 / canvasScale) + gridSize;
        i += gridSize) {
      canvas.drawLine(Offset(0, i),
          Offset(size.width * (1 / canvasScale) + gridSize, i), gridPaint);
    }

    for (var shape in shapes) {
      if (shape.isVisible) {
        // Only draw visible shapes
        _drawShape(canvas, shape);
      }
    }

    if (isDrawingMode && currentPathPoints.isNotEmpty) {
      final pathPaint = Paint()
        ..color = AppColors.accentRed
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 4.0;
      final path = Path();
      path.moveTo(currentPathPoints.first.dx, currentPathPoints.first.dy);
      for (int i = 1; i < currentPathPoints.length; i++) {
        path.lineTo(currentPathPoints[i].dx, currentPathPoints[i].dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    canvas.restore();
  }

  void _drawShape(Canvas canvas, CanvasShape shape) {
    final paint = Paint()..color = shape.color;
    final strokePaint = Paint()
      ..color = shape.strokeColor ?? Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = shape.strokeWidth ?? 1.0;

    if (shape.type == ShapeType.rectangle) {
      canvas.drawRect(shape.rect, paint);
      canvas.drawRect(shape.rect, strokePaint);
    } else if (shape.type == ShapeType.circle) {
      canvas.drawCircle(shape.rect.center, shape.size.width / 2, paint);
      canvas.drawCircle(shape.rect.center, shape.size.width / 2, strokePaint);
    } else if (shape.type == ShapeType.text && shape.textContent != null) {
      final textStyle = TextStyle(
        color: shape.color,
        fontSize: shape.fontSize,
        fontWeight: shape.fontWeight,
        fontStyle: shape.fontStyle,
      );
      final textSpan = TextSpan(text: shape.textContent, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: shape.size.width);
      textPainter.paint(canvas, shape.position);
      // text shapes don't typically have a stroke on their bounding box unless specified
      // canvas.drawRect(shape.rect, strokePaint); // Can be uncommented for text bounding box stroke
    } else if (shape.type == ShapeType.path &&
        shape.pathPoints != null &&
        shape.pathPoints!.isNotEmpty) {
      final pathPaint = Paint()
        ..color = shape.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = shape.strokeWidth ?? 4.0;
      final path = Path();
      path.moveTo(shape.pathPoints!.first.dx, shape.pathPoints!.first.dy);
      for (int i = 1; i < shape.pathPoints!.length; i++) {
        path.lineTo(shape.pathPoints![i].dx, shape.pathPoints![i].dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    if (shape.isSelected) {
      final selectionPaint = Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / canvasScale;
      final selectionRect = shape.rect.inflate(4.0 / canvasScale);
      canvas.drawRect(selectionRect, selectionPaint);

      final handlePaint = Paint()..color = AppColors.primaryBlue;
      const double handleSize = 8.0;

      canvas.drawRect(
          Rect.fromLTWH(
              selectionRect.left - handleSize / 2 / canvasScale,
              selectionRect.top - handleSize / 2 / canvasScale,
              handleSize / canvasScale,
              handleSize / canvasScale),
          handlePaint);
      canvas.drawRect(
          Rect.fromLTWH(
              selectionRect.right - handleSize / 2 / canvasScale,
              selectionRect.top - handleSize / 2 / canvasScale,
              handleSize / canvasScale,
              handleSize / canvasScale),
          handlePaint);
      canvas.drawRect(
          Rect.fromLTWH(
              selectionRect.left - handleSize / 2 / canvasScale,
              selectionRect.bottom - handleSize / 2 / canvasScale,
              handleSize / canvasScale,
              handleSize / canvasScale),
          handlePaint);
      canvas.drawRect(
          Rect.fromLTWH(
              selectionRect.right - handleSize / 2 / canvasScale,
              selectionRect.bottom - handleSize / 2 / canvasScale,
              handleSize / canvasScale,
              handleSize / canvasScale),
          handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CanvasPainter) {
      return oldDelegate.shapes !=
              shapes || // Deep comparison of list content would be better for performance in large apps
          oldDelegate.canvasOffset != canvasOffset ||
          oldDelegate.canvasScale != canvasScale ||
          oldDelegate.isDarkMode != isDarkMode ||
          oldDelegate.currentPathPoints != currentPathPoints ||
          oldDelegate.isDrawingMode != isDrawingMode;
    }
    return true;
  }
}
