import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display Large — hero/splash, above standard scale
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 40,
    height: 48 / 40,
    letterSpacing: -0.80, // -0.02em
  );

  // h1 — 32px, Bold
  static TextStyle get heading1 => GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.2,
    letterSpacing: -0.64, // -0.02em
  );

  // h2 — 24px, SemiBold
  static TextStyle get heading2 => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.24, // -0.01em
  );

  // h2 Bold — 24px bold variant
  static TextStyle get heading3B => GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.24,
  );

  // h3 Medium — 20px, Medium
  static TextStyle get heading3 => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.20, // -0.01em
  );

  // h3 SemiBold — 20px, SemiBold
  static TextStyle get heading4SB => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.20,
  );

  // body-lg — 16px, Regular
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0,
  );

  // body-lg Medium — 16px, Medium
  static TextStyle get bodyLargeMedium => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0,
  );

  // body-md — 14px, Regular
  static TextStyle get body => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
  );

  // body-md SemiBold — 14px, SemiBold
  static TextStyle get body2 => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
  );

  // body-sm — 13px, Regular
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0,
  );

  // body-sm Medium — 13px, Medium
  static TextStyle get bodySmallM => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0,
  );

  // body-sm SemiBold — 13px, SemiBold
  static TextStyle get bodySmallSB => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0,
  );

  // label-caps — 12px, SemiBold, wide tracking (use with toUpperCase())
  static TextStyle get labelCaps => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.0,
    letterSpacing: 0.60, // 0.05em
  );

  // Regular — 12px
  static TextStyle get regular => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
  );

  // Regular Underline — 12px, underlined
  static TextStyle get regularUnderline => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
  );

  // Underline modifier — apply via copyWith
  static TextStyle get underline => const TextStyle(
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
  );

  // Code — 14px, monospace
  static TextStyle get code => const TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
  );
}
