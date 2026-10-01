import 'package:flutter/material.dart';
import 'database/database_helper.dart';   // ← tambahkan ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // ← wajib sebelum akses DB
  await DatabaseHelper.instance.database;      // ← inisialisasi DB
  runApp(const MediaStudioApp());
}