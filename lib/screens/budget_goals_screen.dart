import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  Map<String, dynamic>? _goal;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();

  File? _image;

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // 💾 Save Goal
  void _saveGoal() {
    final name = _nameController.text.trim();
    final target = double.tryParse(_targetController.text) ?? 0;
    final saved = double.tryParse(_savedController.text) ?? 0;

    if (name.isEmpty || target <= 0) return;

    setState(() {
      _goal = {
        "name": name,
        "target": target,
        "saved": saved,
        "image": _image?.path,
      };
    });

    Navigator.pop(context);
  }

  // ➕ Bottom Sheet
  void _showGoalInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set Your Goal 🎯",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Goal Name",
                ),
              ),

              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Amount (₹)",
                ),
              ),

              TextField(
                controller: _savedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Starting Savings (₹)",
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Add Image"),
                  ),
                  const SizedBox(width: 10),
                  if (_image != null)
                    const Text("Image selected ✅"),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _saveGoal,
                child: const Text("Save Goal"),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎯 Goal UI
  Widget _buildGoalView() {
    final saved = (_goal!['saved'] as num).toDouble();
    final target = (_goal!['target'] as num).toDouble();
    final progress = (saved / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_goal!['image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_goal!['image']),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 16),

        Text(
          _goal!['name'],
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
        ),

        const SizedBox(height: 10),

        Text(
          "₹${saved.toInt()} / ₹${target.toInt()}",
          style: const TextStyle(fontSize: 16),
        ),

        Text("${(progress * 100).toInt()}% completed"),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "💡 Update your savings regularly to track progress!",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Goal"),
        actions: [
          if (_goal != null)
            IconButton(
              onPressed: _showGoalInputSheet,
              icon: const Icon(Icons.edit),
            )
        ],
      ),

      floatingActionButton: _goal == null
          ? FloatingActionButton.extended(
              onPressed: _showGoalInputSheet,
              icon: const Icon(Icons.add),
              label: const Text("Set Goal"),
            )
          : null,

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _goal == null
                  ? const Center(
                      child: Text(
                        "No goal set yet 🚀\nTap + to create one",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildGoalView(),
            ),
    );
  }
}