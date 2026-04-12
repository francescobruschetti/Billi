import 'package:flutter/material.dart';

class SearchFieldWidget extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClose;

  const SearchFieldWidget({
    super.key,
    required this.hintText,
    this.icon,
    required this.onChanged,
    this.onClose,
  });

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClose() {
    _controller.clear(); // svuota il campo
    widget.onChanged(''); // notifica il parent che il testo è vuoto
    widget.onClose?.call(); // chiama il callback onClose se è stato fornito
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      autoFocus: true,
      controller: _controller,
      hintText: widget.hintText,
      leading: widget.icon != null ? Icon(widget.icon) : const Icon(Icons.search),
      onChanged: widget.onChanged,
      shadowColor: WidgetStateProperty.all(Colors.transparent), // Remove shadow
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),        
        ),
      ),
      trailing: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onClose,
            tooltip: 'Chiudi',
          ),
      ],
    );
  }
}