import 'package:flutter/material.dart';
import 'package:replica/models/project.dart';
import 'package:replica/models/shape.dart';
import 'package:replica/constants/template_data.dart';

class ProjectService extends ChangeNotifier {
  final List<Project> _recentFiles = [];
  final List<Project> _templates = [];

  List<Project> get recentFiles => _recentFiles;
  List<Project> get templates => _templates;

  ProjectService() {
    _initializeData();
  }

  void _initializeData() {
    _recentFiles.add(Project(
      name: 'My First Design',
      lastModified: DateTime.now().subtract(const Duration(hours: 1)),
      canvasShapes: [
        CanvasShape(
            type: ShapeType.rectangle,
            position: const Offset(50, 50),
            size: const Size(100, 100),
            color: Colors.blue),
        CanvasShape(
            type: ShapeType.circle,
            position: const Offset(180, 150),
            size: const Size(80, 80),
            color: Colors.green),
        CanvasShape(
            type: ShapeType.text,
            position: const Offset(250, 50),
            size: const Size(150, 30),
            textContent: 'Hello World',
            fontSize: 20,
            color: Colors.purple),
      ],
    ));
    _recentFiles.add(Project(
      name: 'Website Mockup V2',
      lastModified: DateTime.now().subtract(const Duration(days: 2)),
      canvasShapes: TemplateData.landingPageWireframe(),
    ));
    _recentFiles.add(Project(
      name: 'Mobile App Flow',
      lastModified: DateTime.now().subtract(const Duration(hours: 5)),
      canvasShapes: TemplateData.mobileAppScreen(),
    ));

    _templates.add(Project(
      name: 'Basic Dashboard Layout',
      type: ProjectType.template,
      canvasShapes: TemplateData.basicDashboard(),
    ));
    _templates.add(Project(
      name: 'Landing Page Wireframe',
      type: ProjectType.template,
      canvasShapes: TemplateData.landingPageWireframe(),
    ));
    _templates.add(Project(
      name: 'Mobile App Screen',
      type: ProjectType.template,
      canvasShapes: TemplateData.mobileAppScreen(),
    ));
    _templates.add(Project(
      name: 'Flow Chart Diagram',
      type: ProjectType.template,
      canvasShapes: TemplateData.flowChart(),
    ));
  }

  Project createNewFile(String name, {List<CanvasShape>? initialShapes}) {
    final newFile = Project(
      name: name,
      canvasShapes: initialShapes ?? [],
      type: ProjectType.file,
    );
    _recentFiles.insert(0, newFile);
    notifyListeners();
    return newFile;
  }

  void updateProject(Project updatedProject) {
    int index = _recentFiles.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _recentFiles[index] =
          updatedProject.copyWith(lastModified: DateTime.now());
      notifyListeners();
    }
  }

  Project? getProjectById(String id) {
    return _recentFiles.firstWhere((p) => p.id == id,
        orElse: () => _templates.firstWhere((t) => t.id == id,
            orElse: () => Project(name: 'Not Found', id: '')));
  }
}
