import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final lightTheme = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      appBarColor: AppColors.background,
      error: AppColors.error,
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      defaultRadius: 12.0, // More rounded, modern look
      elevatedButtonSchemeColor: SchemeColor.onPrimary,
      elevatedButtonSecondarySchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: true,
      fabUseShape: true,
      fabAlwaysCircular: true,
      chipSchemeColor: SchemeColor.primary,
      cardElevation: 2, // Slight elevation for cards
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
  );

  static final darkTheme = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: AppColors.primary, // Slate 900
      primaryContainer: AppColors.tertiary, // Slate 700
      secondary: AppColors.secondary, // Gold
      secondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.goldSecondary,
      tertiaryContainer: AppColors.goldTertiary,
      appBarColor: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      defaultRadius: 12.0,
      elevatedButtonSchemeColor: SchemeColor.onPrimary,
      elevatedButtonSecondarySchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: true,
      fabUseShape: true,
      fabAlwaysCircular: true,
      chipSchemeColor: SchemeColor.primary,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
  );

  // Gold Theme - Renamed/Refined for "Ultra Premium" or Admin
  static final goldTheme = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: AppColors.goldSecondary, // Bronze/Gold Main
      primaryContainer: AppColors.goldContainer,
      secondary: AppColors.primary, // Navy Secondary
      secondaryContainer: AppColors.primaryContainer,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      appBarColor: AppColors.background,
      error: AppColors.error,
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      defaultRadius: 12.0,
      elevatedButtonSchemeColor: SchemeColor.onPrimary,
      elevatedButtonSecondarySchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: true,
      fabUseShape: true,
      fabAlwaysCircular: true,
      chipSchemeColor: SchemeColor.primary,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
  );
}
