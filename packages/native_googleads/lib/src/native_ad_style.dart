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
    // Validate corner radius
    if (cornerRadius != null && cornerRadius! < 0) {
      throw ArgumentError(
          'cornerRadius must be non-negative, got: $cornerRadius');
    }

    // Validate margins and padding
    if (margin != null) {
      if (margin!.top < 0 ||
          margin!.right < 0 ||
          margin!.bottom < 0 ||
          margin!.left < 0) {
        throw ArgumentError('Margin values must be non-negative');
      }
    }

    if (padding != null) {
      if (padding!.top < 0 ||
          padding!.right < 0 ||
          padding!.bottom < 0 ||
          padding!.left < 0) {
        throw ArgumentError('Padding values must be non-negative');
      }
    }

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
      if (backgroundColor != null)
        'backgroundColor': backgroundColor!.toARGB32(),
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
      if (starRatingColor != null)
        'starRatingColor': starRatingColor!.toARGB32(),
      if (mediaStyle != null) 'mediaStyle': mediaStyle!.toMap(),
      if (attributionStyle != null)
        'attributionStyle': attributionStyle!.toMap(),
    };
  }

  Map<String, dynamic> _textStyleToMap(TextStyle style) {
    return {
      if (style.fontSize != null) 'fontSize': style.fontSize,
      if (style.fontWeight != null) 'fontWeight': style.fontWeight!.index,
      if (style.color != null) 'color': style.color!.toARGB32(),
      if (style.letterSpacing != null) 'letterSpacing': style.letterSpacing,
      if (style.height != null) 'height': style.height,
    };
  }
}

/// Builder class for creating [NativeAdStyle] instances with a fluent API.
///
/// Example:
/// ```dart
/// final style = NativeAdStyleBuilder()
///   .setBackgroundColor(Colors.white)
///   .setCornerRadius(12.0)
///   .setPadding(EdgeInsets.all(16))
///   .setHeadlineStyle(
///     fontSize: 18,
///     fontWeight: FontWeight.bold,
///     color: Colors.black87,
///   )
///   .setCallToActionStyle(
///     NativeAdButtonStyle(
///       backgroundColor: Colors.blue,
///       textColor: Colors.white,
///     ),
///   )
///   .build();
/// ```
class NativeAdStyleBuilder {
  EdgeInsets? _margin;
  EdgeInsets? _padding;
  Color? _backgroundColor;
  double? _cornerRadius;
  Border? _border;
  TextStyle? _headlineTextStyle;
  TextStyle? _bodyTextStyle;
  TextStyle? _advertiserTextStyle;
  TextStyle? _priceTextStyle;
  TextStyle? _storeTextStyle;
  NativeAdButtonStyle? _callToActionStyle;
  Color? _starRatingColor;
  NativeAdMediaStyle? _mediaStyle;
  NativeAdAttributionStyle? _attributionStyle;

  /// Sets the margin around the entire ad view.
  NativeAdStyleBuilder setMargin(EdgeInsets margin) {
    _margin = margin;
    return this;
  }

  /// Sets the padding inside the ad container.
  NativeAdStyleBuilder setPadding(EdgeInsets padding) {
    _padding = padding;
    return this;
  }

  /// Sets the background color of the ad container.
  NativeAdStyleBuilder setBackgroundColor(Color color) {
    _backgroundColor = color;
    return this;
  }

  /// Sets the corner radius for the ad container.
  NativeAdStyleBuilder setCornerRadius(double radius) {
    if (radius < 0) {
      throw ArgumentError('Corner radius must be non-negative');
    }
    _cornerRadius = radius;
    return this;
  }

  /// Sets the border configuration.
  NativeAdStyleBuilder setBorder(Border border) {
    _border = border;
    return this;
  }

