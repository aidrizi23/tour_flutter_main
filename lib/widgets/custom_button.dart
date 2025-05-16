import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final EdgeInsets? padding;
  final Size? minimumSize;
  final Size? maximumSize;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? elevation;
  final ButtonType type;
  final bool hapticFeedback;
  final IconData? loadingIcon;
  final Duration animationDuration;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.padding,
    this.minimumSize,
    this.maximumSize,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.elevation,
    this.type = ButtonType.filled,
    this.hapticFeedback = true,
    this.loadingIcon,
    this.animationDuration = const Duration(milliseconds: 150),
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isEnabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  bool get _isEnabled =>
      widget.enabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine colors based on button type and state
    Color backgroundColor;
    Color foregroundColor;

    switch (widget.type) {
      case ButtonType.filled:
        backgroundColor = widget.backgroundColor ?? colorScheme.primary;
        foregroundColor = widget.foregroundColor ?? colorScheme.onPrimary;
        break;
      case ButtonType.outlined:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        foregroundColor = widget.foregroundColor ?? colorScheme.primary;
        break;
      case ButtonType.text:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        foregroundColor = widget.foregroundColor ?? colorScheme.primary;
        break;
      case ButtonType.elevated:
        backgroundColor = widget.backgroundColor ?? colorScheme.surface;
        foregroundColor = widget.foregroundColor ?? colorScheme.primary;
        break;
    }

    if (!_isEnabled) {
      backgroundColor =
          widget.disabledBackgroundColor ??
          (widget.type == ButtonType.filled
              ? colorScheme.surfaceContainerLow
              : Colors.transparent);
      foregroundColor =
          widget.disabledForegroundColor ??
          colorScheme.onSurface.withOpacity(0.38);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                constraints: BoxConstraints(
                  minWidth: widget.minimumSize?.width ?? 64,
                  minHeight: widget.minimumSize?.height ?? 48,
                  maxWidth: widget.maximumSize?.width ?? double.infinity,
                  maxHeight: widget.maximumSize?.height ?? double.infinity,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? 16,
                  ),
                  border:
                      widget.border ??
                      (widget.type == ButtonType.outlined
                          ? Border.all(
                            color:
                                _isEnabled
                                    ? foregroundColor
                                    : colorScheme.outline.withOpacity(0.12),
                            width: 1.5,
                          )
                          : null),
                  boxShadow:
                      widget.boxShadow ??
                      (widget.type == ButtonType.elevated && _isEnabled
                          ? [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.15),
                              blurRadius: widget.elevation ?? 4,
                              offset: Offset(0, widget.elevation ?? 2),
                            ),
                          ]
                          : null),
                ),
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child:
                    widget.isLoading
                        ? _buildLoadingChild(foregroundColor)
                        : _buildRegularChild(widget.child, foregroundColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingChild(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        const SizedBox(width: 12),
        if (widget.child is Text)
          DefaultTextStyle(
            style: (widget.child as Text).style ?? TextStyle(color: color),
            child: const Text('Loading...'),
          )
        else
          Text(
            'Loading...',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildRegularChild(Widget child, Color color) {
    return DefaultTextStyle(
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16),
      textAlign: TextAlign.center,
      child: child,
    );
  }
}

// Icon button with modern design
class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final double? size;
  final String? tooltip;
  final bool isLoading;
  final bool enabled;
  final Border? border;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool hapticFeedback;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.size,
    this.tooltip,
    this.isLoading = false,
    this.enabled = true,
    this.border,
    this.borderRadius = 12,
    this.boxShadow,
    this.hapticFeedback = true,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isEnabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  bool get _isEnabled =>
      widget.enabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = widget.size ?? 48.0;
    final backgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHigh;
    final iconColor = widget.iconColor ?? colorScheme.onSurface;
    final iconSize = widget.iconSize ?? 24.0;

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color:
                    _isEnabled
                        ? backgroundColor
                        : backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.border,
                boxShadow: widget.boxShadow,
              ),
              child: Center(
                child:
                    widget.isLoading
                        ? SizedBox(
                          width: iconSize * 0.8,
                          height: iconSize * 0.8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: iconColor,
                          ),
                        )
                        : Icon(
                          widget.icon,
                          size: iconSize,
                          color:
                              _isEnabled
                                  ? iconColor
                                  : iconColor.withOpacity(0.5),
                        ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

// Floating action button with modern design
class CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool isExtended;
  final String? label;
  final IconData? icon;
  final bool isLoading;
  final bool mini;
  final String? heroTag;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.isExtended = false,
    this.label,
    this.icon,
    this.isLoading = false,
    this.mini = false,
    this.heroTag,
  });

  @override
  State<CustomFloatingActionButton> createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isExtended && widget.label != null) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: FloatingActionButton.extended(
                onPressed: widget.isLoading ? null : _handleTap,
                heroTag: widget.heroTag,
                backgroundColor: widget.backgroundColor ?? colorScheme.primary,
                foregroundColor:
                    widget.foregroundColor ?? colorScheme.onPrimary,
                elevation: widget.elevation ?? 6,
                icon:
                    widget.isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                widget.foregroundColor ?? colorScheme.onPrimary,
                          ),
                        )
                        : (widget.icon != null ? Icon(widget.icon) : null),
                label: Text(
                  widget.label!,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton(
              onPressed: widget.isLoading ? null : _handleTap,
              heroTag: widget.heroTag,
              backgroundColor: widget.backgroundColor ?? colorScheme.primary,
              foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
              elevation: widget.elevation ?? 6,
              mini: widget.mini,
              child:
                  widget.isLoading
                      ? SizedBox(
                        width: widget.mini ? 16 : 24,
                        height: widget.mini ? 16 : 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              widget.foregroundColor ?? colorScheme.onPrimary,
                        ),
                      )
                      : widget.child,
            ),
          ),
        );
      },
    );
  }
}

// Button types
enum ButtonType { filled, outlined, text, elevated }

// Preset button styles for common use cases
class CustomButtonStyles {
  static CustomButton primary({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      type: ButtonType.filled,
      width: width,
      height: height,
      child: child,
    );
  }

  static CustomButton secondary({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      type: ButtonType.outlined,
      width: width,
      height: height,
      child: child,
    );
  }

  static CustomButton text({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      type: ButtonType.text,
      width: width,
      height: height,
      child: child,
    );
  }

  static CustomButton danger({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      type: ButtonType.filled,
      backgroundColor: const Color(0xFFEF4444),
      foregroundColor: Colors.white,
      width: width,
      height: height,
      child: child,
    );
  }

  static CustomButton success({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return CustomButton(
      onPressed: onPressed,
      isLoading: isLoading,
      type: ButtonType.filled,
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      width: width,
      height: height,
      child: child,
    );
  }
}
