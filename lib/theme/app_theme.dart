// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.textSecondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textBlack,
        onBackground: AppColors.textBlack,
        onError: AppColors.white,
      ),

      extensions: <ThemeExtension<dynamic>>[
        AppTextThemeExtension(
          heading4SB: AppTextStyles.heading4SB.copyWith(
            color: AppColors.textBlack,
          ),
        ),
      ],

      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.textBlack,
        ),
        headlineLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.textBlack,
        ),
        headlineMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.textBlack,
        ),
        headlineSmall: AppTextStyles.heading3B.copyWith(
          color: AppColors.textBlack,
        ),
        titleLarge: AppTextStyles.heading3.copyWith(color: AppColors.textBlack),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textBlack),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: AppTextStyles.body2.copyWith(color: AppColors.white),
        labelSmall: AppTextStyles.regular.copyWith(color: AppColors.textBlack),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.body2,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          textStyle: AppTextStyles.body2,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.textGrayLighter,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

@immutable
class AppTextThemeExtension extends ThemeExtension<AppTextThemeExtension> {
  final TextStyle? heading4SB;

  const AppTextThemeExtension({this.heading4SB});

  @override
  AppTextThemeExtension copyWith({TextStyle? heading4SB}) {
    return AppTextThemeExtension(heading4SB: heading4SB ?? this.heading4SB);
  }

  @override
  AppTextThemeExtension lerp(
    ThemeExtension<AppTextThemeExtension>? other,
    double t,
  ) {
    if (other is! AppTextThemeExtension) {
      return this;
    }
    return AppTextThemeExtension(
      heading4SB: TextStyle.lerp(heading4SB, other.heading4SB, t),
    );
  }
}
