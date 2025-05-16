import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final bool autofocus;
  final FocusNode? focusNode;
  final InputBorder? border;
  final Color? fillColor;
  final bool filled;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final String? helperText;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.autofocus = false,
    this.focusNode,
    this.border,
    this.fillColor,
    this.filled = true,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.helperText,
    this.prefix,
    this.suffix,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  widget.label!,
                  style:
                      widget.labelStyle ??
                      theme.textTheme.titleSmall?.copyWith(
                        color:
                            _isFocused
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
          ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    _isFocused
                        ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                        : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                inputFormatters: widget.inputFormatters,
                style: widget.style ?? theme.textTheme.bodyLarge,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  errorText: widget.errorText,
                  helperText: widget.helperText,
                  prefixIcon: widget.prefixIcon,
                  prefix: widget.prefix,
                  suffix: widget.suffix,
                  suffixIcon:
                      widget.obscureText
                          ? IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          )
                          : widget.suffixIcon,
                  filled: widget.filled,
                  fillColor:
                      widget.fillColor ??
                      (widget.enabled
                          ? colorScheme.surfaceContainerLowest
                          : colorScheme.surfaceContainerLow.withOpacity(0.5)),
                  border:
                      widget.border ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.error, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  contentPadding:
                      widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  hintStyle:
                      widget.hintStyle ??
                      theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                  errorStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  helperStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Search field specifically designed for modern search UX
class CustomSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool showFilter;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;
  final Widget? leadingIcon;
  final List<String>? suggestions;
  final bool enabled;
  final FocusNode? focusNode;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showFilter = false,
    this.onFilterTap,
    this.hasActiveFilters = false,
    this.leadingIcon,
    this.suggestions,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        setState(() {
          _hasText = widget.controller!.text.isNotEmpty;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surface,
                    border: Border.all(
                      color:
                          _isFocused
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.2),
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow:
                        _isFocused
                            ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? 'Search...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixIcon:
                          widget.leadingIcon ??
                          Icon(
                            Icons.search_rounded,
                            color:
                                _isFocused
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.6),
                          ),
                      suffixIcon:
                          _hasText
                              ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                onPressed: () {
                                  widget.controller?.clear();
                                  widget.onClear?.call();
                                  _focusNode.unfocus();
                                },
                              )
                              : null,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showFilter) ...[
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color:
                  widget.hasActiveFilters
                      ? colorScheme.primary
                      : colorScheme.surface,
              border: Border.all(
                color:
                    widget.hasActiveFilters
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: widget.onFilterTap,
              icon: Icon(
                Icons.tune_rounded,
                color:
                    widget.hasActiveFilters
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Dropdown field with modern design
class CustomDropdownField<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String? label;
  final String? hint;
  final String? errorText;
  final Function(T?)? onChanged;
  final String Function(T)? itemLabel;
  final bool enabled;
  final Widget? prefixIcon;
  final bool filled;
  final Color? fillColor;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.itemLabel,
    this.enabled = true,
    this.prefixIcon,
    this.filled = true,
    this.fillColor,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: theme.textTheme.titleSmall?.copyWith(
                color:
                    _isFocused
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items:
                widget.items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      widget.itemLabel?.call(item) ?? item.toString(),
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
            onChanged: widget.enabled ? widget.onChanged : null,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              filled: widget.filled,
              fillColor:
                  widget.fillColor ??
                  (widget.enabled
                      ? colorScheme.surfaceContainerLowest
                      : colorScheme.surfaceContainerLow.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            onTap: () {
              setState(() {
                _isFocused = true;
              });
            },
            menuMaxHeight: 300,
            dropdownColor: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
