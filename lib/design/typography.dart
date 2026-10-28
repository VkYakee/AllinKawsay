// lib/design/typography.dart
import 'package:flutter/material.dart';

class AppType {
  AppType._();

  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.4, height: 1.2);
  static const h3 = TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.25);
  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3);
  static const subtitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -0.1, height: 1.35);
  
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.5);
  static const bodySm = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.45);
  
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.4);
  static const captionXs = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.35);
  
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.3);
  static const labelXs = TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, height: 1.3);
  static const eyebrow = TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, height: 1.3);
  
  static const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4);
}