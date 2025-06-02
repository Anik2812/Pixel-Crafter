import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';
import 'package:replica/models/shape.dart';
import 'package:replica/screens/dashboard/canvas_painter.dart';
import 'package:replica/widgets/color_picker_button.dart';
import 'package:replica/models/project.dart';
import 'package:replica/services/project_service.dart';

enum CanvasTool { select, rectangle, circle, text, path, pan }

class DashboardPage extends StatefulWidget {
  final Project project; // Now receives a Project object

  const DashboardPage({super.key, required this.project});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Project _currentProject; // Manage the current project
  List<CanvasShape> _shapes = [];
  CanvasShape? _selectedShape;
  Offset? _startDragPosition;
  Offset? _initialShapePosition;
  Offset? _initialShapeSize;

  Offset _canvasOffset = Offset.zero;
  double _canvasScale = 1.0;
  Offset? _lastPanPoint;

  CanvasTool _currentTool = CanvasTool.select;
  List<Offset> _currentPathPoints = [];

  bool _isLeftPanelOpen = true;
  bool _isRightPanelOpen = true;

  // Undo/Redo History
  final List<List<CanvasShape>> _undoStack = [];
  final List<List<CanvasShape>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _shapes = List.from(_currentProject.canvasShapes.map(
        (s) => s.copyWith(isSelected: false))); // Ensure no selection on load
    _pushStateToUndoStack(); // Save initial state
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.project.id != oldWidget.project.id) {
      // If a new project is loaded, reset everything
      _currentProject = widget.project;
      _shapes = List.from(_currentProject.canvasShapes
          .map((s) => s.copyWith(isSelected: false)));
      _selectedShape = null;
      _undoStack.clear();
      _redoStack.clear();
      _pushStateToUndoStack();
      _canvasOffset = Offset.zero;
      _canvasScale = 1.0;
    }
  }

  void _pushStateToUndoStack() {
    _undoStack
        .add(List.from(_shapes.map((s) => s.copyWith()))); // Deep copy shapes
    _redoStack.clear(); // Clear redo stack on new action
    _updateProjectInService();
  }

  void _undo() {
    if (_undoStack.length > 1) {
      _redoStack.add(_undoStack.removeLast());
      setState(() {
        _shapes = _undoStack.last.map((s) => s.copyWith()).toList();
        _selectedShape = null; // Deselect on undo
      });
      _updateProjectInService();
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final newState = _redoStack.removeLast();
      _undoStack.add(newState);
      setState(() {
        _shapes = newState.map((s) => s.copyWith()).toList();
        _selectedShape = null; // Deselect on redo
      });
      _updateProjectInService();
    }
  }

  void _updateProjectInService() {
    final projectService = Provider.of<ProjectService>(context, listen: false);
    _currentProject.canvasShapes = List.from(_shapes.map((s) => s.copyWith()));
    projectService.updateProject(_currentProject);
  }

  void _addShape(ShapeType type) {
    _selectShape(null); // Deselect any currently selected shape
    final newShape = CanvasShape(
      type: type,
      position: (_canvasOffset * -1 + const Offset(50, 50)) /
          _canvasScale, // Adjusted for current canvas view
      size: const Size(100, 100),
      color: Colors.primaries[_shapes.length % Colors.primaries.length],
      strokeColor: Colors.black.withOpacity(0.5),
      strokeWidth: 1.0,
      isVisible: true,
    );
    if (type == ShapeType.text) {
      _showTextInputDialog(newShape);
    } else {
      setState(() {
        _shapes.add(newShape);
        _selectShape(newShape.id);
        _currentTool = CanvasTool.select;
        _pushStateToUndoStack();
      });
    }
  }

  void _showTextInputDialog(CanvasShape newShape) {
    final TextEditingController textController =
        TextEditingController(text: newShape.textContent);
    showDialog(
      context: context,
      builder: (context) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Text('Enter Text',
              style: isDarkMode
                  ? AppTextStyles.headlineSmallDark
                  : AppTextStyles.headlineSmall),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type your text here',
              hintStyle: isDarkMode
                  ? AppTextStyles.bodyMediumDark
                      .copyWith(color: AppColors.textSecondaryDark)
                  : AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondaryLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.borderColorDark
                        : AppColors.borderColorLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.borderColorDark
                        : AppColors.borderColorLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
            style: isDarkMode
                ? AppTextStyles.bodyMediumDark
                : AppTextStyles.bodyMedium,
            cursorColor: AppColors.primaryBlue,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: isDarkMode
                      ? AppTextStyles.bodyMediumDark
                          .copyWith(color: AppColors.textSecondaryDark)
                      : AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondaryLight)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  final textShape = newShape.copyWith(
                    textContent: textController.text,
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    // Temporarily calculate size, it will re-render correctly
                    size: _calculateTextSize(textController.text, 24).size,
                  );
                  setState(() {
                    _shapes.add(textShape);
                    _selectShape(textShape.id);
                    _currentTool = CanvasTool.select;
                    _pushStateToUndoStack();
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Add',
                  style: isDarkMode
                      ? AppTextStyles.bodyMediumDark
                          .copyWith(color: AppColors.primaryBlue)
                      : AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  TextPainter _calculateTextSize(String text, double fontSize) {
    final textStyle = TextStyle(fontSize: fontSize);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
        minWidth: 0, maxWidth: 300); // Max width to prevent infinite text
    return textPainter;
  }

  void _selectShape(String? id) {
    setState(() {
      for (var shape in _shapes) {
        shape.isSelected = (shape.id == id);
      }
      _selectedShape = _shapes.firstWhereOrNull((shape) => shape.id == id);
    });
  }

  CanvasShape? _hitTest(Offset localPosition) {
    final transformedPosition = (localPosition / _canvasScale) - _canvasOffset;
    // Iterate from top to bottom to select the topmost visible shape
    for (var i = _shapes.length - 1; i >= 0; i--) {
      final shape = _shapes[i];
      if (shape.isVisible && shape.rect.contains(transformedPosition)) {
        return shape;
      }
    }
    return null;
  }

  RectHandle? _hitTestHandle(Offset localPosition) {
    if (_selectedShape == null) return null;

    final transformedPosition = (localPosition / _canvasScale) - _canvasOffset;
    final selectionRect = _selectedShape!.rect.inflate(4.0 / _canvasScale);
    const double handleSize = 8.0;
    const double hitMargin = 10.0; // Larger hit area for handles

    final handles = {
      RectHandle.topLeft: Rect.fromLTWH(selectionRect.left - handleSize / 2,
          selectionRect.top - handleSize / 2, handleSize, handleSize),
      RectHandle.topRight: Rect.fromLTWH(selectionRect.right - handleSize / 2,
          selectionRect.top - handleSize / 2, handleSize, handleSize),
      RectHandle.bottomLeft: Rect.fromLTWH(selectionRect.left - handleSize / 2,
          selectionRect.bottom - handleSize / 2, handleSize, handleSize),
      RectHandle.bottomRight: Rect.fromLTWH(
          selectionRect.right - handleSize / 2,
          selectionRect.bottom - handleSize / 2,
          handleSize,
          handleSize),
    };

    for (var entry in handles.entries) {
      if (entry.value
          .inflate(hitMargin / _canvasScale)
          .contains(transformedPosition)) {
        return entry.key;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    if (_currentTool == CanvasTool.path) {
      setState(() {
        _currentPathPoints = [(localPosition / _canvasScale) - _canvasOffset];
      });
    } else if (_currentTool == CanvasTool.pan) {
      _lastPanPoint = localPosition;
    } else {
      final handle = _hitTestHandle(localPosition);
      if (handle != null && _selectedShape != null) {
        setState(() {
          _startDragPosition = localPosition;
          _initialShapePosition = _selectedShape!.position;
          _initialShapeSize =
              Offset(_selectedShape!.size.width, _selectedShape!.size.height);
          _selectedHandle = handle;
        });
      } else {
        final tappedShape = _hitTest(localPosition);
        if (tappedShape != null) {
          _selectShape(tappedShape.id);
          _startDragPosition = localPosition;
          _initialShapePosition = tappedShape.position;
          _selectedHandle = null;
        } else {
          _selectShape(null);
          _startDragPosition = null;
          _initialShapePosition = null;
          _selectedHandle = null;
        }
      }
    }
  }

  RectHandle? _selectedHandle;

  void _onPanUpdate(DragUpdateDetails details) {
    final currentLocalPosition = details.localPosition;

    if (_currentTool == CanvasTool.path) {
      setState(() {
        _currentPathPoints
            .add((currentLocalPosition / _canvasScale) - _canvasOffset);
      });
    } else if (_currentTool == CanvasTool.pan) {
      if (_lastPanPoint != null) {
        setState(() {
          _canvasOffset +=
              (currentLocalPosition - _lastPanPoint!) / _canvasScale;
          _lastPanPoint = currentLocalPosition;
        });
      }
    } else if (_selectedShape != null && _startDragPosition != null) {
      final delta = (currentLocalPosition - _startDragPosition!) / _canvasScale;

      setState(() {
        if (_selectedHandle != null) {
          // Resizing
          double newX = _initialShapePosition!.dx;
          double newY = _initialShapePosition!.dy;
          double newWidth = _initialShapeSize!.dx;
          double newHeight = _initialShapeSize!.dy;

          switch (_selectedHandle!) {
            case RectHandle.topLeft:
              newX = _initialShapePosition!.dx + delta.dx;
              newY = _initialShapePosition!.dy + delta.dy;
              newWidth = _initialShapeSize!.dx - delta.dx;
              newHeight = _initialShapeSize!.dy - delta.dy;
              break;
            case RectHandle.topRight:
              newY = _initialShapePosition!.dy + delta.dy;
              newWidth = _initialShapeSize!.dx + delta.dx;
              newHeight = _initialShapeSize!.dy - delta.dy;
              break;
            case RectHandle.bottomLeft:
              newX = _initialShapePosition!.dx + delta.dx;
              newWidth = _initialShapeSize!.dx - delta.dx;
              newHeight = _initialShapeSize!.dy + delta.dy;
              break;
            case RectHandle.bottomRight:
              newWidth = _initialShapeSize!.dx + delta.dx;
              newHeight = _initialShapeSize!.dy + delta.dy;
              break;
          }

          // Ensure minimum size and prevent negative dimensions
          newWidth = newWidth.clamp(10.0, double.infinity);
          newHeight = newHeight.clamp(10.0, double.infinity);

          _selectedShape = _selectedShape!.copyWith(
            position: Offset(newX, newY),
            size: Size(newWidth, newHeight),
          );

          // For text, re-calculate layout size as well
          if (_selectedShape!.type == ShapeType.text &&
              _selectedShape!.textContent != null) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: _selectedShape!.textContent,
                style: TextStyle(
                  fontSize: _selectedShape!.fontSize,
                  fontWeight: _selectedShape!.fontWeight,
                  fontStyle: _selectedShape!.fontStyle,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(minWidth: 0, maxWidth: newWidth);
            _selectedShape = _selectedShape!.copyWith(
                size: Size(
                    newWidth,
                    textPainter
                        .height)); // Keep width user-controlled, adjust height
          }

          final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
          if (index != -1) {
            _shapes[index] = _selectedShape!;
          }
        } else {
          // Dragging
          final newPosition = _initialShapePosition! + delta;
          _selectedShape = _selectedShape!.copyWith(position: newPosition);
          final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
          if (index != -1) {
            _shapes[index] = _selectedShape!;
          }
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentTool == CanvasTool.path && _currentPathPoints.isNotEmpty) {
      if (_currentPathPoints.length > 1) {
        setState(() {
          _shapes.add(
            CanvasShape(
              type: ShapeType.path,
              position: _currentPathPoints.first, // Store the starting point
              size: Size.zero, // Path doesn't have a fixed size
              pathPoints: List.from(_currentPathPoints),
              color: AppColors.accentRed,
              strokeWidth: 4.0,
            ),
          );
        });
      }
      _currentPathPoints = [];
      _pushStateToUndoStack();
    }
    if (_startDragPosition != null && _selectedShape != null) {
      // If a drag or resize happened, save state
      _pushStateToUndoStack();
    }
    _startDragPosition = null;
    _initialShapePosition = null;
    _initialShapeSize = null;
    _selectedHandle = null;
    _lastPanPoint = null;
  }

  void _deleteSelectedShape() {
    if (_selectedShape != null) {
      setState(() {
        _shapes.removeWhere((shape) => shape.id == _selectedShape!.id);
        _selectedShape = null;
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeColor(Color newColor) {
    if (_selectedShape != null) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(color: newColor);
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeStrokeColor(Color newColor) {
    if (_selectedShape != null) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(strokeColor: newColor);
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeStrokeWidth(double width) {
    if (_selectedShape != null) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(strokeWidth: width);
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeFontSize(double size) {
    if (_selectedShape != null && _selectedShape!.type == ShapeType.text) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(fontSize: size);
        final newTextSize =
            _calculateTextSize(_selectedShape!.textContent!, size).size;
        _selectedShape = _selectedShape!.copyWith(
            size: Size(
                newTextSize.width, newTextSize.height)); // Update text size
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeFontWeight(FontWeight weight) {
    if (_selectedShape != null && _selectedShape!.type == ShapeType.text) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(fontWeight: weight);
        final newTextSize = _calculateTextSize(
                _selectedShape!.textContent!, _selectedShape!.fontSize!)
            .size;
        _selectedShape = _selectedShape!
            .copyWith(size: Size(newTextSize.width, newTextSize.height));
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _updateSelectedShapeFontStyle(FontStyle style) {
    if (_selectedShape != null && _selectedShape!.type == ShapeType.text) {
      setState(() {
        _selectedShape = _selectedShape!.copyWith(fontStyle: style);
        final newTextSize = _calculateTextSize(
                _selectedShape!.textContent!, _selectedShape!.fontSize!)
            .size;
        _selectedShape = _selectedShape!
            .copyWith(size: Size(newTextSize.width, newTextSize.height));
        final index = _shapes.indexWhere((s) => s.id == _selectedShape!.id);
        if (index != -1) {
          _shapes[index] = _selectedShape!;
        }
        _pushStateToUndoStack();
      });
    }
  }

  void _toggleLayerVisibility(String shapeId) {
    setState(() {
      final index = _shapes.indexWhere((s) => s.id == shapeId);
      if (index != -1) {
        _shapes[index] =
            _shapes[index].copyWith(isVisible: !_shapes[index].isVisible);
      }
      _pushStateToUndoStack();
    });
  }

  void _zoomIn() {
    setState(() {
      _canvasScale *= 1.1;
    });
  }

  void _zoomOut() {
    setState(() {
      _canvasScale /= 1.1;
    });
  }

  void _renameProject() {
    final TextEditingController nameController =
        TextEditingController(text: _currentProject.name);
    showDialog(
      context: context,
      builder: (context) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Text('Rename Project',
              style: isDarkMode
                  ? AppTextStyles.headlineSmallDark
                  : AppTextStyles.headlineSmall),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter new project name',
              hintStyle: isDarkMode
                  ? AppTextStyles.bodyMediumDark
                      .copyWith(color: AppColors.textSecondaryDark)
                  : AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondaryLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.borderColorDark
                        : AppColors.borderColorLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.borderColorDark
                        : AppColors.borderColorLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
            style: isDarkMode
                ? AppTextStyles.bodyMediumDark
                : AppTextStyles.bodyMedium,
            cursorColor: AppColors.primaryBlue,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: isDarkMode
                      ? AppTextStyles.bodyMediumDark
                          .copyWith(color: AppColors.textSecondaryDark)
                      : AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondaryLight)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _currentProject =
                        _currentProject.copyWith(name: nameController.text);
                    Provider.of<ProjectService>(context, listen: false)
                        .updateProject(_currentProject);
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Rename',
                  style: isDarkMode
                      ? AppTextStyles.bodyMediumDark
                          .copyWith(color: AppColors.primaryBlue)
                      : AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: GestureDetector(
          // Allow renaming project by tapping title
          onTap: _renameProject,
          child: Text(
            _currentProject.name,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _buildToolButton(
            Icons.mouse,
            'Select Tool',
            CanvasTool.select,
            _currentTool == CanvasTool.select,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.pan_tool_alt,
            'Pan Tool',
            CanvasTool.pan,
            _currentTool == CanvasTool.pan,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.rectangle_outlined,
            'Add Rectangle',
            CanvasTool.rectangle,
            _currentTool == CanvasTool.rectangle,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.circle_outlined,
            'Add Circle',
            CanvasTool.circle,
            _currentTool == CanvasTool.circle,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.text_fields,
            'Add Text',
            CanvasTool.text,
            _currentTool == CanvasTool.text,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.edit,
            'Pencil Tool',
            CanvasTool.path,
            _currentTool == CanvasTool.path,
            isDarkMode,
          ),
          _buildToolButton(
            Icons.zoom_in,
            'Zoom In',
            null,
            false,
            isDarkMode,
            onPressed: _zoomIn,
          ),
          _buildToolButton(
            Icons.zoom_out,
            'Zoom Out',
            null,
            false,
            isDarkMode,
            onPressed: _zoomOut,
          ),
          _buildToolButton(
            Icons.undo,
            'Undo',
            null,
            false,
            isDarkMode,
            onPressed: _undo,
            isEnabled: _undoStack.length >
                1, // Can only undo if there's more than initial state
          ),
          _buildToolButton(
            Icons.redo,
            'Redo',
            null,
            false,
            isDarkMode,
            onPressed: _redo,
            isEnabled: _redoStack.isNotEmpty,
          ),
          _buildToolButton(
            Icons.delete_outline,
            'Delete Selected',
            null,
            false,
            isDarkMode,
            onPressed: _deleteSelectedShape,
            isEnabled: _selectedShape != null,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isLeftPanelOpen ? 250 : 0,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: _isLeftPanelOpen
                  ? _buildLeftPanel(isDarkMode)
                  : const SizedBox.shrink(),
            ),
          if (!isMobile)
            IconButton(
              icon: Icon(
                  _isLeftPanelOpen ? Icons.chevron_left : Icons.chevron_right,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              onPressed: () {
                setState(() {
                  _isLeftPanelOpen = !_isLeftPanelOpen;
                });
              },
              tooltip: _isLeftPanelOpen
                  ? 'Collapse Left Panel'
                  : 'Expand Left Panel',
            ),
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTapUp: (details) {
                if (_currentTool == CanvasTool.select) {
                  final tappedShape = _hitTest(details.localPosition);
                  _selectShape(tappedShape?.id);
                } else if (_currentTool == CanvasTool.rectangle) {
                  _addShape(ShapeType.rectangle);
                } else if (_currentTool == CanvasTool.circle) {
                  _addShape(ShapeType.circle);
                } else if (_currentTool == CanvasTool.text) {
                  _addShape(ShapeType.text);
                }
              },
              child: CustomPaint(
                painter: CanvasPainter(
                  shapes: _shapes,
                  canvasOffset: _canvasOffset,
                  canvasScale: _canvasScale,
                  isDarkMode: isDarkMode,
                  currentPathPoints: _currentPathPoints,
                  isDrawingMode: _currentTool == CanvasTool.path,
                ),
                child: Container(),
              ),
            ),
          ),
          if (!isMobile)
            IconButton(
              icon: Icon(
                  _isRightPanelOpen ? Icons.chevron_right : Icons.chevron_left,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              onPressed: () {
                setState(() {
                  _isRightPanelOpen = !_isRightPanelOpen;
                });
              },
              tooltip: _isRightPanelOpen
                  ? 'Collapse Right Panel'
                  : 'Expand Right Panel',
            ),
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRightPanelOpen ? 280 : 0,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: _isRightPanelOpen
                  ? _buildRightPanel(isDarkMode)
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    IconData icon,
    String tooltip,
    CanvasTool? tool,
    bool isActive,
    bool isDarkMode, {
    VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(
            icon,
            color: isActive
                ? AppColors.primaryBlue
                : (isEnabled
                    ? (isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight)
                        .withOpacity(0.5)),
          ),
          onPressed: isEnabled
              ? (onPressed ??
                  () {
                    setState(() {
                      _currentTool = tool!;
                    });
                  })
              : null,
          splashRadius: 24,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (isActive) return AppColors.primaryBlue.withOpacity(0.2);
              if (states.contains(MaterialState.hovered)) {
                return (isDarkMode
                        ? AppColors.surfaceLight
                        : AppColors.surfaceDark)
                    .withOpacity(0.1);
              }
              return Colors.transparent;
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Layers',
              style: isDarkMode
                  ? AppTextStyles.headlineSmallDark
                  : AppTextStyles.headlineSmall),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _shapes.length,
            itemBuilder: (context, index) {
              final shape = _shapes[_shapes.length -
                  1 -
                  index]; // Display in reverse order (topmost layer first)
              var copyWith = AppTextStyles.bodySmallDark.copyWith(
                color: (isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    .withOpacity(shape.isVisible ? 1.0 : 0.5),
                fontWeight:
                    shape.isSelected ? FontWeight.bold : FontWeight.normal,
                decoration: shape.isVisible
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
                fontStyle:
                    shape.isVisible ? FontStyle.normal : FontStyle.italic,
                // Fade text if hidden
              );
              return ListTile(
                leading: Icon(
                  shape.type == ShapeType.rectangle
                      ? Icons.rectangle_outlined
                      : shape.type == ShapeType.circle
                          ? Icons.circle_outlined
                          : shape.type == ShapeType.text
                              ? Icons.text_fields
                              : Icons.gesture,
                  color: shape.isSelected
                      ? AppColors.primaryBlue
                      : (isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)
                          .withOpacity(
                              shape.isVisible ? 1.0 : 0.5), // Faded if hidden
                ),
                title: Text(
                  '${shape.type.name.capitalize()} ${_shapes.length - index}', // Numbering based on display order
                  style: isDarkMode
                      ? copyWith
                      : AppTextStyles.bodySmall.copyWith(
                          color: (isDarkMode
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight)
                              .withOpacity(shape.isVisible ? 1.0 : 0.5),
                          fontWeight: shape.isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          decoration: shape.isVisible
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                          fontStyle: shape.isVisible
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    shape.isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  onPressed: () => _toggleLayerVisibility(shape.id),
                  tooltip: shape.isVisible ? 'Hide Layer' : 'Show Layer',
                ),
                selected: shape.isSelected,
                selectedTileColor: AppColors.primaryBlue.withOpacity(0.1),
                onTap: () => _selectShape(shape.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Properties',
              style: isDarkMode
                  ? AppTextStyles.headlineSmallDark
                  : AppTextStyles.headlineSmall),
        ),
        if (_selectedShape == null)
          Expanded(
            child: Center(
              child: Text(
                'Select a shape to view properties',
                textAlign: TextAlign.center,
                style: isDarkMode
                    ? AppTextStyles.labelMediumDark
                        .copyWith(color: AppColors.textSecondaryDark)
                    : AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondaryLight),
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColorPickerButton(
                    label: 'Fill',
                    currentColor: _selectedShape!.color,
                    onColorChanged: _updateSelectedShapeColor,
                  ),
                  const SizedBox(height: 20),
                  // Stroke properties for all types except paths (paths use color for stroke)
                  if (_selectedShape!.type != ShapeType.path) ...[
                    ColorPickerButton(
                      label: 'Stroke',
                      currentColor: _selectedShape!.strokeColor ??
                          Colors.black.withOpacity(0.5),
                      onColorChanged: _updateSelectedShapeStrokeColor,
                    ),
                    const SizedBox(height: 16),
                    Text('Stroke Width',
                        style: isDarkMode
                            ? AppTextStyles.bodyMediumDark
                            : AppTextStyles.bodyMedium),
                    Slider(
                      value: _selectedShape!.strokeWidth ?? 1.0,
                      min: 0.0,
                      max: 10.0,
                      divisions: 10,
                      label: (_selectedShape!.strokeWidth ?? 1.0)
                          .toStringAsFixed(1),
                      onChanged: _updateSelectedShapeStrokeWidth,
                      activeColor: AppColors.primaryBlue,
                      inactiveColor: isDarkMode
                          ? AppColors.borderColorDark
                          : AppColors.borderColorLight,
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Text properties only for text shapes
                  if (_selectedShape!.type == ShapeType.text) ...[
                    Text('Font Size',
                        style: isDarkMode
                            ? AppTextStyles.bodyMediumDark
                            : AppTextStyles.bodyMedium),
                    Slider(
                      value: _selectedShape!.fontSize ?? 16,
                      min: 8,
                      max: 72,
                      divisions: (72 - 8) ~/ 2,
                      label:
                          (_selectedShape!.fontSize ?? 16).toStringAsFixed(0),
                      onChanged: _updateSelectedShapeFontSize,
                      activeColor: AppColors.primaryBlue,
                      inactiveColor: isDarkMode
                          ? AppColors.borderColorDark
                          : AppColors.borderColorLight,
                    ),
                    const SizedBox(height: 16),
                    Text('Font Weight',
                        style: isDarkMode
                            ? AppTextStyles.bodyMediumDark
                            : AppTextStyles.bodyMedium),
                    Row(
                      children: [
                        _buildFontWeightButton(
                            'Normal', FontWeight.normal, isDarkMode),
                        const SizedBox(width: 8),
                        _buildFontWeightButton(
                            'Bold', FontWeight.bold, isDarkMode),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Font Style',
                        style: isDarkMode
                            ? AppTextStyles.bodyMediumDark
                            : AppTextStyles.bodyMedium),
                    Row(
                      children: [
                        _buildFontStyleButton(
                            'Normal', FontStyle.normal, isDarkMode),
                        const SizedBox(width: 8),
                        _buildFontStyleButton(
                            'Italic', FontStyle.italic, isDarkMode),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text('Position & Size',
                      style: isDarkMode
                          ? AppTextStyles.bodyMediumDark
                          : AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  _buildPropertyRow(
                      'X:',
                      '${_selectedShape!.position.dx.toStringAsFixed(0)} px',
                      isDarkMode),
                  _buildPropertyRow(
                      'Y:',
                      '${_selectedShape!.position.dy.toStringAsFixed(0)} px',
                      isDarkMode),
                  _buildPropertyRow(
                      'W:',
                      '${_selectedShape!.size.width.toStringAsFixed(0)} px',
                      isDarkMode),
                  _buildPropertyRow(
                      'H:',
                      '${_selectedShape!.size.height.toStringAsFixed(0)} px',
                      isDarkMode),
                  const SizedBox(height: 20),
                  Text('Type',
                      style: isDarkMode
                          ? AppTextStyles.bodyMediumDark
                          : AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text(_selectedShape!.type.name.capitalize(),
                      style: isDarkMode
                          ? AppTextStyles.bodySmallDark
                          : AppTextStyles.bodySmall),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isDarkMode
                  ? AppTextStyles.labelMediumDark
                  : AppTextStyles.labelMedium),
          Text(value,
              style: isDarkMode
                  ? AppTextStyles.bodySmallDark
                  : AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFontWeightButton(
      String text, FontWeight weight, bool isDarkMode) {
    bool isSelected = _selectedShape?.fontWeight == weight;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateSelectedShapeFontWeight(weight),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryBlue
              : (isDarkMode
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight),
          foregroundColor: isSelected
              ? Colors.white
              : (isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight),
          side: BorderSide(
              color: isDarkMode
                  ? AppColors.borderColorDark
                  : AppColors.borderColorLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text, style: AppTextStyles.labelSmall),
      ),
    );
  }

  Widget _buildFontStyleButton(String text, FontStyle style, bool isDarkMode) {
    bool isSelected = _selectedShape?.fontStyle == style;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateSelectedShapeFontStyle(style),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryBlue
              : (isDarkMode
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight),
          foregroundColor: isSelected
              ? Colors.white
              : (isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight),
          side: BorderSide(
              color: isDarkMode
                  ? AppColors.borderColorDark
                  : AppColors.borderColorLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text, style: AppTextStyles.labelSmall),
      ),
    );
  }
}

enum RectHandle { topLeft, topRight, bottomLeft, bottomRight }

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
