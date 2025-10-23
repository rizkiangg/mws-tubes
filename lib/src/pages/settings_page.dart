import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Notifikasi'),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            ListTile(
              title: const Text('Versi aplikasi'),
              subtitle: const Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }
}
