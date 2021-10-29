import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request =
    Uri.parse("https://api.hgbrasil.com/finance?format=json&key=f700883f");

void main() async {
  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 1;
  double euro = 1;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _realChanged(String text) {
    double real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          title: const Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Erro ao carregar Dados",
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                        textAlign: TextAlign.center),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Icon(Icons.monetization_on,
                                  size: 150.0, color: Colors.amber),
                              buildTextField(
                                  "Reais", "R\$", realController, _realChanged),
                              const Divider(),
                              buildTextField("Dolares", "US\$", dolarController,
                                  _dolarChanged),
                              const Divider(),
                              buildTextField(
                                  "Euros", "€", euroController, _euroChanged)
                            ],
                          )));
                }
            }
          },
        ));
  }

  buildTextField(String label, String prefix, TextEditingController controller,
      Function(String) changed) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.amber),
            border: const OutlineInputBorder(),
            prefixText: prefix),
        style: const TextStyle(color: Colors.amber, fontSize: 25),
        onChanged: (value) {
          if (_formKey.currentState!.validate()) {
            changed(value);
          }
        },
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "insira um valor válido!";
          }
        });
  }
}
