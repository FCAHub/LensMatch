import 'package:flutter/material.dart';

class ScanHistoryView extends StatelessWidget {
  const ScanHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: const Center(
        child: Text('No past face scans found.'),
      ),
    );
  }
}
