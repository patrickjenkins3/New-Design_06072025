import 'package:flutter/material.dart';

/// Responsive utilities for handling different screen sizes and device types
/// Provides consistent spacing, font sizes, and layout calculations
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Device type detection
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  /// Screen size categories
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;
  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 360 &&
      MediaQuery.of(context).size.width < 768;
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  /// Responsive font sizes that scale properly across devices
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      // Small phones (iPhone SE, etc.)
      return baseSize * 0.85;
    } else if (screenWidth < 390) {
      // Standard phones (iPhone 12, etc.)
      return baseSize * 0.9;
    } else if (screenWidth < 430) {
      // Large phones (iPhone 14 Pro Max, etc.)
      return baseSize;
    } else if (screenWidth < 768) {
      // Large phones and small tablets
      return baseSize * 1.05;
    } else {
      // Tablets and desktop
      return baseSize * 1.1;
    }
  }

  /// Responsive padding that adapts to screen size
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double horizontal = 16.0,
    double vertical = 16.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalPadding = horizontal;
    double verticalPadding = vertical;

    if (screenWidth < 360) {
      horizontalPadding = horizontal * 0.75;
      verticalPadding = vertical * 0.75;
    } else if (screenWidth > 768) {
      horizontalPadding = horizontal * 1.5;
      verticalPadding = vertical * 1.2;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  /// Responsive margin that adapts to screen size
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double horizontal = 16.0,
    double vertical = 8.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalMargin = horizontal;
    double verticalMargin = vertical;

    if (screenWidth < 360) {
      horizontalMargin = horizontal * 0.75;
      verticalMargin = vertical * 0.75;
    } else if (screenWidth > 768) {
      horizontalMargin = horizontal * 1.25;
      verticalMargin = vertical * 1.1;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalMargin,
      vertical: verticalMargin,
    );
  }

  /// Get maximum content width for better readability on large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return 1000;
    } else if (screenWidth > 768) {
      return screenWidth * 0.85;
    } else {
      return screenWidth;
    }
  }

  /// Safe area aware height calculation
  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  /// Check if device has notch or dynamic island
  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 24;
  }

  /// Get appropriate icon size for the device
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseSize * 0.85;
    } else if (screenWidth > 768) {
      return baseSize * 1.15;
    }
    return baseSize;
  }

  /// Get number of columns for grid layouts
  static int getGridColumns(BuildContext context, {int minItemWidth = 300}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 32; // Account for padding
    return (availableWidth / minItemWidth).floor().clamp(1, 4);
  }

  /// Check if content should use single column layout
  static bool shouldUseSingleColumn(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context,
      {double baseHeight = 48.0}) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 667) {
      // iPhone SE and similar small screens
      return baseHeight * 0.9;
    } else if (screenHeight > 900) {
      // Large screens
      return baseHeight * 1.1;
    }
    return baseHeight;
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context,
      {double baseRadius = 12.0}) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseRadius * 0.8;
    } else if (screenWidth > 768) {
      return baseRadius * 1.2;
    }
    return baseRadius;
  }
}

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isPhone => ResponsiveUtils.isPhone(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
  bool get hasNotch => ResponsiveUtils.hasNotch(this);
  bool get shouldUseSingleColumn => ResponsiveUtils.shouldUseSingleColumn(this);

  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  EdgeInsets responsivePadding(
          {double horizontal = 16.0, double vertical = 16.0}) =>
      ResponsiveUtils.getResponsivePadding(this,
          horizontal: horizontal, vertical: vertical);
  EdgeInsets responsiveMargin(
          {double horizontal = 16.0, double vertical = 8.0}) =>
      ResponsiveUtils.getResponsiveMargin(this,
          horizontal: horizontal, vertical: vertical);
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);
  double get safeAreaHeight => ResponsiveUtils.getSafeAreaHeight(this);
  double iconSize({double baseSize = 24.0}) =>
      ResponsiveUtils.getIconSize(this, baseSize: baseSize);
  int gridColumns({int minItemWidth = 300}) =>
      ResponsiveUtils.getGridColumns(this, minItemWidth: minItemWidth);
  double buttonHeight({double baseHeight = 48.0}) =>
      ResponsiveUtils.getButtonHeight(this, baseHeight: baseHeight);
  double borderRadius({double baseRadius = 12.0}) =>
      ResponsiveUtils.getBorderRadius(this, baseRadius: baseRadius);
}
