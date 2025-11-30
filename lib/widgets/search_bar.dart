import 'package:flutter/material.dart';
import '../utils/palette.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  void _onTextChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: TextStyle(color: Palette.onPrimary),
      cursorColor: Palette.accent,
      decoration: InputDecoration(
        hintText: "Cari materi...",
        hintStyle: TextStyle(color: Palette.onPrimary.withOpacity(0.6)),
        prefixIcon: Icon(Icons.search, color: Palette.onPrimary.withOpacity(0.7)),
        suffixIcon: hasText
            ? IconButton(
                icon: Icon(Icons.clear, color: Palette.onPrimary.withOpacity(0.7)),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Palette.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Palette.accent, width: 1.2),
        ),
      ),
    );
  }
}
