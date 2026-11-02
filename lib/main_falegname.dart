import 'package:flutter/material.dart';

void main() => runApp(const BartFalegname());

class BartFalegname extends StatelessWidget {
  const BartFalegname({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(debugShowCheckedModeBanner: false, home: PreventivoPage());
}

class Voce {
  String nome; String unita; double min; double max; double prezzo; int qta;
  Voce(this.nome, this.unita, this.min, this.max, this.prezzo, {this.qta = 1});
}

class PreventivoPage extends StatefulWidget {
  const PreventivoPage({super.key});
  @override
  State<PreventivoPage> createState() => _PreventivoPageState();
}

class _PreventivoPageState extends State<PreventivoPage> {
  // FALEGNAME
  final nomeFal = TextEditingController();
  final pivaFal = TextEditingController();
  final telFal = TextEditingController();
  final viaFal = TextEditingController();
  final cittaFal = TextEditingController();
  final provFal = TextEditingController();
  final capFal = TextEditingController();

  // CLIENTE
  final nomeCli = TextEditingController();
  final telCli = TextEditingController();
  final viaCli = TextEditingController();
  final cittaCli = TextEditingController();
  final provCli = TextEditingController();
  final capCli = TextEditingController();

  final List<Voce> voci = [
    Voce("Cucina lineare base", "ml", 400, 800, 600),
    Voce("Cucina lineare laccata / legno", "ml", 800, 1500, 1150),
    Voce("Cucina ad angolo / penisola", "ml", 1200, 2200, 1500),
    Voce("Cucina con isola", "ml", 1800, 3500, 2500),
    Voce("Armadio a muro", "mq", 400, 1000, 650),
    Voce("Porta interna", "cad", 350, 900, 550),
  ];

  Widget campo(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(controller: c, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bart Falegname - Preventivo"), backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text("DATI FALEGNAME", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
          campo(nomeFal, "Nome Falegnameria"),
          campo(pivaFal, "Partita IVA"),
          campo(telFal, "Telefono"),
          campo(viaFal, "Via / Indirizzo"),
          Row(children: [Expanded(child: campo(cittaFal, "Città")), const SizedBox(width: 8), SizedBox(width: 70, child: campo(provFal, "Prov.")), const SizedBox(width: 8), SizedBox(width: 80, child: campo(capFal, "CAP"))]),
          const SizedBox(height: 16),
          const Text("DATI CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
          campo(nomeCli, "Nome Cliente"),
          campo(telCli, "Telefono Cliente"),
          campo(viaCli, "Via / Indirizzo Cliente"),
          Row(children: [Expanded(child: campo(cittaCli, "Città")), const SizedBox(width: 8), SizedBox(width: 70, child: campo(provCli, "Prov.")), const SizedBox(width: 8), SizedBox(width: 80, child: campo(capCli, "CAP"))]),
          const Divider(height: 30),
          const Text("LISTINO", style: TextStyle(fontWeight: FontWeight.bold)),
          ...voci.map((v) => Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(v.nome, style: const TextStyle(fontWeight: FontWeight.bold))), Text("${v.prezzo.toInt()} €")]),
                  Slider(min: v.min, max: v.max, value: v.prezzo, activeColor: const Color(0xFF5D4037), onChanged: (val) => setState(() => v.prezzo = val)),
                  Row(children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => v.qta = v.qta > 1 ? v.qta - 1 : 1)),
                    Text("${v.qta} ${v.unita}"),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => v.qta++)),
                    const Spacer(),
                    Text("Tot: ${(v.prezzo * v.qta).toInt()} €", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
