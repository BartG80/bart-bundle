import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

void main() => runApp(MaterialApp(home: PreventivoFalegname(), debugShowCheckedModeBanner: false));

class Voce {
  String nome;
  double min;
  double max;
  double valore;
  bool selezionato;
  Voce(this.nome, this.min, this.max, this.valore, {this.selezionato = false});
}

class PreventivoFalegname extends StatefulWidget {
  @override
  State<PreventivoFalegname> createState() => _PreventivoFalegnameState();
}

class _PreventivoFalegnameState extends State<PreventivoFalegname> {
  final nomeFal = TextEditingController(); final pivaFal = TextEditingController(); final telFal = TextEditingController();
  final viaFal = TextEditingController(); final cittaFal = TextEditingController(); final provFal = TextEditingController(); final capFal = TextEditingController();
  final nomeCli = TextEditingController(); final telCli = TextEditingController(); final viaCli = TextEditingController();
  final cittaCli = TextEditingController(); final provCli = TextEditingController(); final capCli = TextEditingController();

  List<Voce> lavorazioni = [
    Voce('Manodopera', 10, 300, 50),
    Voce('Levigatura (ora)', 10, 100, 30),
    Voce('Finitura', 10, 300, 50),
    Voce('Verniciatura', 10, 300, 80),
    Voce('Pensili cucina al mq', 50, 10000, 500),
    Voce('Top cucina', 50, 10000, 800),
    Voce('Ante', 50, 10000, 600),
    Voce('Armadio', 100, 10000, 1200),
    Voce('Tavolo', 100, 10000, 900),
    Voce('Mensola', 50, 5000, 200),
    Voce('Montaggio', 50, 5000, 250),
    Voce('Trasporto', 50, 5000, 100),
  ];

  List<Voce> legni = [
    Voce('Abete al mq', 20, 500, 80),
    Voce('Rovere al mq', 50, 1000, 300),
    Voce('Noce al mq', 80, 1200, 450),
    Voce('Faggio al mq', 40, 800, 200),
    Voce('Frassino al mq', 50, 900, 250),
    Voce('Ciliegio al mq', 70, 1100, 400),
    Voce('Larice al mq', 60, 1000, 350),
    Voce('Multistrato', 30, 600, 120),
  ];

  double get totale {
    double t = 0;
    for (var v in lavorazioni) if(v.selezionato) t += v.valore;
    for (var v in legni) if(v.selezionato) t += v.valore;
    return t;
  }

  Widget buildVoce(Voce v) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: v.selezionato ? Colors.brown : Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: v.selezionato ? Colors.brown.shade50 : Colors.white),
      child: Column(children: [
        CheckboxListTile(
          value: v.selezionato,
          activeColor: Colors.brown,
          title: Text(v.nome, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: v.selezionato ? Text('${v.valore.toInt()} €', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)) : Text('${v.min.toInt()}€ - ${v.max.toInt()}€'),
          onChanged: (b) => setState(() => v.selezionato = b!),
        ),
        if(v.selezionato) Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Slider(min: v.min, max: v.max, value: v.valore, activeColor: Colors.brown, onChanged: (val) => setState(() => v.valore = val))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bart Falegname - Preventivo'), backgroundColor: Colors.brown),
      body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DATI FALEGNAME', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: nomeFal, decoration: InputDecoration(labelText: 'Nome')), TextField(controller: pivaFal, decoration: InputDecoration(labelText: 'P.IVA')), TextField(controller: telFal, decoration: InputDecoration(labelText: 'Telefono')),
        TextField(controller: viaFal, decoration: InputDecoration(labelText: 'Via')),
        Row(children: [Expanded(child: TextField(controller: cittaFal, decoration: InputDecoration(labelText: 'Città'))), SizedBox(width: 6, child: TextField(controller: provFal, decoration: InputDecoration(labelText: 'Prov'))), SizedBox(width: 8), SizedBox(width: 90, child: TextField(controller: capFal, decoration: InputDecoration(labelText: 'CAP')))]),
        SizedBox(height: 16),
        Text('DATI CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: nomeCli, decoration: InputDecoration(labelText: 'Nome Cliente')), TextField(controller: telCli, decoration: InputDecoration(labelText: 'Telefono')),
        TextField(controller: viaCli, decoration: InputDecoration(labelText: 'Via Cliente')),
        Row(children: [Expanded(child: TextField(controller: cittaCli, decoration: InputDecoration(labelText: 'Città'))), SizedBox(width: 6, child: TextField(controller: provCli, decoration: InputDecoration(labelText: 'Prov'))), SizedBox(width: 8), SizedBox(width: 90, child: TextField(controller: capCli, decoration: InputDecoration(labelText: 'CAP')))]),
        SizedBox(height: 20),
        Container(color: Colors.brown.shade100, padding: EdgeInsets.all(8), width: double.infinity, child: Text('LAVORAZIONI - Seleziona e scorri prezzo', style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height: 8),
        ...lavorazioni.map((v) => buildVoce(v)),
        SizedBox(height: 12),
        Container(color: Colors.orange.shade100, padding: EdgeInsets.all(8), width: double.infinity, child: Text('ESSENZE LEGNO', style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height: 8),
        ...legni.map((v) => buildVoce(v)),
        SizedBox(height: 20),
        Container(padding: EdgeInsets.all(16), color: Colors.brown, width: double.infinity, child: Text('TOTALE: ${totale.toInt()} €', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        SizedBox(height: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 55), backgroundColor: Colors.brown), onPressed: () async {
          final pdf = pw.Document();
          pdf.addPage(pw.Page(build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Preventivo ${nomeFal.text}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('${viaFal.text}, ${cittaFal.text} (${provFal.text}) P.IVA ${pivaFal.text}'),
            pw.SizedBox(height: 10), pw.Text('Cliente: ${nomeCli.text} - ${viaCli.text}, ${cittaCli.text}'), pw.Divider(),
            ...lavorazioni.where((e) => e.selezionato).map((e) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(e.nome), pw.Text('${e.valore.toInt()} €')])),
            ...legni.where((e) => e.selezionato).map((e) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(e.nome), pw.Text('${e.valore.toInt()} €')])),
            pw.Divider(), pw.Text('TOTALE: ${totale.toInt()} €', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ])));
          await Printing.layoutPdf(onLayout: (_) => pdf.save());
        }, child: Text('GENERA PDF', style: TextStyle(color: Colors.white, fontSize: 18))),
        SizedBox(height: 40),
      ])),
    );
  }
}
