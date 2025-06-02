import 'package:flutter/material.dart';
import 'package:replica/models/shape.dart';
import 'package:replica/constants/colors.dart';

class TemplateData {
  static List<CanvasShape> basicDashboard() {
    return [
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(50, 50),
        size: const Size(400, 250),
        color: Colors.lightBlue.withOpacity(0.3),
        strokeColor: AppColors.primaryBlue,
        strokeWidth: 2,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(60, 60),
        size: const Size(200, 30),
        textContent: 'Dashboard Layout',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(70, 110),
        size: const Size(100, 80),
        color: Colors.green.withOpacity(0.5),
        strokeColor: Colors.green.shade800,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.circle,
        position: const Offset(190, 110),
        size: const Size(80, 80),
        color: Colors.orange.withOpacity(0.5),
        strokeColor: Colors.orange.shade800,
        strokeWidth: 1,
      ),
    ];
  }

  static List<CanvasShape> landingPageWireframe() {
    return [
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(50, 50),
        size: const Size(600, 50),
        color: Colors.grey.withOpacity(0.2),
        strokeColor: Colors.grey.shade600,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(60, 60),
        size: const Size(100, 20),
        textContent: 'Header',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(50, 120),
        size: const Size(600, 200),
        color: Colors.purple.withOpacity(0.2),
        strokeColor: AppColors.accentPurple,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(150, 200),
        size: const Size(300, 40),
        textContent: 'Hero Section',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.accentPurple,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(50, 350),
        size: const Size(280, 150),
        color: Colors.teal.withOpacity(0.2),
        strokeColor: AppColors.accentGreen,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(370, 350),
        size: const Size(280, 150),
        color: Colors.teal.withOpacity(0.2),
        strokeColor: AppColors.accentGreen,
        strokeWidth: 1,
      ),
    ];
  }

  static List<CanvasShape> mobileAppScreen() {
    return [
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(100, 50),
        size: const Size(300, 550),
        color: Colors.black, // Phone frame
        strokeColor: Colors.white,
        strokeWidth: 2,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(110, 60),
        size: const Size(280, 530),
        color: Colors.blueGrey.shade800,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(120, 70),
        size: const Size(260, 40),
        color: Colors.grey.shade700,
      ), // App bar
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(130, 80),
        size: const Size(100, 20),
        textContent: 'My App',
        fontSize: 18,
        color: Colors.white,
      ),
      CanvasShape(
        type: ShapeType.circle,
        position: const Offset(130, 140),
        size: const Size(60, 60),
        color: Colors.pink.withOpacity(0.5),
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(210, 140),
        size: const Size(150, 20),
        color: Colors.blue.withOpacity(0.5),
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(210, 170),
        size: const Size(120, 20),
        color: Colors.blue.withOpacity(0.5),
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(120, 480),
        size: const Size(260, 40),
        color: Colors.deepPurple.withOpacity(0.5),
      ), // Bottom Nav
    ];
  }

  static List<CanvasShape> flowChart() {
    return [
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(150, 50),
        size: const Size(150, 60),
        color: Colors.teal.withOpacity(0.3),
        strokeColor: Colors.teal,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(180, 70),
        size: const Size(100, 20),
        textContent: 'Start',
        fontSize: 18,
        color: Colors.teal.shade800,
      ),
      CanvasShape(
        type: ShapeType.path,
        position: const Offset(225, 110),
        size: const Size(100, 80),
        pathPoints: [
          const Offset(225, 110),
          const Offset(225, 150),
        ],
        color: Colors.grey.shade600,
        strokeWidth: 2,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(150, 150),
        size: const Size(150, 60),
        color: Colors.amber.withOpacity(0.3),
        strokeColor: Colors.amber.shade800,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(160, 170),
        size: const Size(130, 20),
        textContent: 'Process Data',
        fontSize: 18,
        color: Colors.amber.shade800,
      ),
      CanvasShape(
        type: ShapeType.path,
        position: const Offset(225, 210),
        size: const Size(100, 80),
        pathPoints: [
          const Offset(225, 210),
          const Offset(225, 250),
        ],
        color: Colors.grey.shade600,
        strokeWidth: 2,
      ),
      CanvasShape(
        type: ShapeType.rectangle,
        position: const Offset(150, 250),
        size: const Size(150, 60),
        color: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red.shade800,
        strokeWidth: 1,
      ),
      CanvasShape(
        type: ShapeType.text,
        position: const Offset(180, 270),
        size: const Size(100, 20),
        textContent: 'End',
        fontSize: 18,
        color: Colors.red.shade800,
      ),
    ];
  }
}
