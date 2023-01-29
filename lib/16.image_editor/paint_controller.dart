import 'package:flutter/material.dart';

import 'paint_data.dart';

class PaintController extends ChangeNotifier {
  PaintController() : super();

  late Paint _currentPaint;

  final Paint _eraserPaint = Paint()
    ..strokeWidth = 20
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.clear;

  Color _currentColor = Colors.red;
  double _currentStrokeWidth = 5;

  final List<List<PaintData>> _brushPaths = [[]];
  final List<List<Path>> _eraserPaths = [[]];

  bool _inDrag = false;
  bool _isEraserMode = false;

  void initPaint(Color brushColor, double brushStrokeWidth) {
    _currentColor = brushColor;
    _currentStrokeWidth = brushStrokeWidth;
    _currentPaint = _createPaint(brushColor, brushStrokeWidth);
  }

  set paintColor(Color color) {
    _currentColor = color;
    _currentPaint = _createPaint(color, _currentStrokeWidth);
  }

  set paintStrokeWidth(double strokeWidth) {
    _currentStrokeWidth = strokeWidth;
    _currentPaint = _createPaint(_currentColor, strokeWidth);
  }

  set eraserMode(bool value) {
    if (_isEraserMode && !value) {
      _brushPaths.add([]);
      _eraserPaths.add([]);
    }

    _isEraserMode = value;
  }

  void clear() {
    if (!_inDrag) {
      _brushPaths
        ..clear()
        ..add([]);
      _eraserPaths
        ..clear()
        ..add([]);
      notifyListeners();
    }
  }

  void startPainting(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      final path = Path()..moveTo(startPoint.dx, startPoint.dy);
      if (_isEraserMode) {
        _eraserPaths.last.add(path);
      } else {
        _brushPaths.last.add(PaintData(path, _currentPaint));
      }
      notifyListeners();
    }
  }

  void updatePainting(Offset nextPoint) {
    if (_inDrag) {
      if (_isEraserMode) {
        _eraserPaths.last.last.lineTo(nextPoint.dx, nextPoint.dy);
      } else {
        _brushPaths.last.last.path.lineTo(nextPoint.dx, nextPoint.dy);
      }
      notifyListeners();
    }
  }

  void endPainting() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (var i = 0; i < _brushPaths.length; i++) {
      for (final data in _brushPaths[i]) {
        canvas.drawPath(data.path, data.paint);
      }
      for (final data in _eraserPaths[i]) {
        canvas.drawPath(data, _eraserPaint);
      }
    }
    canvas.restore();
  }

  Paint _createPaint(Color color, double strokeWidth) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = color;
}
