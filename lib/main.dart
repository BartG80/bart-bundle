import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Voce {
  final String nome;
  final double min;
  final double max;
  final double medio;
  final String unita;
  const Voce(this.nome, this.min, this.max, this.medio, {this.unita = "mq"});
}

const LISTINO = [
  Voce("Cucina lineare base (truciolare/laminato)", 400, 800, 600, unita: "ml"),
  Voce("Cucina lineare laccata / legno", 800, 1500, 1150, unita: "ml"),
  Voce("Cucina ad angolo con penisola", 1200, 2200, 1500, unita: "ml"),
  Voce("Cucina con isola centrale", 1800, 3500, 2500, unita: "ml"),
  Voce("Cucina artigianale esclusiva massello", 2500, 4500, 3200, unita: "ml"),
  Voce("Armadio / Guardaroba a muro base", 400, 1000, 700, unita: "mq"),
  Voce("Cabina armadio completa", 800, 2000, 1200, unita: "mq"),
  Voce("Mobile ingresso / scarpiera", 600, 1800, 950, unita: "cad"),
  Voce("Libreria / Scaffalatura massello", 400, 1500, 750, unita: "ml"),
  Voce("Mobile bagno con lavabo", 300, 1800, 650, unita: "cad"),
  Voce("Tavolo in legno massello", 350, 1500, 800, unita: "cad"),
  Voce("Porta interna massello su misura", 400, 1500, 750, unita: "cad"),
  Voce("Parquet posa massello", 50, 120, 75, unita: "mq"),
  Voce("Manodopera finitura a olio naturale", 15, 35, 25, unita: "mq"),
  Voce("Manodopera finitura olio + cera", 20, 40, 30, unita: "mq"),
  Voce("Manodopera levigatura grezza/fine", 10, 25, 18, unita: "mq"),
  Voce("Manodopera verniciatura trasparente", 25, 50, 35, unita: "mq"),
  Voce("Manodopera verniciatura laccata opaca/lucida", 35, 70, 50, unita: "mq"),
  Voce("Manodopera verniciatura a spruzzo 2 mani", 30, 60, 45, unita: "mq"),
  Voce("Posa / Montaggio in opera", 35, 60, 45, unita: "ora"),
  Voce("Legno Rovere Slavonia (materiale)", 80, 180, 120, unita: "mq"),
  Voce("Legno Noce Nazionale/Americano", 120, 250, 160, unita: "mq"),
  Voce("Legno Frassino / Faggio", 60, 140, 95, unita: "mq"),
  Voce("Pannello Multistrato / Listellare", 40, 110, 65, unita: "mq"),
  Voce("Pannello MDF / Truciolare nobilitato", 25, 70, 45, unita: "mq"),
  Voce("Top cucina laminato / legno / pietra", 150, 800, 350, unita: "ml"),
  Voce("Ferramenta guide cerniere maniglie", 15, 120, 45, unita: "cad"),
  Voce("Zoccolini cornici accessori", 10, 50, 25, unita: "ml"),
];

void main() {
  runApp(const BartApp());
}

class BartApp extends StatelessWidget {
  const BartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bart Falegname Pro',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const PreventivoPage(),
    );
  }
}

class PreventivoPage extends StatelessWidget {
  const PreventivoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bart Falegname - Listino'), backgroundColor: Colors.brown),
      body: ListView.builder(
        itemCount: LISTINO.length,
        itemBuilder: (context, i) {
          final v = LISTINO[i];
          return ListTile(
            title: Text(v.nome),
            subtitle: Text('${v.min.toInt()} - ${v.max.toInt()} € / ${v.unita}'),
            trailing: Text('${v.medio.toInt()} €', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.picture_as_pdf),
        onPressed: () async {
          final pdf = pw.Document();
          pdf.addPage(pw.Page(build: (c) => pw.Column(children: [pw.Text('Listino Bart Falegname'), pw.SizedBox(height: 20), ...LISTINO.map((v) => pw.Text('${v.nome} - ${v.medio} €/${v.unita}'))])));
          await Printing.layoutPdf(onLayout: (f) async => pdf.save());
        },
      ),
    );
  }
}
