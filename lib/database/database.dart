import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<PrimaryMood> moods = [];

class PrimaryMood {
  final String name;
  final String emoji;
  final Color color;
  final List<SecondaryMood> submoods = [];

  PrimaryMood(this.name, this.emoji, this.color);

  PrimaryMood add(String name, List<String> subs) {
    SecondaryMood submood = SecondaryMood(this, name, []);

    for (String sub in subs) {
      submood.add(sub);
    }

    submoods.add(submood);
    return this;
  }

  static PrimaryMood getByName(String name) {
    return moods.firstWhere((mood) => mood.name == name);
  }
}

class SecondaryMood {
  final PrimaryMood parent;
  final String name;
  final List<TertiaryMood> submoods;

  SecondaryMood(this.parent, this.name, this.submoods);

  SecondaryMood add(String name) {
    submoods.add(TertiaryMood(this, name));
    return this;
  }

  static SecondaryMood? getByName(String name) {
    for (PrimaryMood mood in moods) {
      for (SecondaryMood submood in mood.submoods) {
        if (submood.name == name) {
          return submood;
        }
      }
    }

    return null;
  }
}

class TertiaryMood {
  final SecondaryMood parent;
  final String name;

  TertiaryMood(this.parent, this.name);

  static TertiaryMood? getByName(String name) {
    for (PrimaryMood mood in moods) {
      for (SecondaryMood submood in mood.submoods) {
        for (TertiaryMood tertiary in submood.submoods) {
          if (tertiary.name == name) {
            return tertiary;
          }
        }
      }
    }

    return null;
  }
}

class Entry {
  final DateTime timestamp;
  TertiaryMood mood;
  String note;

  Entry(this.timestamp, this.mood, this.note);

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mood': mood.name,
      'note': note
    };
  }

  @override
  String toString() {
    return 'Entry{timestamp: $timestamp, mood: $mood, note: $note}';
  }
}

late Future<Database> database;

Future<void> insertEntry(Entry entry) async {
  final Database db = await database;
  await db.insert('entries', entry.toMap());
}

Future<void> deleteEntry(Entry entry) async {
  final Database db = await database;
  await db.delete('entries', where: 'timestamp = ?', whereArgs: [entry.timestamp.millisecondsSinceEpoch]);
}

Future<List<Entry>> entries() async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query('entries', orderBy: 'timestamp DESC');

  return List.generate(maps.length, (i) {
    return Entry(DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        TertiaryMood.getByName(maps[i]['mood'])!, maps[i]['note']);
  });
}

Future<List<Entry>> last(int limit) async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps =
      await db.query('entries', orderBy: 'timestamp DESC', limit: limit);

  return List.generate(maps.length, (i) {
    return Entry(DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        TertiaryMood.getByName(maps[i]['mood'])!, maps[i]['note']);
  });
}

Future<int> setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  loadMoods();

  database = openDatabase(join(await getDatabasesPath(), 'moods.db'),
      onCreate: (db, version) {
    db.execute(
        'CREATE TABLE entries (timestamp INTEGER PRIMARY KEY, mood TEXT, note TEXT)');
  }, version: 1);

  return 0;
}

void loadMoods() {
  PrimaryMood anger =
      PrimaryMood('angry', '😡', CupertinoColors.destructiveRed);
  PrimaryMood disgust =
      PrimaryMood('disgusted', '🤢', CupertinoColors.activeGreen);
  PrimaryMood fear = PrimaryMood('afraid', '😨', CupertinoColors.systemPurple);
  PrimaryMood happy = PrimaryMood('happy', '😂', CupertinoColors.systemYellow);
  PrimaryMood sad = PrimaryMood('sad', '😢', CupertinoColors.systemBlue);
  PrimaryMood surprise =
      PrimaryMood('surprised', '😮', CupertinoColors.activeOrange);

  anger.add('aggressive', ['provoked', 'hostile']);
  anger.add('critical', ['skeptical', 'sarcastic']);
  anger.add('distant', ['withdrawn', 'suspicious']);
  anger.add('frustrated', ['irritated', 'infuriated']);
  anger.add('hateful', ['violated', 'resentful']);
  anger.add('hurt', ['devastated', 'embarassed']);
  anger.add('mad', ['enraged', 'furious']);
  anger.add('threatened', ['jealous', 'insecure']);

  disgust.add('avoidant', ['hesitant', 'aversive']);
  disgust.add('awful', ['detestable', 'repulsive']);
  disgust.add('disappointed', ['revolted', 'repugnant']);
  disgust.add('disapproving', ['loathing', 'judgemental']);

  fear.add('anxious', ['worried', 'overwhelmed']);
  fear.add('humiliated', ['ridiculed', 'disrespected']);
  fear.add('insecure', ['inferior', 'inadequate']);
  fear.add('rejected', ['alienated', 'inadequate']);
  fear.add('scared', ['frightened', 'terrified']);
  fear.add('submissive', ['insignificant', 'worthless']);

  happy.add('accepted', ['satisfied', 'respected']);
  happy.add('interested', ['inquisitive', 'amused']);
  happy.add('intimate', ['sensitive', 'playful']);
  happy.add('joyful', ['estatic', 'liberated']);
  happy.add('optimistic', ['inspired', 'open']);
  happy.add('peaceful', ['loving', 'hopeful']);
  happy.add('powerful', ['provocative', 'courageous']);
  happy.add('proud', ['important', 'confident']);

  sad.add('abandoned', ['ignored', 'victimized']);
  sad.add('bored', ['apathetic', 'indifferent']);
  sad.add('depressed', ['empty', 'inferior']);
  sad.add('despaired', ['vulnerable', 'powerless']);
  sad.add('guilty', ['ashamed', 'remorseful']);
  sad.add('lonely', ['isolated', 'abandoned']);

  surprise.add('amazed', ['in awe', 'astonished']);
  surprise.add('confused', ['disillusioned', 'perplexed']);
  surprise.add('excited', ['eager', 'energetic']);
  surprise.add('startled', ['shocked', 'dismayed']);

  moods.add(anger);
  moods.add(fear);
  moods.add(disgust);
  moods.add(sad);
  moods.add(surprise);
  moods.add(happy);
}
