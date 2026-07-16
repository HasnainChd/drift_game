import 'package:flutter/material.dart';

class Gate {
  final String id;
  final double x; // Horizontal position of the gate
  final double gapY; // Top Y position of the gap
  final double gapHeight; // Height of the gap
  final Color color;
  final bool passed;

  const Gate({
    required this.id,
    required this.x,
    required this.gapY,
    required this.gapHeight,
    required this.color,
    this.passed = false,
  });

  Gate copyWith({
    String? id,
    double? x,
    double? gapY,
    double? gapHeight,
    Color? color,
    bool? passed,
  }) {
    return Gate(
      id: id ?? this.id,
      x: x ?? this.x,
      gapY: gapY ?? this.gapY,
      gapHeight: gapHeight ?? this.gapHeight,
      color: color ?? this.color,
      passed: passed ?? this.passed,
    );
  }
}
