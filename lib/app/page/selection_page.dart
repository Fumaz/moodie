import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:moodie/app/page/note_page.dart';
import 'package:moodie/database/database.dart';
import 'package:moodie/util/colors.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  PrimaryMood? _primaryMood;
  SecondaryMood? _secondaryMood;
  TertiaryMood? _tertiaryMood;

  FortuneItem createItem(String text, Color color, double angle, onTap) {
    return FortuneItem(
        child: Transform.rotate(angle: angle, child: Text(text)),
        onTap: onTap,
        onLongPress: () {
          if (_tertiaryMood != null) {
            setState(() => _tertiaryMood = null);
            return;
          }

          if (_secondaryMood != null) {
            setState(() => _secondaryMood = null);
            return;
          }

          if (_primaryMood != null) {
            setState(() => _primaryMood = null);
            return;
          }
        },
        style: FortuneItemStyle(
          color: color,
          textAlign: TextAlign.center,
          textStyle: const TextStyle(
            fontSize: 25,
          ),
        ));
  }

  List<FortuneItem> createItems() {
    if (_primaryMood == null) {
      return createItemsDynamically(moods, (mood) => _primaryMood = mood);
    }

    if (_secondaryMood == null) {
      return createItemsDynamically(_primaryMood!.submoods, (mood) => _secondaryMood = mood);
    }

    return createItemsDynamically(_secondaryMood!.submoods, (mood) {
      _tertiaryMood = mood;
      Navigator.push(context, CupertinoPageRoute(builder: (context) => NotePage(mood: mood)));
    });
  }

  List<FortuneItem> createItemsDynamically(List<dynamic> moods, onTap) {
    return [
      for (int i = 0; i < moods.length; i++)
        createItem(moods[i].name, (moods[i] is PrimaryMood) ? moods[i].color : (i % 2 == 0 ? _primaryMood!.color : lighten(_primaryMood!.color)), i >= (moods.length / 2) ? pi : 0, () {
          setState(() => onTap(moods[i]));
        })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('How are you feeling?'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            if (_tertiaryMood != null) {
              setState(() => _tertiaryMood = null);
            } else if (_secondaryMood != null) {
              setState(() => _secondaryMood = null);
            } else if (_primaryMood != null) {
              setState(() => _primaryMood = null);
            } else {
              Navigator.pop(context);
            }
          },
          color: CupertinoColors.systemPink,
        ),
      ),
      child: AnimatedOpacity(
        opacity: 1.0,
    duration: const Duration(seconds: 1),
    child: Transform.rotate(
      angle: _secondaryMood == null ? 0 : pi / 2,
      child:Center(
        child: SizedBox(
          width: 350,
          height: 350,
          child: FortuneWheel(
            items: createItems(),
            physics: NoPanPhysics(),
            // duration: const Duration(milliseconds: 1),
            curve: FortuneCurve.none,
            animateFirst: false,
            indicators: const [],
            styleStrategy: const UniformStyleStrategy(),
          ),
        ),
      ),
    )
      )
    );
  }
}
