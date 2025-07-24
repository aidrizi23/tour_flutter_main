import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with TickerProviderStateMixin {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
                if (hasFocus) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      _isFocused && !_hasError
                          ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.isPassword,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  enabled: widget.enabled,
                  inputFormatters: widget.inputFormatters,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.enabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.5),
                  ),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    prefixIcon:
                        widget.prefixIcon != null
                            ? Container(
                              margin: const EdgeInsets.only(left: 12, right: 8),
                              child: Icon(
                                widget.prefixIcon,
                                size: 22,
                                color:
                                    _isFocused
                                        ? (_hasError
                                            ? colorScheme.error
                                            : colorScheme.primary)
                                        : colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                              ),
                            )
                            : null,
                    suffixIcon:
                        widget.suffixIcon != null
                            ? Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: widget.suffixIcon,
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                            _hasError
                                ? colorScheme.error.withOpacity(0.3)
                                : colorScheme.outline.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                            _hasError ? colorScheme.error : colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        widget.enabled
                            ? (_isFocused
                                ? colorScheme.surfaceContainerHighest
                                    .withOpacity(0.8)
                                : colorScheme.surfaceContainerLow.withOpacity(
                                  0.5,
                                ))
                            : colorScheme.surfaceContainerLow.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color:
                          _isFocused
                              ? (_hasError
                                  ? colorScheme.error
                                  : colorScheme.primary)
                              : colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: _isFocused ? 14 : 16,
                    ),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 16,
                      vertical: 16,
                    ),
                    counterText: widget.maxLength != null ? null : '',
                    errorStyle: TextStyle(
                      color: colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (value) {
                    if (widget.validator != null) {
                      final error = widget.validator!(value);
                      setState(() {
                        _hasError = error != null;
                        _errorText = error;
                      });
                      return error;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_hasError && widget.validator != null) {
                      // Clear error when user starts typing
                      final error = widget.validator!(value);
                      if (error == null) {
                        setState(() {
                          _hasError = false;
                          _errorText = null;
                        });
                      }
                    }
                    widget.onChanged?.call(value);
                  },
                  onFieldSubmitted: widget.onFieldSubmitted,
                ),
              ),
            ),
            // Additional error text display (optional)
            if (_hasError && _errorText != null)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const CustomSearchField({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.showFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                ),
              if (showFilter && onFilterTap != null)
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                  onPressed: onFilterTap,
                ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String hint;
  final void Function(T?)? onChanged;
  final String Function(T) displayText;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool enabled;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.label,
    this.hint = 'Select an option',
    required this.onChanged,
    required this.displayText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonFormField<T>(
        value: value,
        items:
            items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  displayText(item),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
        onChanged: enabled ? onChanged : null,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              prefixIcon != null
                  ? Container(
                    margin: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      prefixIcon,
                      size: 22,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor:
              enabled
                  ? colorScheme.surfaceContainerLow.withOpacity(0.5)
                  : colorScheme.surfaceContainerLow.withOpacity(0.3),
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.normal,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 50,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 8 : 16,
            vertical: 16,
          ),
        ),
        dropdownColor: colorScheme.surfaceContainerHigh,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}   
