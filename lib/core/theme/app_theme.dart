import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// A Kalenda színei: a webes design (`_kalenda-design`) palettája – mély kékeszöld márkaszín, hűvös, világoskék háttér.
class AppColors {
  AppColors._();

  /// Márka: gombok, kiemelések, a nagy fejlécek háttere.
  static const brand = Color(0xFF086288);
  static const brandDark = Color(0xFF064C6B);

  /// A szöveg alapszíne (sötét kékeszöld), és a halvány szövegek.
  static const navy = Color(0xFF0A3D57);
  static const muted = Color(0xFF577387);
  static const mutedStrong = Color(0xFF3D6177);

  /// A márkaszínű háttéren látszó másodlagos szövegek / ikonok.
  static const onBrandMuted = Color(0xFFCFE9F7);
  static const onBrandAccent = Color(0xFF97D7FF);

  /// Árnyalat a márka mellé (színátmenetekhez, kiemelésekhez).
  static const indigo = Color(0xFF0B7CAB);

  // Halvány háttérszínek (csempék, kijelölés, jelvények) – az elő-/szövegszín a márka sötétebb árnyalata.
  static const blueSoft = Color(0xFFE3F3FF);
  static const indigoSoft = Color(0xFFEAF4FC);
  static const greenSoft = Color(0xFFDFF3E6);
  static const amberSoft = Color(0xFFFFF1D2);
  static const roseSoft = Color(0xFFFDE8E8);
  static const tint = Color(0xFFF2F9FF);

  // Állapotszínek (foglalás, számla, szabadság…): sötét szövegszín a halvány háttérhez.
  static const success = Color(0xFF1B6E3C);
  static const warning = Color(0xFF8A5A00);
  static const danger = Color(0xFFC62828);
  static const neutral = Color(0xFF577387);

  /// A nagy fejlécek háttere: a design lapos, egyszínű márka-háttere.
  static const heroGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [brand, brand]);
}

/// Közös méretek és lekerekítések, hogy minden képernyő egy nyelvet beszéljen.
class AppDimens {
  AppDimens._();

  /// Kártyák, panelek.
  static const radius = 16.0;

  /// Gombok, beviteli mezők, listaelemek.
  static const radiusSmall = 14.0;

  /// Nagy lapok (belépő panel, alsó lapok).
  static const radiusLarge = 26.0;
  static const pagePadding = 16.0;
  static const gap = 12.0;
}

/// A cím- és kiemelt betűtípus (Bricolage Grotesque); a törzsszöveg Figtree.
const _display = 'BricolageGrotesque';
const _body = 'Figtree';

