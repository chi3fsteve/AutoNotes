import 'package:flutter/material.dart';
import 'constants.dart';

typedef NoteSavedCallback = Future<void> Function(Map<String, dynamic> note);

class NoteCreationPage extends StatefulWidget {
  final NoteSavedCallback onNoteSaved;
  final ValueNotifier<Map<String, dynamic>?> noteNotifier;

  const NoteCreationPage({
    super.key,
    required this.onNoteSaved,
    required this.noteNotifier,
  });

  @override
  State<NoteCreationPage> createState() => _NoteCreationPageState();
}

class _NoteCreationPageState extends State<NoteCreationPage> {
  late TextEditingController _contentController;
  bool _isNoteSaved = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.noteNotifier.value?['content'] ?? '',
    );
  }

  Future<void> _onNoteContentChanged() async {
    await _saveNote();
  }

  Future<void> _saveNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      await widget.onNoteSaved({'id': widget.noteNotifier.value!['id'], 'delete': true});
      return;
    }
    final note = {
      'id': widget.noteNotifier.value!['id'],
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await widget.onNoteSaved(note);
    widget.noteNotifier.value = note;
    _isNoteSaved = true;
  }

  @override
  void dispose() {
    if (!_isNoteSaved && _contentController.text.trim().isEmpty) {
      widget.onNoteSaved({'id': widget.noteNotifier.value!['id'], 'delete': true});
    }
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Theme.of(context).colorScheme.inversePrimary,
            height: 4.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(kAppTitle, style: kTitleTextStyle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(color: Theme.of(context).colorScheme.background),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _onNoteContentChanged();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}