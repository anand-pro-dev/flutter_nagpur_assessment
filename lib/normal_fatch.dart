import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProviderApiData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crop Data',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProviderApiData>(
        builder: (context, providerData, _) {
          return providerData.loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: providerData.platforms.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Image.network(providerData.platforms[index]
                                ['iconURL']
                            .toString()),
                        title: Text(
                            providerData.platforms[index]['name'].toString()),
                        subtitle: Text(providerData.platforms[index]
                                ['description']
                            .toString()),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class ProviderApiData extends ChangeNotifier {
  bool loading = false;
  Map<String, dynamic> user = {};
  List platforms = [];

  Future<void> fetchData() async {
    loading = true;

    try {
      final result = await Services().get();
      user = result;
      platforms = result['data']['platforms'];

      log(user.toString());
    } catch (error) {
      log("Error fetching user details: $error");

      user = {};
    }

    loading = false;
    notifyListeners();
  }
}

class Services {
  var baseUrl =
      'https://assessment.sgp1.digitaloceanspaces.com/android/test/machineTest.json';

  Future<dynamic> get() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // log('Response data: $jsonData');
        return jsonData;
      } else {
        return {
          'status': false,
          '__': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle exceptions
      log('Exception: $e');
      return {
        'status': false,
        '__': e.toString(),
      };
    }
  }
}
