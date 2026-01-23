import 'dart:typed_data';
import 'package:flutter/material.dart'; 
import 'package:image_picker/image_picker.dart';

import 'models/medicine.dart';
import 'services/gemeni_service_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Cloud OCR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Google Cloud Vision OCR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _imageBytes; // Используем байты вместо File для скорости
  List<Medicine> _medicines = []; // Список распознанных лекарств
  bool _isLoading = false;

  final MedicineScannerService _service = MedicineScannerService();
  final ImagePicker _picker = ImagePicker();

// В классе _MyHomePageState
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 30,
      maxWidth: 600,
    );

    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
      _medicines = [];
    });

    try {
      final bytes = await pickedFile.readAsBytes();

      // Замеряем время для дебага (опционально)
      final stopwatch = Stopwatch()..start();

      final List<dynamic> jsonList = await _service.scanImage(bytes);

      print("Сканирование заняло: ${stopwatch.elapsed.inSeconds} сек.");

      setState(() {
        _medicines = jsonList.map((m) => Medicine.fromJson(m)).toList();
      });

    } catch (e) {
      _showSnackBar("Ошибка: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📸 AI Аптечка"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildImagePreview(),
          const Divider(height: 1),
          Expanded(child: _buildResultArea()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPickerOptions,
        label: const Text("Сканировать"),
        icon: const Icon(Icons.document_scanner),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.black12,
      child: _imageBytes != null
          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
          : const Center(child: Text("Нет изображения")),
    );
  }

  Widget _buildResultArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_medicines.isEmpty) {
      return const Center(
        child: Text("Нажмите на кнопку, чтобы начать поиск лекарств"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final med = _medicines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(_getCategoryIcon(med.category)),
            ),
            title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${med.dosage} • ${med.category}"),
            trailing: Text(med.date, style: const TextStyle(color: Colors.redAccent)),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase().contains('анальгетик')) return Icons.healing;
    if (category.toLowerCase().contains('витамин')) return Icons.wb_sunny;
    return Icons.medication;
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
    );
  }
}