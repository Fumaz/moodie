import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:moodie/app/charts.dart';
import 'package:moodie/app/page/selection_page.dart';
import 'package:moodie/app/page/settings_page.dart';
import 'package:moodie/database/database.dart';

import '../../util/colors.dart';
import '../app.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({Key? key}) : super(key: key);

  @override
  _EntriesPageState createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  List<Entry> _entries = [];

  @override
  void initState() {
    super.initState();
    entries().then((value) => setState(() => _entries = value));
  }

  Widget createSliverList() {
    if (_entries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('😶', style: TextStyle(fontSize: 125)),
              Text(
                'No entries yet!',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Tap the + button to add one.',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = _entries[index];
          return Slidable(
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                  onPressed: (context) {
                    setState(() {
                      _entries.remove(entry);
                    });
                    deleteEntry(entry);
                  },
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.red,
                  icon: CupertinoIcons.delete,
                  label: 'Delete',
                )
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                  onPressed: (context) {},
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.blue,
                  icon: CupertinoIcons.share,
                  label: 'Share',
                )
              ],
            ),
            child: Card(
              color: lighten(entry.mood.parent.parent.color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
              child: ListTile(
                leading: Text(
                  entry.mood.parent.parent.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(entry.mood.name.toUpperCase(),
                        style: TextStyle(
                            color: getTextColor(),
                            fontWeight: FontWeight.bold)),
                    Expanded(child: Container()),
                    Text(
                      DateFormat('d MMMM - HH:mm').format(entry.timestamp),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: getTextColor(), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                subtitle: Text(
                    entry.note.replaceAll('\n', '').length > 20
                        ? entry.note.replaceAll('\n', '').substring(0, 20) +
                            "..."
                        : entry.note.replaceAll('\n', ''),
                    style: TextStyle(color: getTextColor())),
                onTap: () => showNotes(entry),
              ),
            ),
          );
        },
        childCount: _entries.length,
      ),
    );
  }

  void showNotes(Entry entry) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              DateFormat('d MMMM - HH:mm').format(entry.timestamp),
            ),
            content: Text(entry.note),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void showChart() {
    SimpleTimeSeriesChart.createSeries().then((value) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text('Last 15 moods'),
              content: SizedBox(
                  width: 700,
                  height: 300,
                  child: Column(children: [
                    SizedBox(
                      width: 700,
                      height: 235,
                      child: SimpleTimeSeriesChart(
                        series: value,
                        animate: true,
                      ),
                    ),
                    CupertinoButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context))
                  ])),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: GestureDetector(
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.systemPink,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SelectionPage()));
              },
              onLongPress: () {
                TertiaryMood mood = ((moods.toList()..shuffle()).first)
                    .submoods
                    .first
                    .submoods
                    .first;
                Entry entry = Entry(DateTime.now(), mood, "owo woow");

                insertEntry(entry);
                setState(() {
                  _entries.add(entry);
                });
              },
            ),
            trailing: GestureDetector(
                child: const Icon(CupertinoIcons.chart_bar_square,
                    color: CupertinoColors.systemPink),
                onTap: () {
                  showChart();
                }),
            middle: const Text('Moodie'),
          ),
          child:
              SafeArea(child: CustomScrollView(slivers: [createSliverList()]))),
    );
  }
}
