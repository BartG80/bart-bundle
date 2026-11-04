import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const BartFalegnameApp());

class BartFalegnameApp extends StatelessWidget {
  const BartFalegnameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bart v8.7 Falegname',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown, useMaterial3: false),
      home: const PreventivoPage(),
    );
  }
}

class PreventivoPage extends StatefulWidget {
  const PreventivoPage({super.key});
  @override
  State<PreventivoPage> createState() => _PreventivoPageState();
}

class _PreventivoPageState extends State<PreventivoPage> {
  int progNum = 9;
  final falNome = TextEditingController();
  final falIndirizzo = TextEditingController();
  final falPiva = TextEditingController();
  final falTel = TextEditingController();
  final falEmail = TextEditingController();

  final cliNome = TextEditingController();
  final cliIndirizzo = TextEditingController();
  final cliLuogo = TextEditingController();
  final cliTel = TextEditingController();
  final cliCF = TextEditingController();

  final manufattoCtrl = TextEditingController();
  final lunghezzaCtrl = TextEditingController(text: '100');
  final larghezzaCtrl = TextEditingController(text: '50');
  final altezzaCtrl = TextEditingController(text: '80');
  final profonditaCtrl = TextEditingController();
  final manoOperaCtrl = TextEditingController(text: '150');
  final utileCtrl = TextEditingController(text: '20');

  String essenzaSelezionata = 'Pino';
  final List<String> essenze = ['Pino','Abete','Faggio','Frassino','Rovere','Castagno','Noce','Ciliegio','Canaletto','Wenge','Teak'];
  double prezzoEssenza = 80;
  double extraEssenza = 0;

  String pannelloSelezionato = 'Multistrato Okume';
  final List<String> pannelli = ['Multistrato Okume','Multistrato Betulla','Multistrato Pino Fenolico','Multistrato Pioppo','Multistrato Faggio','Multistrato Rovere','Lamellare Pino','Lamellare Faggio','Lamellare Rovere','Lamellare Abete','MDF','Truciolare','Marino','OSB','Listellare'];
  double prezzoPannello = 35;
  double extraPannello = 0;

  double calcolaMq() {
    double l = double.tryParse(lunghezzaCtrl.text) ?? 0;
    double ll = double.tryParse(larghezzaCtrl.text) ?? 0;
    return (l * ll) / 10000;
  }

  double calcolaTot() {
    double mq = calcolaMq();
    if (mq == 0) mq = 1;
    double mat = (prezzoEssenza + extraEssenza + prezzoPannello + extraPannello) * mq;
    double man = double.tryParse(manoOperaCtrl.text) ?? 0;
    double utilePerc = double.tryParse(utileCtrl.text) ?? 0;
    double sub = mat + man;
    return sub + (sub * utilePerc / 100);
  }

  void pulisciTutto() {
    setState(() {
      cliNome.clear(); cliIndirizzo.clear(); cliLuogo.clear(); cliTel.clear(); cliCF.clear();
      manufattoCtrl.clear(); lunghezzaCtrl.text='100'; larghezzaCtrl.text='50'; altezzaCtrl.text='80'; profonditaCtrl.clear();
      manoOperaCtrl.text='150'; utileCtrl.text='20';
      prezzoEssenza=80; extraEssenza=0; prezzoPannello=35; extraPannello=0;
      progNum++;
    });
  }

