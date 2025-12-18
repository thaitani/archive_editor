import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditNameDialog extends ConsumerStatefulWidget {
  const AddEditNameDialog({
    super.key,
    this.existingName,
  });
  final String? existingName;

  @override
  ConsumerState<AddEditNameDialog> createState() => _AddEditNameDialogState();
}

class _AddEditNameDialogState extends ConsumerState<AddEditNameDialog> {
  late final TextEditingController _categoryController;
  late final TextEditingController _authorController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _authorController = TextEditingController();
    _titleController = TextEditingController();

    if (widget.existingName != null) {
      final regex = RegExp(r'^\((.*?)\)\[(.*?)\](.*)$');
      final match = regex.firstMatch(widget.existingName!);
      if (match != null) {
        _categoryController.text = match.group(1) ?? '';
        _authorController.text = match.group(2) ?? '';
        _titleController.text = match.group(3) ?? widget.existingName!;
      } else {
        _titleController.text = widget.existingName!;
      }
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _authorController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String _getFormattedName() {
    final category = _categoryController.text.trim();
    final author = _authorController.text.trim();
    final title = _titleController.text.trim();

    if (category.isEmpty && author.isEmpty && title.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    if (category.isNotEmpty) buffer.write('($category)');
    if (author.isNotEmpty) buffer.write('[$author]');
    buffer.write(title);

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingName == null ? 'Add Name' : 'Edit Name'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _categoryController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preview:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _getFormattedName().isEmpty
                    ? '(Category)[Author]Title v00'
                    : _getFormattedName(),
                style: TextStyle(
                  color:
                      _getFormattedName().isEmpty ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final text = _getFormattedName();
            if (text.isNotEmpty) {
              if (widget.existingName != null) {
                await ref
                    .read(nameSuggestionProvider.notifier)
                    .edit(widget.existingName!, text);
              } else {
                await ref.read(nameSuggestionProvider.notifier).add(text);
              }
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.existingName == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
