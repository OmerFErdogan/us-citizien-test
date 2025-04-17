import 'package:flutter/material.dart';
import 'screen_size.dart';

class ResponsiveHelper {
  final BuildContext context;
  final double _smallScreenBreakpoint = 600;
  final double _mediumScreenBreakpoint = 900;

  // Private constructor
  ResponsiveHelper._internal(this.context);

  // Factory constructor
  static ResponsiveHelper of(BuildContext context) {
    return ResponsiveHelper._internal(context);
  }

  /// Returns the current [ScreenSize] based on the width of the screen.
  ScreenSize get screenSize {
    final width = MediaQuery.of(context).size.width;
    
    if (width <= _smallScreenBreakpoint) {
      return ScreenSize.small;
    } else if (width <= _mediumScreenBreakpoint) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  /// Returns true if the screen size is [ScreenSize.small].
  bool get isSmall => screenSize == ScreenSize.small;

  /// Returns true if the screen size is [ScreenSize.medium].
  bool get isMedium => screenSize == ScreenSize.medium;

  /// Returns true if the screen size is [ScreenSize.large].
  bool get isLarge => screenSize == ScreenSize.large;

  /// Returns true if the screen is in portrait orientation.
  bool get isPortrait => 
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Returns true if the screen is in landscape orientation.
  bool get isLandscape => 
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Returns text scale factor from MediaQuery for accessibility
  double get textScaleFactor => MediaQuery.of(context).textScaleFactor;

  /// Returns a dimension based on screen width percentage
  double widthPercent(double percent) {
    return width * (percent / 100);
  }

  /// Returns a dimension based on screen height percentage
  double heightPercent(double percent) {
    return height * (percent / 100);
  }

  /// Returns adaptable padding based on screen width and provided density factor
  /// The density factor determines how much the padding scales with screen size
  EdgeInsets adaptivePadding({
    double horizontal = 0.0,
    double vertical = 0.0,
    double densityFactor = 0.5, // 0 = fixed, 1 = fully proportional
  }) {
    // Baseline width for calculations (typical phone width)
    const double baselineWidth = 375.0;
    
    // Calculate the scaling factor based on current width vs baseline
    final double scaleFactor = 1.0 + ((width / baselineWidth) - 1.0) * densityFactor;
    
    return EdgeInsets.symmetric(
      horizontal: horizontal * scaleFactor,
      vertical: vertical * scaleFactor,
    );
  }

  /// Returns adaptable icon size based on screen dimensions
  /// or from theme if useTheme is true
  double adaptiveIconSize({
    double size = 24.0,
    bool useTheme = true,
    double densityFactor = 0.5, // 0 = fixed, 1 = fully proportional
  }) {
    // If using theme and theme defines icon size, use it as a reference
    double baseSize = useTheme && Theme.of(context).iconTheme.size != null
        ? Theme.of(context).iconTheme.size!
        : size;
    
    // Baseline width for calculations (typical phone width)
    const double baselineWidth = 375.0;
    
    // Calculate the scaling factor based on current width vs baseline
    final double scaleFactor = 1.0 + ((width / baselineWidth) - 1.0) * densityFactor;
    
    return baseSize * scaleFactor;
  }

  /// Returns the accessible font size based on device text scale factor
  /// and the base font size for the current screen size
  double scaledFontSize({
    required double small,
    required double medium,
    required double large,
  }) {
    // Önce ekran boyutuna göre temel font boyutunu al
    final baseFontSize = value<double>(small: small, medium: medium, large: large);
    
    // Sonra erişilebilirlik için metin ölçekleme faktörü ile çarp
    return baseFontSize * textScaleFactor;
  }

  /// Returns true if the device should use a wide layout (tablet or large screen).
  /// Primarily depends on screen width, with orientation as a secondary factor.
  bool get shouldUseWideLayout {
    // Kesinlikle geniş ekran için yeterli genişlik
    if (width > _mediumScreenBreakpoint) {
      return true;
    }
    
    // Orta boyut aralığındaki cihazlar için yatay modda geniş ekran kullan
    if (width > 700 && isLandscape) {
      return true;
    }
    
    return false;
  }

  /// Returns the appropriate value based on screen size.
  /// 
  /// Example: 
  /// ```
  /// final fontSize = ResponsiveHelper.of(context).value(
  ///   small: 14.0,
  ///   medium: 16.0,
  ///   large: 18.0,
  /// );
  /// ```
  T value<T>({
    required T small,
    required T medium,
    required T large,
  }) {
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium;
      case ScreenSize.large:
        return large;
    }
  }

  /// Returns the width of the screen.
  double get width => MediaQuery.of(context).size.width;
  
  /// Returns the height of the screen.
  double get height => MediaQuery.of(context).size.height;

  /// Returns the safe padding from MediaQuery.
  EdgeInsets get safePadding => MediaQuery.of(context).padding;
}
