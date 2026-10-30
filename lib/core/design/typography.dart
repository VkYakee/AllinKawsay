// lib/core/design/typography.dart
import 'package:flutter/material.dart';

class AppText {
  AppText._();

  // Headings (Apple Style)
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0, height: 1.1);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.2);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.25);
  
  // Titles
  static const TextStyle title = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.4, height: 1.3);
  static const TextStyle subtitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.2, height: 1.35);

  // Body
  static const TextStyle body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.5);
  static const TextStyle bodySm = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.45);

  // Labels & Captions
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.4);
  static const TextStyle captionXs = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.35);
  
  // Monospace (Numerofonía)
  static const TextStyle mono = TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold, height: 1.2);
}