  Future<void> generaPDF() async {
    final pdf = pw.Document();
    final mq = calcolaMq();
    final tot = calcolaTot();
    final iva = tot * 0.22;
    final totIva = tot + iva;
    pdf.addPage(pw.MultiPage(
      build: (c) => [
        pw.Text('PREVENTIVO N. ${progNum.toString().padLeft(3,'0')} - v8.7', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('FALEGNAME: ${falNome.text} - ${falIndirizzo.text} - P.IVA ${falPiva.text}'),
          pw.Text('Tel ${falTel.text} - ${falEmail.text}'),
        ])),
        pw.SizedBox(height: 8),
        pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('CLIENTE: ${cliNome.text}'),
          pw.Text('${cliIndirizzo.text} - ${cliLuogo.text}'),
          pw.Text('Tel ${cliTel.text} - CF ${cliCF.text}'),
        ])),
        pw.SizedBox(height: 12),
        pw.Text('Manufatto: ${manufattoCtrl.text} - L ${lunghezzaCtrl.text} x l ${larghezzaCtrl.text} x H ${altezzaCtrl.text} - Mq ${mq.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Essenza: $essenzaSelezionata - ${prezzoEssenza.toStringAsFixed(0)}€ + extra ${extraEssenza.toStringAsFixed(0)}€'),
        pw.Text('Pannello: $pannelloSelezionato - ${prezzoPannello.toStringAsFixed(0)}€ + extra ${extraPannello.toStringAsFixed(0)}€'),
        pw.Text('Mano d\'opera: ${manoOperaCtrl.text}€'),
        pw.SizedBox(height: 12),
        pw.Text('TOTALE Materiali + Lavoro: ${tot.toStringAsFixed(2)} EUR + IVA 22% = ${totIva.toStringAsFixed(2)} EUR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Note legali:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('1. Validità 15 giorni (30 su richiesta)\n2. Prezzi soggetti a variazione mercato\n3. Venature/nodi naturali\n4. Tolleranza +/-2mm\n5. Tempi consegna indicativi\n6. Trasporto/montaggio esclusi\n7. Pagamento 40% acconto, 60% alla consegna\n8. Garanzia 24 mesi\n9. Modifiche in corso d\'opera\n10. Foro Mantova'),
      ],
    ));
    await Printing.layoutPdf(onLayout: (f) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bart v8.7 - N.${progNum.toString().padLeft(3,'0')}'),
        backgroundColor: Colors.brown,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: pulisciTutto)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('INTESTAZIONE FALEGNAME', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: falNome, decoration: const InputDecoration(labelText: 'Nome Falegname')),
          TextField(controller: falIndirizzo, decoration: const InputDecoration(labelText: 'Indirizzo')),
          TextField(controller: falPiva, decoration: const InputDecoration(labelText: 'P.IVA')),
          TextField(controller: falTel, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: falEmail, decoration: const InputDecoration(labelText: 'Email')),
          const Divider(),
          const Text('CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: cliNome, decoration: const InputDecoration(labelText: 'Nome Cliente')),
          TextField(controller: cliIndirizzo, decoration: const InputDecoration(labelText: 'Indirizzo Cliente')),
          TextField(controller: cliLuogo, decoration: const InputDecoration(labelText: 'Luogo')),
          TextField(controller: cliTel, decoration: const InputDecoration(labelText: 'Tel Cliente')),
          TextField(controller: cliCF, decoration: const InputDecoration(labelText: 'CF')),
          const Divider(),
          const Text('ESSENZE LEGNO - 1 SELEZIONE', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(value: essenzaSelezionata, isExpanded: true, items: essenze.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => essenzaSelezionata = v!)),
          Text('Prezzo essenza: ${prezzoEssenza.toInt()}€ (20-250)'), Slider(value: prezzoEssenza, min: 20, max: 250, onChanged: (v) => setState(() => prezzoEssenza = v)),
          Text('Extra essenza: ${extraEssenza.toInt()}€'), Slider(value: extraEssenza, min: 0, max: 100, onChanged: (v) => setState(() => extraEssenza = v)),
          const Divider(),
          const Text('PANNELLI MULTISTRATO / LISTELLARE - 1 PANNELLO', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(value: pannelloSelezionato, isExpanded: true, items: pannelli.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => pannelloSelezionato = v!)),
          Text('Prezzo pannello: ${prezzoPannello.toInt()}€ (10-100)'), Slider(value: prezzoPannello, min: 10, max: 100, onChanged: (v) => setState(() => prezzoPannello = v)),
          Text('Extra pannello: ${extraPannello.toInt()}€'), Slider(value: extraPannello, min: 0, max: 100, onChanged: (v) => setState(() => extraPannello = v)),
          const Divider(),
          const Text('MANUFATTO DA CREARE', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: manufattoCtrl, decoration: const InputDecoration(labelText: 'Descrizione manufatto')),
          Row(children: [Expanded(child: TextField(controller: lunghezzaCtrl, decoration: const InputDecoration(labelText: 'L cm'), keyboardType: TextInputType.number)), Expanded(child: TextField(controller: larghezzaCtrl, decoration: const InputDecoration(labelText: 'l cm'), keyboardType: TextInputType.number)), Expanded(child: TextField(controller: altezzaCtrl, decoration: const InputDecoration(labelText: 'H cm'), keyboardType: TextInputType.number))]),
          TextField(controller: profonditaCtrl, decoration: const InputDecoration(labelText: 'P cm opzionale')),
          Text('Mq calcolati: ${calcolaMq().toStringAsFixed(2)}'),
          const Divider(),
          TextField(controller: manoOperaCtrl, decoration: const InputDecoration(labelText: 'Mano d\'opera €'), keyboardType: TextInputType.number),
          TextField(controller: utileCtrl, decoration: const InputDecoration(labelText: 'Utile % (nascosto)'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Text('TOT STIMATO: ${calcolaTot().toStringAsFixed(2)} EUR', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: generaPDF, style: ElevatedButton.styleFrom(backgroundColor: Colors.brown), child: Text('GENERA PDF v8.7 N.${progNum.toString().padLeft(3,'0')}'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: pulisciTutto, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('PULISCI TUTTO'))),
        ]),
      ),
    );
  }
}
