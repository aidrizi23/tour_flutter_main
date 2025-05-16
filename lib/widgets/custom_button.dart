import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.minimumSize,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSecondary
                  ? colorScheme.secondaryContainer
                  : backgroundColor ?? colorScheme.primary,
          foregroundColor:
              isSecondary
                  ? colorScheme.onSecondaryContainer
                  : foregroundColor ?? colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: minimumSize ?? const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSecondary
                          ? colorScheme.onSecondaryContainer
                          : foregroundColor ?? colorScheme.onPrimary,
                    ),
                  ),
                )
                : child,
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? borderColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.borderColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? colorScheme.primary,
          side: BorderSide(color: borderColor ?? colorScheme.outline, width: 1),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: minimumSize ?? const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ?? colorScheme.primary,
                    ),
                  ),
                )
                : child,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final EdgeInsetsGeometry? padding;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        color: foregroundColor ?? colorScheme.onPrimaryContainer,
        padding: padding ?? EdgeInsets.zero,
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: child,
        label: Text(label!),
        backgroundColor: backgroundColor ?? colorScheme.primary,
        foregroundColor: foregroundColor ?? colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}
