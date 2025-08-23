import 'package:flutter/material.dart';

/// Configuration class for native ad styling and layout options.
class NativeAdStyle {
  /// Margin around the entire ad view
  final EdgeInsets? margin;

  /// Padding inside the ad container
  final EdgeInsets? padding;

  /// Background color of the ad container
  final Color? backgroundColor;

  /// Corner radius for the ad container
  final double? cornerRadius;

  /// Border configuration
  final Border? border;

  /// Text style for the headline
  final TextStyle? headlineTextStyle;

  /// Text style for the body text
  final TextStyle? bodyTextStyle;

  /// Text style for the advertiser name
  final TextStyle? advertiserTextStyle;

  /// Text style for the price
  final TextStyle? priceTextStyle;

  /// Text style for the store name
  final TextStyle? storeTextStyle;

  /// Call to action button style
  final NativeAdButtonStyle? callToActionStyle;

  /// Star rating bar color
  final Color? starRatingColor;

  /// Media view configuration
  final NativeAdMediaStyle? mediaStyle;

  /// Ad attribution label style
  final NativeAdAttributionStyle? attributionStyle;

  const NativeAdStyle({
    this.margin,
    this.padding,
    this.backgroundColor,
    this.cornerRadius,
    this.border,
    this.headlineTextStyle,
    this.bodyTextStyle,
    this.advertiserTextStyle,
    this.priceTextStyle,
    this.storeTextStyle,
    this.callToActionStyle,
    this.starRatingColor,
    this.mediaStyle,
    this.attributionStyle,
  });

  /// Creates a default style configuration
  factory NativeAdStyle.defaultStyle() {
    return NativeAdStyle(
      padding: const EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      cornerRadius: 8.0,
      headlineTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      callToActionStyle: NativeAdButtonStyle.defaultStyle(),
      mediaStyle: const NativeAdMediaStyle(),
      attributionStyle: NativeAdAttributionStyle.defaultStyle(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (margin != null)
        'margin': {
          'top': margin!.top,
          'right': margin!.right,
          'bottom': margin!.bottom,
          'left': margin!.left,
        },
      if (padding != null)
        'padding': {
          'top': padding!.top,
          'right': padding!.right,
          'bottom': padding!.bottom,
          'left': padding!.left,
        },
      if (backgroundColor != null) 'backgroundColor': backgroundColor!.toARGB32(),
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      if (headlineTextStyle != null)
        'headlineTextStyle': _textStyleToMap(headlineTextStyle!),
      if (bodyTextStyle != null)
        'bodyTextStyle': _textStyleToMap(bodyTextStyle!),
      if (advertiserTextStyle != null)
        'advertiserTextStyle': _textStyleToMap(advertiserTextStyle!),
      if (priceTextStyle != null)
        'priceTextStyle': _textStyleToMap(priceTextStyle!),
      if (storeTextStyle != null)
        'storeTextStyle': _textStyleToMap(storeTextStyle!),
      if (callToActionStyle != null)
        'callToActionStyle': callToActionStyle!.toMap(),
      if (starRatingColor != null) 'starRatingColor': starRatingColor!.toARGB32(),
      if (mediaStyle != null) 'mediaStyle': mediaStyle!.toMap(),
      if (attributionStyle != null)
        'attributionStyle': attributionStyle!.toMap(),
    };
  }

  Map<String, dynamic> _textStyleToMap(TextStyle style) {
    return {
      if (style.fontSize != null) 'fontSize': style.fontSize,
      if (style.fontWeight != null)
        'fontWeight': style.fontWeight!.index,
      if (style.color != null) 'color': style.color!.toARGB32(),
      if (style.letterSpacing != null) 'letterSpacing': style.letterSpacing,
      if (style.height != null) 'height': style.height,
    };
  }
}

/// Style configuration for call to action button
class NativeAdButtonStyle {
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double? cornerRadius;
  final Border? border;

  const NativeAdButtonStyle({
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.padding,
    this.cornerRadius,
    this.border,
  });

  factory NativeAdButtonStyle.defaultStyle() {
    return const NativeAdButtonStyle(
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cornerRadius: 4.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (backgroundColor != null) 'backgroundColor': backgroundColor!.toARGB32(),
      if (textColor != null) 'textColor': textColor!.toARGB32(),
      if (textStyle != null)
        'textStyle': {
          if (textStyle!.fontSize != null) 'fontSize': textStyle!.fontSize,
          if (textStyle!.fontWeight != null)
            'fontWeight': textStyle!.fontWeight!.index,
        },
      if (padding != null)
        'padding': {
          'top': padding!.top,
          'right': padding!.right,
          'bottom': padding!.bottom,
          'left': padding!.left,
        },
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
    };
  }
}

/// Media view configuration for native ads
class NativeAdMediaStyle {
  /// Aspect ratio for media content (width/height)
  /// Common values: 16/9 (1.77), 4/3 (1.33), 1/1 (1.0)
  final double? aspectRatio;

  /// Whether to maintain aspect ratio
  final bool maintainAspectRatio;

  /// Corner radius for media view
  final double? cornerRadius;

  /// Background color while media is loading
  final Color? placeholderColor;

  const NativeAdMediaStyle({
    this.aspectRatio,
    this.maintainAspectRatio = true,
    this.cornerRadius,
    this.placeholderColor,
  });

  Map<String, dynamic> toMap() {
    return {
      if (aspectRatio != null) 'aspectRatio': aspectRatio,
      'maintainAspectRatio': maintainAspectRatio,
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      if (placeholderColor != null)
        'placeholderColor': placeholderColor!.toARGB32(),
    };
  }
}

/// Ad attribution label style configuration
class NativeAdAttributionStyle {
  final String? text;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? cornerRadius;

  const NativeAdAttributionStyle({
    this.text,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.cornerRadius,
  });

  factory NativeAdAttributionStyle.defaultStyle() {
    return const NativeAdAttributionStyle(
      text: 'Ad',
      textStyle: TextStyle(
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.orange,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      cornerRadius: 3.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (text != null) 'text': text,
      if (textStyle != null)
        'textStyle': {
          if (textStyle!.fontSize != null) 'fontSize': textStyle!.fontSize,
          if (textStyle!.color != null) 'color': textStyle!.color!.toARGB32(),
          if (textStyle!.fontWeight != null)
            'fontWeight': textStyle!.fontWeight!.index,
        },
      if (backgroundColor != null) 'backgroundColor': backgroundColor!.toARGB32(),
      if (padding != null)
        'padding': {
          'top': padding!.top,
          'right': padding!.right,
          'bottom': padding!.bottom,
          'left': padding!.left,
        },
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
    };
  }
}

/// Native ad layout template types
enum NativeAdTemplate {
  /// Small template with minimal height
  small,

  /// Medium template with image and text
  medium,

  /// Large template with prominent media
  large,

  /// Custom template (use with NativeAdStyle)
  custom,
}