import 'dart:convert';

import 'package:sql_data_fatch/screens/details_screen.dart';
import 'package:sql_data_fatch/screens/home_screen.dart';
import 'package:sql_data_fatch/sql/sql_helper.dart';
import 'package:sql_data_fatch/sql/sql_helper_details.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
