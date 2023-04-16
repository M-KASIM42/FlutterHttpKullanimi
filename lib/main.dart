import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'HTTP Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  

  List<Map<dynamic, dynamic>> _list = [];

  Future<void> _fetchCountries() async {
    var response = await http
        .get(Uri.parse("http://8a11-34-71-84-212.ngrok-free.app/countries"));

    if (response.statusCode == 200) {
      setState(() {
        _list = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      throw Exception('Failed to fetch countries');
    }
  }

  Future<void> _createCountry() async {
    var response = await http.post(
      Uri.parse("http://8a11-34-71-84-212.ngrok-free.app/countries"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'area': int.parse(_areaController.text),
        'capital': _capitalController.text,
        'name': _nameController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _areaController.clear();
        _capitalController.clear();
        _nameController.clear();
      });
      _fetchCountries();
    } else {
      throw Exception('Failed to create country');
    }
  }

  Future<void> _updateCountry(int id) async {
    var response = await http.put(
      Uri.parse("http://8a11-34-71-84-212.ngrok-free.app/countries/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'area': int.parse(_areaController.text),
        'capital': _capitalController.text,
        'name': _nameController.text
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _areaController.clear();
        _capitalController.clear();
        _nameController.clear();
      });
      _fetchCountries();
    } else {
      throw Exception('Failed to update country');
    }
  }

  Future<void> _deleteCountry(int id) async {
    var response = await http.delete(
        Uri.parse("http://8a11-34-71-84-212.ngrok-free.app/countries/$id"));
    if (response.statusCode == 200) {
      _fetchCountries();
    } else {
      throw Exception('Failed to delete country');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText:  'Enter area',
              ),
            ),
            TextField(
              controller: _capitalController,
              decoration: const InputDecoration(
                hintText: 'Enter capital',
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createCountry,
              child:const Text('Create Country'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  final country = _list[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        country["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(country["area"].toString()),
                      Text(country["capital"]),
                      Text(country["id"].toString()),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () => _updateCountry(country['id']),
                            child: const Text('Edit'),
                          ),
                          ElevatedButton(
                            onPressed: () => _deleteCountry(country['id']),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}