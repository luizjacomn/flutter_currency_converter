import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const uri = 'https://api.hgbrasil.com/finance?format=json&key=de9111d9';
const resultsKey = 'results';
const currenciesKey = 'currencies';
const dollarKey = 'USD';
const euroKey = 'EUR';
const buyKey = 'buy';
final _green = Colors.tealAccent;
final _gray = Colors.blueGrey[200];
final _darkGray = Colors.blueGrey[800];
final _icon = Icons.autorenew;
final _iconReset = Icons.refresh;

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: _gray),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(uri);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _realController = TextEditingController();
  final _dolarController = TextEditingController();
  final _euroController = TextEditingController();

  double _dolar;
  double _euro;

  void _resetFields() {
    _realController.clear();
    _dolarController.clear();
    _euroController.clear();
  }

  void _realChanged(String text) {
    double real = double.parse(text);
    _dolarController.text = (real / _dolar).toStringAsFixed(2);
    _euroController.text = (real / _euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    var emDolares = _dolar * dolar;
    _realController.text = (emDolares).toStringAsFixed(2);
    _euroController.text = (emDolares / _euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    double emReais = euro * _euro;
    _realController.text = (emReais).toStringAsFixed(2);
    _dolarController.text = (emReais / _dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkGray,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _iconReset,
              color: _darkGray,
            ),
            onPressed: () {
              _resetFields();
            },
          )
        ],
        centerTitle: true,
        title: Text(
          '\$ Conversor de moedas \$',
          style: TextStyle(
            color: _darkGray,
          ),
        ),
        backgroundColor: _green,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando dados...',
                    style: TextStyle(
                      color: _green,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados! :(',
                      style: TextStyle(
                        color: _gray,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  _dolar = snapshot.data[resultsKey][currenciesKey][dollarKey]
                      [buyKey];
                  _euro =
                      snapshot.data[resultsKey][currenciesKey][euroKey][buyKey];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Icon(
                              _icon,
                              size: 150.0,
                              color: _green,
                            )),
                        buildTextField(
                            'Reais', 'R', _realController, _realChanged),
                        Divider(),
                        buildTextField(
                            'Dólares', 'US', _dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            'Euros', '€', _euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function changed) {
  return TextField(
    controller: controller,
    onChanged: changed,
    keyboardType: TextInputType.number,
    style: TextStyle(color: _gray, fontSize: 20.0),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _green),
        border: OutlineInputBorder(),
        prefixText: "$prefix\$ "),
  );
}
