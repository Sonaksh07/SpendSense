import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/transaction.dart';
import '../models/categories.dart';
import '../services/transaction_service.dart';

class UploadPassbookScreen extends StatefulWidget {
  const UploadPassbookScreen({super.key});

  @override
  State<UploadPassbookScreen> createState() => _UploadPassbookScreenState();
}

class _UploadPassbookScreenState extends State<UploadPassbookScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Passbook')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 80),
            const SizedBox(height: 20),
            const Text('Upload CSV or PDF passbook'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Choose File'),
            ),
            if (_isProcessing) const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 20),
            const Text('Supported formats: CSV (bank statement)'),
            const Text('PDF support coming soon', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'pdf'],
    );
    if (result == null) return;
    final file = result.files.first;
    setState(() => _isProcessing = true);
    if (file.extension == 'csv') {
      await _parseCSV(file.bytes!);
    } else {
      // PDF placeholder: show dialog that it's not implemented yet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF parsing not yet available. Please use CSV.')),
      );
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _parseCSV(List<int> bytes) async {
    final String content = String.fromCharCodes(bytes);
    List<List<dynamic>> rows = const CsvToListConverter().convert(content);
    // Assume header row: Date, Description, Debit, Credit, Balance
    // Adjust based on common formats
    List<Transaction> imported = [];
    for (var row in rows.skip(1)) {
      if (row.length < 4) continue;
      final dateStr = row[0].toString();
      final desc = row[1].toString();
      final debit = row[2].toString().isNotEmpty ? double.tryParse(row[2].toString()) : null;
      final credit = row[3].toString().isNotEmpty ? double.tryParse(row[3].toString()) : null;
      final amount = debit ?? credit ?? 0.0;
      if (amount == 0.0) continue;
      DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
      // Simple category detection from description
      SpendingCategory cat = SpendingCategory.other;
      if (desc.toLowerCase().contains('swiggy') || desc.toLowerCase().contains('zomato')) cat = SpendingCategory.food;
      else if (desc.toLowerCase().contains('uber') || desc.toLowerCase().contains('ola')) cat = SpendingCategory.transport;
      else if (desc.toLowerCase().contains('amazon') || desc.toLowerCase().contains('flipkart')) cat = SpendingCategory.shopping;
      // Create transaction
      imported.add(Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString() + imported.length.toString(),
        amount: amount,
        merchant: desc.length > 20 ? desc.substring(0, 20) : desc,
        timestamp: date,
        rawDescription: desc,
        category: cat,
        confidence: 0.7,
        anomalyScore: 0.3,
        isImpulse: false,
      ));
    }
    TransactionService().addMultipleTransactions(imported);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${imported.length} transactions')));
      Navigator.pop(context);
    }
  }
}