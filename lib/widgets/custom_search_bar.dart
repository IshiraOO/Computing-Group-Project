import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final EdgeInsetsGeometry? margin;
  final Widget? prefix;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double borderRadius;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.margin,
    this.prefix,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.borderRadius = 12,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = widget.iconColor ?? theme.colorScheme.primary;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: _isFocused
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: _isFocused ? 15 : 10,
            spreadRadius: _isFocused ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
          prefixIcon: widget.prefix ?? Icon(
            Icons.search,
            color: effectiveIconColor,
            size: 22,
          ),
          suffixIcon: _controller != null && _controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: effectiveIconColor,
                  size: 20,
                ),
                onPressed: () {
                  _controller!.clear();
                  widget.onChanged('');
                  if (widget.onClear != null) {
                    widget.onClear!();
                  }
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.surface),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 1.5),
          ),
        ),
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 16, color: widget.textColor ?? theme.colorScheme.onSurface),
        cursorColor: theme.colorScheme.primary,
        cursorWidth: 1.5,
      ),
    );
  }
}