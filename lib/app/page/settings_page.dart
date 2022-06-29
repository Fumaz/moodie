import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  bool isItalian() {
    return preferences?.getBool("italian") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: CupertinoColors.systemPink,
        ),
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Coming Soon..."),
                Spacer(),
                CupertinoSwitch(
                  value: isItalian(),
                  onChanged: (value) async {
                    await preferences?.setBool("italian", value);
                    setState(() {});
                  },
                ),
              ],
            )
          ]
        ),
      )
    );
  }
}
