import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'constants.dart';
import 'note_creation_page.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Theme.of(context).colorScheme.onBackground,
        useMaterial3: true,
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper.instance.getAllNotes();
    setState(() {
      _notes = List.from(notes)
        ..sort((a, b) => b['updated_at'].compareTo(a['updated_at']));
    });
  }

  void _navigateToNoteCreationPage(Map<String, dynamic> note) {
    final noteNotifier = ValueNotifier<Map<String, dynamic>>(note);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteCreationPage(
          onNoteSaved: _editNote,
          noteNotifier: noteNotifier,
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final newNote = {
      'content': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final noteId = await DatabaseHelper.instance.insertNote(newNote);
    final createdNote = {
      'id': noteId,
      ...newNote,
    };
    _navigateToNoteCreationPage(createdNote);
  }

  Future<void> _editNote(Map<String, dynamic> note) async {
  if (note.containsKey('delete') && note['delete'] == true) {
    await _deleteNote(note['id']);
  } else {
    await DatabaseHelper.instance.updateNote(note);
  }
  _loadNotes();
}

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(kAppTitle, style: kTitleTextStyle),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Theme.of(context).colorScheme.inversePrimary,
            height: 5.0,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(15),
        itemCount: _notes.length,
        separatorBuilder: (context, index) => Container(
          margin: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        itemBuilder: (context, index) {
          final note = _notes[index];
          final limitedContent = note['content'].length > 50
              ? '${note['content'].substring(0, 50)}...'
              : note['content'];

          return Slidable(
            key: Key(note['id'].toString()),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _deleteNote(note['id']),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Color.fromARGB(205, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                limitedContent,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                    fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DateFormat.yMd()
                    .add_Hm()
                    .format(DateTime.parse(note['updated_at'])),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.66)),
              ),
              onTap: () {
                _navigateToNoteCreationPage(note);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}
