import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(home: PreventivoFalegname(), debugShowCheckedModeBanner: false));

class PreventivoFalegname extends StatefulWidget {
  @override
  State<PreventivoFalegname> createState() => _PreventivoFalegnameState();
}

class _PreventivoFalegnameState extends State<PreventivoFalegname> {
  // Dati Falegname
  final nomeFal = TextEditingController();
  final pivaFal = TextEditingController();
  final telFal = TextEditingController();
  final viaFal = TextEditingController();
  final cittaFal = TextEditingController();
  final provFal = TextEditingController();
  final capFal = TextEditingController();

  // Dati Cliente
  final nomeCli = TextEditingController();
  final telCli = TextEditingController();
  final viaCli = TextEditingController();
  final cittaCli = TextEditingController();
  final provCli = TextEditingController();
  final capCli = TextEditingController();

  double prezzo = 550;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bart Falegname - Preventivo'), backgroundColor: Colors.brown),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DATI FALEGNAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(controller: nomeFal, decoration: InputDecoration(labelText: 'Nome Falegname')),
            TextField(controller: pivaFal, decoration: InputDecoration(labelText: 'P.IVA')),
            TextField(controller: telFal, decoration: InputDecoration(labelText: 'Telefono')),
            TextField(controller: viaFal, decoration: InputDecoration(labelText: 'Via')),
            Row(children: [
              Expanded(child: TextField(controller: cittaFal, decoration: InputDecoration(labelText: 'Città'))),
              SizedBox(width: 8),
              SizedBox(width: 70, child: TextField(controller: provFal, decoration: InputDecoration(labelText: 'Prov'))),
              SizedBox(width: 8),
              SizedBox(width: 90, child: TextField(controller: capFal, decoration: InputDecoration(labelText: 'CAP'))),
            ]),
            SizedBox(height: 20),
            Text('DATI CLIENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(controller: nomeCli, decoration: InputDecoration(labelText: 'Nome Cliente')),
            TextField(controller: telCli, decoration: InputDecoration(labelText: 'Telefono Cliente')),
            TextField(controller: viaCli, decoration: InputDecoration(labelText: 'Via Cliente')),
            Row(children: [
              Expanded(child: TextField(controller: cittaCli, decoration: InputDecoration(labelText: 'Città Cliente'))),
              SizedBox(width: 8),
              SizedBox(width: 70, child: TextField(controller: provCli, decoration: InputDecoration(labelText: 'Prov Cliente'))),
              SizedBox(width: 8),
              SizedBox(width: 90, child: TextField(controller: capCli, decoration: InputDecoration(labelText: 'CAP Cliente'))),
            ]),
            SizedBox(height: 20),
            Text('PREZZO: ${prezzo.toInt()} €', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Slider(min: 400, max: 800, value: prezzo, onChanged: (v) => setState(() => prezzo = v)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.brown),
              onPressed: () async {
                final pdf = pw.Document();
                pdf.addPage(pw.Page(build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Preventivo Falegname - ${nomeFal.text}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Falegname: ${nomeFal.text} - P.IVA ${pivaFal.text}'),
                  pw.Text('Tel: ${telFal.text} - ${viaFal.text}, ${cittaFal.text} (${provFal.text}) ${capFal.text}'),
                  pw.Divider(),
                  pw.Text('Cliente: ${nomeCli.text} - Tel ${telCli.text}'),
                  pw.Text('${viaCli.text}, ${cittaCli.text} (${provCli.text}) ${capCli.text}'),
                  pw.SizedBox(height: 20),
                  pw.Text('Totale: ${prezzo.toInt()} €', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ])));
                await Printing.layoutPdf(onLayout: (_) => pdf.save());
              },
              child: Text('GENERA PDF', style: TextStyle(fontSize: 18, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
