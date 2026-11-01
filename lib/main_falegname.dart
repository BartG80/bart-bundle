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
  Voce("Cucina su misura al metro lineare", 800, 1500),
  Voce("Armadio a muro al mq - ante scorrevoli", 400, 700),
  Voce("Porta interna + posa + ferramenta", 350, 600),
  Voce("Parquet posa al mq (incollato/flottante)", 50, 120),
  Voce("Libreria / Mensola su misura", 150, 400),
  Voce("Mobile bagno su misura", 600, 1200),
  Voce("Taglio e piallatura legno al mq", 40, 80),
  Voce("Restauro mobile / sedia", 100, 350),
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
        build: (c) => pw.Column(children: [
              pw.Text("Bart - Falegname Pro",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("Cliente: ${cliente.text}"),
              pw.SizedBox(height: 20),
              ...righe.map((r) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${r.qty}x ${r.voce.nome}"),
                        pw.Text("${r.tot.toStringAsFixed(2)}€")
                      ])),
              pw.Divider(),
              pw.Text("TOTALE: ${totale.toStringAsFixed(2)}€",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold))
            ])));
    await Printing.layoutPdf(onLayout: (f) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Bart - Falegname Pro"),
          backgroundColor: Colors.green),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                controller: cliente,
                decoration: const InputDecoration(
                    labelText: "Nome Cliente", border: OutlineInputBorder()))),
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
                      trailing: Text("${r.tot.toStringAsFixed(0)}€"));
                })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: righe.isEmpty ? null : genPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("GENERA PDF PREVENTIVO"))),
        )
      ]),
    );
  }
}
