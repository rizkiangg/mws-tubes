import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple static user page; could be wired to auth later
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman User')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: Agus'),
            SizedBox(height: 8),
            Text('Email: agus@example.com'),
          ],
        ),
      ),
    );
  }
}
