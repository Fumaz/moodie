import 'package:flutter/cupertino.dart';
import 'package:moodie/app/page/entries_page.dart';
import 'package:moodie/database/database.dart';

class NotePage extends StatefulWidget {
  final TertiaryMood mood;

  const NotePage({Key? key, required this.mood}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _textController = TextEditingController();
  late TertiaryMood mood = widget.mood;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Note'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: CupertinoColors.systemPink,
        ),
        trailing: GestureDetector(
          child: Icon(
            CupertinoIcons.check_mark_circled,
            color: CupertinoColors.systemPink,
          ),
          onTap: () {
            Entry entry = Entry(
              DateTime.now(),
              mood,
              _textController.text,
            );


            insertEntry(entry).then((value) =>
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => const EntriesPage(),
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _textController,
                autofocus: true,
                autocorrect: true,
                placeholder: 'Enter note',
                keyboardType: TextInputType.multiline,
                maxLines: 999,
              ),
              ),
          ],
        ),
      ),
    );
  }
}
