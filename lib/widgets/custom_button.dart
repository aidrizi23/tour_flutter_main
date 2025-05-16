import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final bool isSecondary;
  final bool isOutlined;
  final bool showLoadingText;
  final String? loadingText;
  final double? elevation;
  final BorderSide? side;

  const CustomButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.minimumSize,
    this.isSecondary = false,
    this.isOutlined = false,
    this.showLoadingText = false,
    this.loadingText,
    this.elevation,
    this.side,
  }) : assert(
         child != null || text != null,
         'Either child or text must be provided',
       );

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      if (widget.showLoadingText && widget.loadingText != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getContentColor()),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.loadingText!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getContentColor(),
              ),
            ),
          ],
        );
      }
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getContentColor()),
        ),
      );
    }

    if (widget.child != null) return widget.child!;

    // Build text with optional icon
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.text!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Text(
      widget.text!,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Color _getContentColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.isOutlined) {
      return widget.foregroundColor ?? colorScheme.primary;
    }
    if (widget.isSecondary) {
      return widget.foregroundColor ?? colorScheme.onSecondaryContainer;
    }
    return widget.foregroundColor ?? colorScheme.onPrimary;
  }

  Color _getBackgroundColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.isOutlined) {
      return Colors.transparent;
    }
    if (widget.isSecondary) {
      return widget.backgroundColor ?? colorScheme.secondaryContainer;
    }
    return widget.backgroundColor ?? colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap:
          widget.onPressed != null && !widget.isLoading
              ? widget.onPressed
              : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.minimumSize?.height ?? 52,
              width: widget.minimumSize?.width ?? double.infinity,
              decoration: BoxDecoration(
                color:
                    widget.onPressed != null && !widget.isLoading
                        ? _getBackgroundColor()
                        : colorScheme.onSurface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                border:
                    widget.isOutlined
                        ? Border.all(
                          color:
                              widget.side?.color ??
                              (widget.onPressed != null && !widget.isLoading
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.5)),
                          width: widget.side?.width ?? 1,
                        )
                        : null,
                boxShadow:
                    !widget.isOutlined &&
                            widget.onPressed != null &&
                            !widget.isLoading
                        ? [
                          BoxShadow(
                            color: _getBackgroundColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      widget.onPressed != null && !widget.isLoading
                          ? widget.onPressed
                          : null,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? 16,
                  ),
                  splashColor: _getContentColor().withOpacity(0.1),
                  highlightColor: _getContentColor().withOpacity(0.05),
                  child: Padding(
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color:
                              widget.onPressed != null && !widget.isLoading
                                  ? _getContentColor()
                                  : colorScheme.onSurface.withOpacity(0.38),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        child: IconTheme(
                          data: IconThemeData(
                            color:
                                widget.onPressed != null && !widget.isLoading
                                    ? _getContentColor()
                                    : colorScheme.onSurface.withOpacity(0.38),
                            size: 20,
                          ),
                          child: _buildButtonContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Convenience constructors
extension CustomButtonExtensions on CustomButton {
  static CustomButton primary({
    Key? key,
    VoidCallback? onPressed,
    Widget? child,
    String? text,
    IconData? icon,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool showLoadingText = false,
    String? loadingText,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
      minimumSize: minimumSize,
      showLoadingText: showLoadingText,
      loadingText: loadingText,
      child: child,
    );
  }

  static CustomButton secondary({
    Key? key,
    VoidCallback? onPressed,
    Widget? child,
    String? text,
    IconData? icon,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool showLoadingText = false,
    String? loadingText,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
      minimumSize: minimumSize,
      isSecondary: true,
      showLoadingText: showLoadingText,
      loadingText: loadingText,
      child: child,
    );
  }

  static CustomButton outlined({
    Key? key,
    VoidCallback? onPressed,
    Widget? child,
    String? text,
    IconData? icon,
    bool isLoading = false,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    BorderSide? side,
    bool showLoadingText = false,
    String? loadingText,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
      minimumSize: minimumSize,
      isOutlined: true,
      side: side,
      showLoadingText: showLoadingText,
      loadingText: loadingText,
      child: child,
    );
  }
}

class CustomIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isPressed;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.isPressed = false,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ?? colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                boxShadow:
                    widget.onPressed != null
                        ? [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? 12,
                  ),
                  splashColor: colorScheme.primary.withOpacity(0.1),
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize ?? 24,
                      color:
                          widget.onPressed != null
                              ? (widget.foregroundColor ??
                                  colorScheme.onSurface)
                              : colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
