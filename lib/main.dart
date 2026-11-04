import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Voce {
  final String nome;
  final double min;
  final double max;
  final double medio;
  const Voce(this.nome, this.min, this.max) : medio = (min + max) / 2;
}

const LISTINO = [
  Voce("Pannello Fotovoltaico 450W", 90, 120),
  Voce("Inverter Ibrido 6kW", 900, 1200),
  Voce("Batteria Accumulo 5kWh", 1800, 2200),
  Voce("Struttura Tetto / Zavorre", 15, 35),
  Voce("Quadro AC/DC + Cablaggi", 300, 500),
  Voce("Installazione e Pratica GSE", 800, 1200),
  Voce("Contatore Bidirezionale", 100, 200),
];

class Riga {
  Voce voce;
  int qty;
  double prezzo;
  Riga(this.voce, this.qty, this.prezzo);
  double get tot => qty * prezzo;
}

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home(), debugShowCheckedModeBanner: false);
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final cliente = TextEditingController();
  final List<Riga> righe = [];
  double get totale => righe.fold(0, (s, r) => s + r.tot);

  Future<void> genPDF() async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
        build: (c) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Bart v10.0 - Bundle Fotovoltaico",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("PANNELLI - SI PARTE DA 1 (NON DA 2)"),
              pw.SizedBox(height: 10),
              pw.Text("Cliente: ${cliente.text}"),
              pw.SizedBox(height: 20),
              ...righe.map((r) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${r.qty}x ${r.voce.nome}"),
                        pw.Text("${r.tot.toStringAsFixed(2)}€")
                      ])),
              pw.Divider(),
              pw.Text("TOT: ${totale.toStringAsFixed(2)} EUR",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Note: Impianto chiavi in mano"),
                    pw.Text("Garanzia 25 anni pannelli"),
                  ],
                ),
              ),
            ])));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Bart v10 - PANNELLI DA 1"),
          backgroundColor: Colors.green),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                controller: cliente,
                decoration: const InputDecoration(
                    labelText: "Nome Cliente",
                    border: OutlineInputBorder()))),
        Expanded(
            child: ListView.builder(
                itemCount: LISTINO.length,
                itemBuilder: (c, i) {
                  final v = LISTINO[i];
                  return ListTile(
                      title: Text(v.nome),
                      subtitle: Text("${v.min.toInt()}-${v.max.toInt()}€"),
                      trailing: const Icon(Icons.add),
                      onTap: () =>
                          setState(() => righe.add(Riga(v, 1, v.medio))));
                })),
        const Divider(),
        Expanded(
            child: ListView.builder(
                itemCount: righe.length,
                itemBuilder: (c, i) {
                  final r = righe[i];
                  return ListTile(
                      title: Text("${r.qty}x ${r.voce.nome}"),
                      subtitle: Text(
                          "${r.qty} pannello/i - TOT ~${r.tot.toStringAsFixed(0)} EUR"),
                      trailing: Text("${r.tot.toStringAsFixed(0)}€"));
                })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: righe.isEmpty ? null : genPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(
                      "${righe.isEmpty ? 0 : righe.first.qty} pannello/i - TOT ~${totale.toStringAsFixed(0)} EUR - GENERA PDF"))),
        )
      ]),
    );
  }
}
