import 'package:flutter/material.dart';

void main() => runApp(const BartFalegname());

class BartFalegname extends StatelessWidget {
  const BartFalegname({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF5D4037)),
      home: const ListinoPage(),
    );
  }
}

class Voce {
  String nome; String unita; double min; double max; double prezzo;
  Voce(this.nome, this.unita, this.min, this.max, this.prezzo);
}

class ListinoPage extends StatefulWidget {
  const ListinoPage({super.key});
  @override
  State<ListinoPage> createState() => _ListinoPageState();
}

class _ListinoPageState extends State<ListinoPage> {
  final List<Voce> voci = [
    Voce("Cucina lineare base (truciolare/laminato)", "ml", 400, 800, 600),
    Voce("Cucina lineare laccata / legno", "ml", 800, 1500, 1150),
    Voce("Cucina ad angolo / penisola", "ml", 1200, 2200, 1500),
    Voce("Cucina con isola centrale", "ml", 1800, 3500, 2500),
    Voce("Cucina artigianale esclusiva massello", "ml", 2500, 4500, 3200),
    Voce("Armadio / Guardaroba a muro base", "mq", 400, 1000, 650),
    Voce("Cabina armadio completa", "mq", 800, 2000, 1200),
    Voce("Mobile ingresso / scarpiera", "cad", 600, 1800, 950),
    Voce("Libreria / Scaffalatura massello", "ml", 400, 1500, 800),
    Voce("Porta interna standard", "cad", 350, 900, 550),
    Voce("Porta blindata / scorrevole", "cad", 800, 2000, 1200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bart Falegname - Listino"),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: voci.length,
        itemBuilder: (context, i) {
          final v = voci[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(v.nome, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Text("${v.prezzo.toInt()} €", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF5D4037))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("${v.min.toInt()} - ${v.max.toInt()} € / ${v.unita}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Slider(
                    min: v.min,
                    max: v.max,
                    divisions: 20,
                    label: "${v.prezzo.toInt()}€",
                    value: v.prezzo,
                    activeColor: const Color(0xFF5D4037),
                    onChanged: (val) => setState(() => v.prezzo = val),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
