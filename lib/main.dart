import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

void main() => runApp(const BartApp());

class BartApp extends StatelessWidget {
  const BartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falegnameria di Bart v4.8',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const HomePage(),
    );
  }
}

class Manufatto {
  String nome;
  double L, l, H, P, qta;
  Manufatto({this.nome='Tavolo', this.L=1000, this.l=600, this.H=800, this.P=400, this.qta=1});
  double get mq => (L/1000)*(H/1000)*qta;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nomeCtrl = TextEditingController(text: 'Miguelina');
  final telCtrl = TextEditingController();
  final luogoCtrl = TextEditingController(text: 'Cerreto');
  
  List<Manufatto> manufatti = [Manufatto()];
  double legnoMq = 30;
  double pannelliQta = 5;
  double scartoLegni = 15;
  double scartoPannelli = 10;
  double manoH = 15;
  double manoPrezzo = 35;
  double levig = 300;
  double finitura = 55;
  double extra = 0;
  double vern = 3300;
  double margin = 30;
  double iva = 22;
  double legnoPrezzo = 100;

  String fmtUI(double n) => '${n.toStringAsFixed(2)} EUR';
  String fmtPDF(double n) => 'EUR ${n.toStringAsFixed(2)}';

  Map<String,double> calcola() {
    double legniNetto = legnoMq * (legnoPrezzo + 5);
    double pannelliNetto = pannelliQta * (38+6);
    double scL = legniNetto * scartoLegni/100;
    double scP = pannelliNetto * scartoPannelli/100;
    double mano = manoH * manoPrezzo;
    double materiale = legniNetto+scL+pannelliNetto+scP+mano+levig+finitura+extra+vern;
    double utile = materiale * margin/100;
    double imponibile = materiale + utile;
    double ivaVal = imponibile * iva/100;
    double totale = imponibile + ivaVal;
    return {
      'legni': legniNetto, 'scL': scL, 'pannelli': pannelliNetto, 'scP': scP,
      'mano': mano, 'materiale': materiale, 'utile': utile,
      'imponibile': imponibile, 'iva': ivaVal, 'totale': totale
    };
  }

  Future<void> generaPDF() async {
    final t = calcola();
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PREVENTIVO - ${DateTime.now().toIso8601String().substring(0,10)} - ${nomeCtrl.text}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('DA: falegnameria di Bart - Tel 3791797758', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('A: ${nomeCtrl.text} ${luogoCtrl.text} Tel:${telCtrl.text}', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 10),
              for (var m in manufatti)
                pw.Text('${m.nome} L:${m.L} l:${m.l} H:${m.H} P:${m.P} mm [${m.mq.toStringAsFixed(3)} mq] x${m.qta}'),
              pw.Divider(),
              pw.Text('Legni netto ${fmtPDF(t['legni']!)}'),
              pw.Text('Scarto legni ${scartoLegni}% ${fmtPDF(t['scL']!)}'),
              pw.Text('Pannelli netto ${fmtPDF(t['pannelli']!)}'),
              pw.Text('Scarto pannelli ${scartoPannelli}% ${fmtPDF(t['scP']!)}'),
              pw.Text('Manodopera ${manoH}h ${fmtPDF(t['mano']!)}'),
              pw.Text('Levigatura ${fmtPDF(levig)}'),
              pw.Text('Finitura Cera ${fmtPDF(finitura)}'),
              if (extra>0) pw.Text('Extra laccatura/trasporto ${fmtPDF(extra)}'),
              pw.Text('Verniciatura x2 ${fmtPDF(vern)}'),
              pw.SizedBox(height: 6),
              pw.Text('Materiale + lavorazioni ${fmtPDF(t['materiale']!)}'),
              pw.Text('Utile / Margine ${margin}% ${fmtPDF(t['utile']!)}'),
              pw.SizedBox(height: 6),
              pw.Text('IMPONIBILE ${fmtPDF(t['imponibile']!)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('IVA ${iva}% ${fmtPDF(t['iva']!)}'),
              pw.SizedBox(height: 10),
              pw.Text('TOTALE IVATO: ${fmtPDF(t['totale']!)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/preventivo_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Preventivo Falegnameria di Bart - ${fmtPDF(t['totale']!)}');
  }

  @override
  Widget build(BuildContext context) {
    final t = calcola();
    return Scaffold(
      appBar: AppBar(title: const Text('Falegnameria di Bart v4.8 FIX INVIO')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Dati Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome cliente')),
          TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: luogoCtrl, decoration: const InputDecoration(labelText: 'Luogo')),
          const SizedBox(height: 12),
          const Text('Manufatti - TUTTO L/l/H/P mm + mq auto', style: TextStyle(fontWeight: FontWeight.bold)),
          for (int i=0;i<manufatti.length;i++)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
              TextField(decoration: const InputDecoration(labelText: 'Descrizione'), controller: TextEditingController(text: manufatti[i].nome), onChanged: (v){ manufatti[i].nome=v; }),
              Row(children: [
                Expanded(child: TextField(decoration: const InputDecoration(labelText: 'L mm'), keyboardType: TextInputType.number, controller: TextEditingController(text: manufatti[i].L.toString()), onChanged: (v){manufatti[i].L=double.tryParse(v)??0; setState((){});})),
                const SizedBox(width: 6),
                Expanded(child: TextField(decoration: const InputDecoration(labelText: 'l mm'), keyboardType: TextInputType.number, controller: TextEditingController(text: manufatti[i].l.toString()), onChanged: (v){manufatti[i].l=double.tryParse(v)??0; setState((){});})),
                const SizedBox(width: 6),
                Expanded(child: TextField(decoration: const InputDecoration(labelText: 'H mm'), keyboardType: TextInputType.number, controller: TextEditingController(text: manufatti[i].H.toString()), onChanged: (v){manufatti[i].H=double.tryParse(v)??0; setState((){});})),
                const SizedBox(width: 6),
                Expanded(child: TextField(decoration: const InputDecoration(labelText: 'P mm'), keyboardType: TextInputType.number, controller: TextEditingController(text: manufatti[i].P.toString()), onChanged: (v){manufatti[i].P=double.tryParse(v)??0; setState((){});})),
              ]),
              Row(children: [
                Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qta'), keyboardType: TextInputType.number, controller: TextEditingController(text: manufatti[i].qta.toString()), onChanged: (v){manufatti[i].qta=double.tryParse(v)??1; setState((){});})),
                const SizedBox(width: 12),
                Text('mq auto: ${manufatti[i].mq.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: (){setState(()=>manufatti.removeAt(i));}, child: const Text('Elimina', style: TextStyle(color: Colors.red)))),
            ]))),
          ElevatedButton(onPressed: ()=>setState(()=>manufatti.add(Manufatto())), child: const Text('+ Aggiungi Manufatto')),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Legni netto ${fmtUI(t['legni']!)}'),
            Text('Materiale + lavorazioni ${fmtUI(t['materiale']!)}'),
            Text('Utile ${margin}% ${fmtUI(t['utile']!)}'),
            const Divider(),
            Text('IMPONIBILE ${fmtUI(t['imponibile']!)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('TOTALE IVATO ${fmtUI(t['totale']!)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]))),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
            onPressed: generaPDF,
            child: const Text('GENERA PDF + CONDIVIDI - FIX EUR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
