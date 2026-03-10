import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double full = 9999.0;
}


/// Extension to add custom color properties to ColorScheme
extension ColorSchemeExtensions on ColorScheme {
  /// Primary text color based on brightness
  Color get primaryText => brightness == Brightness.light
      ? LightModeColors.primaryText
      : DarkModeColors.primaryText;

  /// Secondary text color based on brightness
  Color get secondaryText => brightness == Brightness.light
      ? LightModeColors.secondaryText
      : DarkModeColors.secondaryText;

  /// Success color based on brightness
  Color get success => brightness == Brightness.light
      ? LightModeColors.success
      : DarkModeColors.success;
}


/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}


/// Light Mode Colors
class LightModeColors {
  static const primary = Color(0xFF0066FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFFF2D87);
  static const onSecondary = Color(0xFFFFFFFF);
  static const accent = Color(0xFFFFE500);
  static const background = Color(0xFFF4F4F9);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0A0A0F);
  static const primaryText = Color(0xFF0A0A0F);
  static const secondaryText = Color(0xFF4A4A5A);
  static const hint = Color(0xFFA0A0B0);
  static const error = Color(0xFFFF3B30);
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF00E676);
  static const divider = Color(0xFFE0E0E0);
  static const transparent = Color(0x00000000);

  static const shadowSm = BoxShadow(
    color: Color(0x330066FF),
    offset: Offset(0, 4),
    blurRadius: 8,
  );
  static const shadowMd = BoxShadow(
    color: Color(0x4DFF2D87),
    offset: Offset(0, 8),
    blurRadius: 16,
  );
  static const shadowLg = BoxShadow(
    color: Color(0x4DFFE500),
    offset: Offset(0, 12),
    blurRadius: 24,
    spreadRadius: 2,
  );
  static const shadowXl = BoxShadow(
    color: Color(0x66000000),
    offset: Offset(0, 16),
    blurRadius: 32,
    spreadRadius: 4,
  );
}

/// Dark Mode Colors
class DarkModeColors {
  static const primary = Color(0xFF0066FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFFF2D87);
  static const onSecondary = Color(0xFFFFFFFF);
  static const accent = Color(0xFFFFE500);
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF16161F);
  static const onSurface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFFFFFFFF);
  static const secondaryText = Color(0xFFA0A0B0);
  static const hint = Color(0xFF4A4A5A);
  static const error = Color(0xFFFF453A);
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF00E676);
  static const divider = Color(0xFF2C2C35);
  static const transparent = Color(0x00000000);

  static const shadowSm = BoxShadow(
    color: Color(0x330066FF),
    offset: Offset(0, 4),
    blurRadius: 8,
  );
  static const shadowMd = BoxShadow(
    color: Color(0x4DFF2D87),
    offset: Offset(0, 8),
    blurRadius: 16,
  );
  static const shadowLg = BoxShadow(
    color: Color(0x4DFFE500),
    offset: Offset(0, 12),
    blurRadius: 24,
    spreadRadius: 2,
  );
  static const shadowXl = BoxShadow(
    color: Color(0x66000000),
    offset: Offset(0, 16),
    blurRadius: 32,
    spreadRadius: 4,
  );
}


/// Light theme
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.primary,
    onPrimary: LightModeColors.onPrimary,
    secondary: LightModeColors.secondary,
    onSecondary: LightModeColors.onSecondary,
    tertiary: LightModeColors.accent,
    error: LightModeColors.error,
    onError: LightModeColors.onError,
    surface: LightModeColors.surface,
    onSurface: LightModeColors.onSurface,
    background: LightModeColors.background,
    onBackground: LightModeColors.primaryText,
    outline: LightModeColors.divider,
  ),
  scaffoldBackgroundColor: LightModeColors.background,
  dividerColor: LightModeColors.divider,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.primaryText,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: LightModeColors.divider, width: 1),
    ),
  ),
  textTheme: _buildTextTheme(
    LightModeColors.primaryText,
    LightModeColors.secondaryText,
  ),
  extensions: [
    CustomShadows(
      sm: LightModeColors.shadowSm,
      md: LightModeColors.shadowMd,
      lg: LightModeColors.shadowLg,
      xl: LightModeColors.shadowXl,
    ),
  ],
);

/// Dark theme
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.primary,
    onPrimary: DarkModeColors.onPrimary,
    secondary: DarkModeColors.secondary,
    onSecondary: DarkModeColors.onSecondary,
    tertiary: DarkModeColors.accent,
    error: DarkModeColors.error,
    onError: DarkModeColors.onError,
    surface: DarkModeColors.surface,
    onSurface: DarkModeColors.onSurface,
    background: DarkModeColors.background,
    onBackground: DarkModeColors.primaryText,
    outline: DarkModeColors.divider,
  ),
  scaffoldBackgroundColor: DarkModeColors.background,
  dividerColor: DarkModeColors.divider,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.primaryText,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: DarkModeColors.divider, width: 1),
    ),
  ),
  textTheme: _buildTextTheme(
    DarkModeColors.primaryText,
    DarkModeColors.secondaryText,
  ),
  extensions: [
    CustomShadows(
      sm: DarkModeColors.shadowSm,
      md: DarkModeColors.shadowMd,
      lg: DarkModeColors.shadowLg,
      xl: DarkModeColors.shadowXl,
    ),
  ],
);

/// Build text theme using Poppins (primary) and Urbanist (secondary)
TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
  final primaryFont = GoogleFonts.poppinsTextTheme();
  final secondaryFont = GoogleFonts.urbanistTextTheme();

  return TextTheme(
    headlineLarge: primaryFont.headlineLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: primaryColor,
    ),
    headlineMedium: primaryFont.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: primaryColor,
    ),
    titleLarge: primaryFont.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: primaryColor,
    ),
    titleMedium: primaryFont.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: primaryColor,
    ),
    bodyLarge: secondaryFont.bodyLarge?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: primaryColor,
    ),
    bodyMedium: secondaryFont.bodyMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: secondaryColor,
    ),
    bodySmall: secondaryFont.bodySmall?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: secondaryColor,
    ),
    labelLarge: primaryFont.labelLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: primaryColor,
    ),
    labelMedium: primaryFont.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: primaryColor,
    ),
    labelSmall: primaryFont.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: primaryColor,
    ),
  );
}

// Custom Theme Extension for Shadows
class CustomShadows extends ThemeExtension<CustomShadows> {
  final BoxShadow? sm;
  final BoxShadow? md;
  final BoxShadow? lg;
  final BoxShadow? xl;

  const CustomShadows({this.sm, this.md, this.lg, this.xl});

  @override
  ThemeExtension<CustomShadows> copyWith({
    BoxShadow? sm,
    BoxShadow? md,
    BoxShadow? lg,
    BoxShadow? xl,
  }) {
    return CustomShadows(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  ThemeExtension<CustomShadows> lerp(
    ThemeExtension<CustomShadows>? other,
    double t,
  ) {
    if (other is! CustomShadows) return this;
    return CustomShadows(
      sm: BoxShadow.lerp(sm, other.sm, t),
      md: BoxShadow.lerp(md, other.md, t),
      lg: BoxShadow.lerp(lg, other.lg, t),
      xl: BoxShadow.lerp(xl, other.xl, t),
    );
  }
}

extension CustomShadowsContext on BuildContext {
  CustomShadows get shadows => Theme.of(this).extension<CustomShadows>()!;
}
