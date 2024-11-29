import 'package:flutter/material.dart';

class AddWater extends StatelessWidget {
  const AddWater({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Water'),
      ),
      body: const Center(
        child: Text(
          'Add Water',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