/// Világos és sötét téma a design palettájából (Material 3).
ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  // Világos: a design pontos színei. Sötét: ugyanaz a kékeszöld család, mélyebb háttérrel.
  final background = dark ? const Color(0xFF06222F) : AppColors.tint;
  final surface = dark ? const Color(0xFF0B3347) : Colors.white;
  final border = dark ? const Color(0xFF1B4C66) : const Color(0xFFD9E8F5);
  final inputBorder = dark ? const Color(0xFF2A607C) : const Color(0xFFCFE0EE);
  final primary = dark ? AppColors.onBrandAccent : AppColors.brand;
  final onSurface = dark ? const Color(0xFFE3F3FF) : AppColors.navy;
  final muted = dark ? const Color(0xFF97B0C0) : AppColors.muted;
  final tintSelected = dark ? const Color(0xFF0F4A66) : AppColors.blueSoft;
  final onTintSelected = dark ? AppColors.onBrandMuted : AppColors.brandDark;

  final scheme = ColorScheme.fromSeed(seedColor: AppColors.brand, brightness: brightness).copyWith(
    primary: primary,
    onPrimary: dark ? const Color(0xFF04334A) : Colors.white,
    primaryContainer: tintSelected,
    onPrimaryContainer: onTintSelected,
    secondary: primary,
    secondaryContainer: tintSelected,
    onSecondaryContainer: onTintSelected,
    tertiaryContainer: tintSelected,
    onTertiaryContainer: onTintSelected,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: muted,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surface,
    surfaceContainer: dark ? const Color(0xFF0E3C53) : AppColors.indigoSoft,
    surfaceContainerHigh: dark ? const Color(0xFF12455F) : AppColors.indigoSoft,
    surfaceContainerHighest: dark ? const Color(0xFF16506C) : const Color(0xFFE3EEF6),
    outline: dark ? const Color(0xFF6E8CA0) : const Color(0xFF97B0C0),
    outlineVariant: border,
    error: dark ? const Color(0xFFFF9A9A) : AppColors.danger,
    errorContainer: dark ? const Color(0xFF5A1F1F) : AppColors.roseSoft,
    onErrorContainer: dark ? const Color(0xFFFFDAD6) : const Color(0xFF8A2A2A),
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: _body, brightness: brightness);

  TextStyle? display(TextStyle? style, double size, FontWeight weight, {double letterSpacing = 0}) =>
      style?.copyWith(fontFamily: _display, fontSize: size, fontWeight: weight, letterSpacing: letterSpacing, color: onSurface);

  final text = base.textTheme.copyWith(
    headlineLarge: display(base.textTheme.headlineLarge, 32, FontWeight.w800, letterSpacing: -0.2),
    headlineMedium: display(base.textTheme.headlineMedium, 26, FontWeight.w800, letterSpacing: -0.1),
    headlineSmall: display(base.textTheme.headlineSmall, 22, FontWeight.w800),
    titleLarge: display(base.textTheme.titleLarge, 19, FontWeight.w700),
    titleMedium: display(base.textTheme.titleMedium, 17, FontWeight.w700),
    titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    labelMedium: base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
  );

  OutlineInputBorder fieldBorder(Color color, [double width = 1.5]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall));

  return base.copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
    ),
    scaffoldBackgroundColor: background,
    textTheme: text,
    // A design fejléce fehér, alatta 1 px-es vonallal.
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: border)),
      titleTextStyle: text.titleLarge?.copyWith(color: onSurface, fontSize: 18),
    ),
    // Lapos kártya: 1 px-es kékes keret, árnyék nélkül.
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: muted,
      titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      subtitleTextStyle: text.bodyMedium?.copyWith(color: muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: fieldBorder(inputBorder),
      enabledBorder: fieldBorder(inputBorder),
      focusedBorder: fieldBorder(primary, 2),
      errorBorder: fieldBorder(scheme.error),
      focusedErrorBorder: fieldBorder(scheme.error, 2),
      labelStyle: TextStyle(color: muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: buttonShape,
        textStyle: text.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: primary,
        side: BorderSide(color: dark ? inputBorder : border, width: 1.5),
        shape: buttonShape,
        textStyle: text.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary, shape: buttonShape, textStyle: text.labelLarge),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 6,
      extendedTextStyle: text.labelLarge?.copyWith(fontSize: 15, color: Colors.white),
      shape: const StadiumBorder(),
    ),
    // A design alsó sávja: fehér, felül vonal; a kijelölt fül halványkék tablettában, sötét kékeszöld felirattal.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: tintSelected,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? onTintSelected : muted, size: 22),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? onTintSelected : muted,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: border, width: 1.5),
      backgroundColor: surface,
      selectedColor: tintSelected,
      checkmarkColor: onTintSelected,
      labelStyle: text.labelLarge?.copyWith(color: onSurface),
      secondaryLabelStyle: text.labelLarge?.copyWith(color: onTintSelected),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: dark ? muted : AppColors.mutedStrong,
      indicatorColor: primary,
      dividerColor: border,
      labelStyle: text.labelLarge,
      unselectedLabelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
    ),
    dividerTheme: DividerThemeData(color: border, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary, linearTrackColor: border),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.transparent : border),
    ),
  );
}
