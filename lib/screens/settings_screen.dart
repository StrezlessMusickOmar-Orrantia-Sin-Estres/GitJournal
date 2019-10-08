import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';

import 'package:preferences/preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SettingsList(),
    );
  }
}

class SettingsList extends StatefulWidget {
  @override
  SettingsListState createState() {
    return SettingsListState();
  }
}

class SettingsListState extends State<SettingsList> {
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();
  final gitAuthorEmailKey = GlobalKey<FormFieldState<String>>();
  final fontSizeKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;

    var saveGitAuthor = (String gitAuthor) {
      Settings.instance.gitAuthor = gitAuthor;
      Settings.instance.save();
    };

    var gitAuthorForm = Form(
      child: TextFormField(
        key: gitAuthorKey,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Who should author the changes?',
          labelText: 'Full Name',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthor,
        onSaved: saveGitAuthor,
        initialValue: Settings.instance.gitAuthor,
      ),
      onChanged: () {
        if (!gitAuthorKey.currentState.validate()) return;
        var gitAuthor = gitAuthorKey.currentState.value;
        saveGitAuthor(gitAuthor);
      },
    );

    var saveGitAuthorEmail = (String gitAuthorEmail) {
      Settings.instance.gitAuthorEmail = gitAuthorEmail;
      Settings.instance.save();
    };
    var gitAuthorEmailForm = Form(
      child: TextFormField(
        key: gitAuthorEmailKey,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          hintText: 'Who should author the changes?',
          labelText: 'Email',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter an email';
          }

          bool emailValid =
              RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
          if (!emailValid) {
            return 'Please enter a valid email';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthorEmail,
        onSaved: saveGitAuthorEmail,
        initialValue: Settings.instance.gitAuthorEmail,
      ),
      onChanged: () {
        if (!gitAuthorEmailKey.currentState.validate()) return;
        var gitAuthorEmail = gitAuthorEmailKey.currentState.value;
        saveGitAuthorEmail(gitAuthorEmail);
      },
    );

    return PreferencePage([
      SettingsHeader('Display Settings'),
      DropdownPreference(
        'Theme',
        'theme',
        defaultVal: "Light",
        values: ["Light", "Dark"],
        onChange: (newVal) {
          var dynamicTheme = DynamicTheme.of(context);
          switch (newVal) {
            case "Dark":
              dynamicTheme.setBrightness(Brightness.dark);
              break;
            case "Light":
            case "default":
              dynamicTheme.setBrightness(Brightness.light);
              break;
          }
        },
      ),
      ListTile(
        title: Text("Font Size"),
        subtitle: Text(settings.noteFontSize.toPublicString()),
        onTap: () async {
          var fontSize = await showDialog<NoteFontSize>(
            context: context,
            builder: (context) => FontSizeSettingsDialog(),
          );

          if (fontSize != null) {
            Settings.instance.noteFontSize = fontSize;
            Settings.instance.save();
            setState(() {});
          }
        },
      ),
      SettingsHeader("Git Author Settings"),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      SizedBox(height: 16.0),
      SettingsHeader("Storage"),
      DropdownPreference(
        'File Name',
        'file_name',
        defaultVal: "ISO8601 With TimeZone",
        values: [
          "ISO8601 With TimeZone",
          "ISO8601",
          "ISO8601 without Colons",
        ],
        onChange: (newVal) {
          NoteFileNameFormat format;
          switch (newVal) {
            case "ISO8601 With TimeZone":
              format = NoteFileNameFormat.Iso8601WithTimeZone;
              break;
            case "ISO8601":
              format = NoteFileNameFormat.Iso8601;
              break;
            case "ISO8601 without Colons":
              format = NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon;
              break;
            default:
              format = NoteFileNameFormat.Iso8601WithTimeZone;
          }
          Settings.instance.noteFileNameFormat = format;
          Settings.instance.save();
        },
      ),
      SizedBox(height: 16.0),
      SettingsHeader("Analytics"),
      CheckboxPreference(
        "Collect Anonymous Usage Statistics",
        "usage_stats",
        defaultVal: Settings.instance.collectUsageStatistics,
        onEnable: () {
          Settings.instance.collectUsageStatistics = true;
          Settings.instance.save();
        },
        onDisable: () {
          Settings.instance.collectUsageStatistics = false;
          Settings.instance.save();
        },
      ),
      CheckboxPreference(
        "Collect Anonymous Crash Reports",
        "crash_reports",
        defaultVal: Settings.instance.collectCrashReports,
        onEnable: () {
          Settings.instance.collectCrashReports = true;
          Settings.instance.save();
        },
        onDisable: () {
          Settings.instance.collectCrashReports = false;
          Settings.instance.save();
        },
      ),
      VersionNumberTile(),
    ]);
  }
}

class SettingsHeader extends StatelessWidget {
  final String text;
  SettingsHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 0.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class VersionNumberTile extends StatefulWidget {
  @override
  VersionNumberTileState createState() {
    return VersionNumberTileState();
  }
}

class VersionNumberTileState extends State<VersionNumberTile> {
  String versionText = "";

  @override
  void initState() {
    super.initState();

    () async {
      var str = await getVersionString();
      setState(() {
        versionText = str;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Text("Version Info", style: textTheme.subhead),
      subtitle: Text(
        versionText,
        style: textTheme.body1,
        textAlign: TextAlign.left,
      ),
      enabled: false,
    );
  }
}

class FontSizeSettingsDialog extends StatelessWidget {
  final String title = "Font Size";

  @override
  Widget build(BuildContext context) {
    var sizes = <Widget>[];
    for (var fontSize in NoteFontSize.options) {
      var tile = _constructTile(context, fontSize);
      sizes.add(tile);
    }

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: sizes,
        ),
      ),
    );
  }

  ListTile _constructTile(BuildContext context, NoteFontSize fontSize) {
    var style = Theme.of(context).textTheme.body1;
    style = style.copyWith(fontSize: fontSize.toDouble());

    return ListTile(
      title: Text(fontSize.toPublicString(), style: style),
      onTap: () {
        Navigator.of(context).pop(fontSize);
      },
    );
  }
}