  /// Sets the text style for the headline.
  NativeAdStyleBuilder setHeadlineStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    _headlineTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    return this;
  }

  /// Sets the text style for the body text.
  NativeAdStyleBuilder setBodyStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    _bodyTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    return this;
  }

  /// Sets the text style for the advertiser name.
  NativeAdStyleBuilder setAdvertiserStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    _advertiserTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    return this;
  }

  /// Sets the text style for the price.
  NativeAdStyleBuilder setPriceStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    _priceTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    return this;
  }

  /// Sets the text style for the store name.
  NativeAdStyleBuilder setStoreStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    _storeTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    return this;
  }

  /// Sets the call to action button style.
  NativeAdStyleBuilder setCallToActionStyle(NativeAdButtonStyle style) {
    _callToActionStyle = style;
    return this;
  }

  /// Sets the star rating bar color.
  NativeAdStyleBuilder setStarRatingColor(Color color) {
    _starRatingColor = color;
    return this;
  }

  /// Sets the media view configuration.
  NativeAdStyleBuilder setMediaStyle(NativeAdMediaStyle style) {
    _mediaStyle = style;
    return this;
  }

  /// Sets the ad attribution label style.
  NativeAdStyleBuilder setAttributionStyle(NativeAdAttributionStyle style) {
    _attributionStyle = style;
    return this;
  }

  /// Builds and returns the [NativeAdStyle] instance.
  NativeAdStyle build() {
    return NativeAdStyle(
      margin: _margin,
      padding: _padding,
      backgroundColor: _backgroundColor,
      cornerRadius: _cornerRadius,
      border: _border,
      headlineTextStyle: _headlineTextStyle,
      bodyTextStyle: _bodyTextStyle,
      advertiserTextStyle: _advertiserTextStyle,
      priceTextStyle: _priceTextStyle,
      storeTextStyle: _storeTextStyle,
      callToActionStyle: _callToActionStyle,
      starRatingColor: _starRatingColor,
      mediaStyle: _mediaStyle,
      attributionStyle: _attributionStyle,
    );
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
    // Validate corner radius
    if (cornerRadius != null && cornerRadius! < 0) {
      throw ArgumentError(
          'Button cornerRadius must be non-negative, got: $cornerRadius');
    }

    // Validate padding
    if (padding != null) {
      if (padding!.top < 0 ||
          padding!.right < 0 ||
          padding!.bottom < 0 ||
          padding!.left < 0) {
        throw ArgumentError('Button padding values must be non-negative');
      }
    }

    return {
      if (backgroundColor != null)
        'backgroundColor': backgroundColor!.toARGB32(),
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
    // Validate aspect ratio
    if (aspectRatio != null && aspectRatio! <= 0) {
      throw ArgumentError('aspectRatio must be positive, got: $aspectRatio');
    }

    // Validate corner radius
    if (cornerRadius != null && cornerRadius! < 0) {
      throw ArgumentError(
          'Media cornerRadius must be non-negative, got: $cornerRadius');
    }

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
      if (backgroundColor != null)
        'backgroundColor': backgroundColor!.toARGB32(),
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

/// Native ad template types for predefined layouts.
///
/// These templates provide consistent, optimized layouts for different
/// ad placement scenarios in your app.
enum NativeAdTemplate {
  /// Small template with minimal content.
  ///
  /// Best for inline placements in lists or compact spaces.
  /// Typically shows headline, body text, and small icon.
  /// Recommended height: 100-150dp
  small,

  /// Medium template with balanced image and text content.
  ///
  /// Perfect for feed-style layouts or content breaks.
  /// Displays headline, body, media preview, and call-to-action button.
  /// Recommended height: 250-350dp
  medium,

  /// Large template with prominent media display.
  ///
  /// Best for immersive ad experiences or featured placements.
  /// Shows full media, headline, extended body text, and prominent CTA.
  /// Recommended height: 350-500dp
  large,

  /// Custom template for advanced customization.
  ///
  /// Use this when you need full control over the ad appearance.
  /// Must be used in conjunction with NativeAdStyle for styling.
  /// Allows mixing template structure with custom styling overrides.
  custom,
}
