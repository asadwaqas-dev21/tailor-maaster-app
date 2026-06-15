import "dart:async";

import "package:flutter/material.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:tailor_app/core/constants/app_constants.dart";

class AppSearchBar extends StatefulWidget {
  final String hint;
  final void Function(String) onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      widget.onChanged(value);
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged("");
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: _onClear,
              );
            },
          ),
        ),
      ),
    );
  }
}
