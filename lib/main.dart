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
      title: 'Bart v5.8 SAFE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const HomePage(),
    );
  }
}

class Manufatto {
  String nome;
  double? L, l, H, P;
  double qta;
  Manufatto({this.nome = '', this.L, this.l, this.H, this.P, this.qta = 1});
  double get mq => (L == null || H == null) ? 0 : (L! / 1000) * (H! / 1000) * qta;
}

class LegnoItem {
  String essenza;
  double prezzoMq, extra, mq, spessore;
  LegnoItem({required this.essenza, required this.prezzoMq, required this.extra, required this.mq, required this.spessore});
  double get tot => (prezzoMq + extra) * mq;
}

class PannelloItem {
  String nome;
  double prezzo, extra, qta, spessore;
  PannelloItem({required this.nome, required this.prezzo, required this.extra, required this.qta, required this.spessore});
  double get tot => (prezzo + extra) * qta;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int preventivoNumero = 1;

  final falNomeCtrl = TextEditingController(text: 'Falegnameria di Bart');
  final falIndirizzoCtrl = TextEditingController();
  final falPivaCtrl = TextEditingController();
  final falTelCtrl = TextEditingController(text: '3791797758');
  final falEmailCtrl = TextEditingController();

  final cliNomeCtrl = TextEditingController();
  final cliTelCtrl = TextEditingController();
  final cliLuogoCtrl = TextEditingController();
  final cliIndirizzoCtrl = TextEditingController();
  final cliCfCtrl = TextEditingController();
  final cliEmailCtrl = TextEditingController();

  List<Manufatto> manufatti = [];
  List<LegnoItem> legni = [];
  List<PannelloItem> pannelli = [];

  final List<Map<String, dynamic>> essenzeCatalogo = [
    {'nome': 'Noce Nazionale', 'prezzo': 100.0, 'extra': 5.0},
    {'nome': 'Noce Canaletto', 'prezzo': 130.0, 'extra': 6.0},
    {'nome': 'Rovere Naturale', 'prezzo': 90.0, 'extra': 5.0},
    {'nome': 'Rovere Rustico', 'prezzo': 85.0, 'extra': 5.0},
    {'nome': 'Frassino', 'prezzo': 80.0, 'extra': 5.0},
    {'nome': 'Ciliegio', 'prezzo': 110.0, 'extra': 5.0},
    {'nome': 'Castagno', 'prezzo': 95.0, 'extra': 5.0},
    {'nome': 'Faggio', 'prezzo': 75.0, 'extra': 4.0},
    {'nome': 'Abete', 'prezzo': 60.0, 'extra': 3.0},
    {'nome': 'Wenge', 'prezzo': 150.0, 'extra': 8.0},
    {'nome': 'Teak', 'prezzo': 180.0, 'extra': 8.0},
  ];

  final List<Map<String, dynamic>> pannelliCatalogo = [
    {'nome': 'Lamellare Abete', 'prezzo': 38.0, 'extra': 6.0},
    {'nome': 'Multistrato Pioppo', 'prezzo': 35.0, 'extra': 5.0},
    {'nome': 'MDF Grezzo', 'prezzo': 28.0, 'extra': 4.0},
    {'nome': 'Truciolare Nobilitato', 'prezzo': 32.0, 'extra': 3.0},
    {'nome': 'Compensato Marino', 'prezzo': 60.0, 'extra': 6.0},
    {'nome': 'OSB', 'prezzo': 22.0, 'extra': 3.0},
  ];

  final List<double> spessoriLegno = [10, 15, 20, 25, 30, 40, 50];
  final List<double> spessoriPannello = [6, 8, 10, 12, 15, 18, 20, 25, 30];

  String? essenzaSelezionata;
  double? essenzaMq;
  double essenzaSpessore = 20.0;

  String? pannelloSelezionato;
  double? pannelloQta;
  double pannelloSpessore = 18.0;

  double? manoH, manoPrezzo, levig, finitura, extra, vern;
  double margin = 30, iva = 22;

  String fmtUI(double n) => '${n.toStringAsFixed(2)} EUR';
  String fmtPDF(double n) => 'EUR ${n.toStringAsFixed(2)}';

  Map<String, double> calcola() {
    double legniNetto = legni.fold(0, (s, l) => s + l.tot);
    double pannelliNetto = pannelli.fold(0, (s, p) => s + p.tot);
    double mh = manoH ?? 0, mp = manoPrezzo ?? 0, lv = levig ?? 0, fn = finitura ?? 0, ex = extra ?? 0, vn = vern ?? 0;
    double mano = mh * mp;
    double materiale = legniNetto + pannelliNetto + mano + lv + fn + ex + vn;
    double utile = materiale * margin / 100;
    double imponibile = materiale + utile;
    double ivaVal = imponibile * iva / 100;
    return {'materiale': materiale, 'utile': utile, 'iva': ivaVal, 'totale': imponibile + ivaVal};
  }

  void resetTutto() {
    setState(() {
      manufatti.clear();
      legni.clear();
      pannelli.clear();
      manoH = null; manoPrezzo = null; levig = null; finitura = null; vern = null; extra = null;
      essenzaSelezionata = null; essenzaMq = null;
      pannelloSelezionato = null; pannelloQta = null;
      margin = 30; iva = 22;
      cliNomeCtrl.clear(); cliTelCtrl.clear(); cliLuogoCtrl.clear(); cliIndirizzoCtrl.clear(); cliCfCtrl.clear(); cliEmailCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preventivo azzerato!')));
  }

  Future<void> generaPDF() async {
    final t = calcola();
    if (t['totale']! == 0 && manufatti.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserisci qualcosa')));
      return;
    }
    int num = preventivoNumero;
    preventivoNumero++;
    setState(() {});
    String numF = num.toString().padLeft(3, '0');
    String anno = DateTime.now().year.toString();
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(18),
      build: (ctx) {
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            decoration: pw.BoxDecoration(color: PdfColors.green900),
            child: pw.Padding(
              padding: pw.EdgeInsets.all(12),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('FALEGNAMERIA DI BART', style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Preventivo N. $anno-$numF', style: pw.TextStyle(color: PdfColors.green100, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Text(DateTime.now().toIso8601String().substring(0, 10), style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
              ]),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(children: [
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.green900, width: 1.2), color: PdfColors.green50),
                child: pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('FALEGNAME', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.green900)),
                    pw.SizedBox(height: 3),
                    pw.Text(falNomeCtrl.text.isEmpty ? '[Nome]' : falNomeCtrl.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(falIndirizzoCtrl.text, style: pw.TextStyle(fontSize: 8)),
                    pw.Text('P.IVA ${falPivaCtrl.text} Tel ${falTelCtrl.text}', style: pw.TextStyle(fontSize: 8)),
                  ]),
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1.2), color: PdfColors.blue50),
                child: pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('CLIENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900)),
                    pw.SizedBox(height: 3),
                    pw.Text(cliNomeCtrl.text.isEmpty ? '[Cliente]' : cliNomeCtrl.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('${cliLuogoCtrl.text} ${cliIndirizzoCtrl.text}', style: pw.TextStyle(fontSize: 8)),
                    pw.Text('Tel ${cliTelCtrl.text} CF ${cliCfCtrl.text}', style: pw.TextStyle(fontSize: 8)),
                  ]),
                ),
              ),
            ),
          ]),
          pw.SizedBox(height: 12),
          if (manufatti.isNotEmpty)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('MANUFATTI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Table(border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5), children: [
                pw.TableRow(decoration: pw.BoxDecoration(color: PdfColors.green800), children: [for (var h in ['Desc', 'L', 'l', 'H', 'P', 'mq', 'Qta']) pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(h, style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)))]),
                for (var m in manufatti)
                  pw.TableRow(children: [
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.nome, style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.L?.toStringAsFixed(0) ?? '-', style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.l?.toStringAsFixed(0) ?? '-', style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.H?.toStringAsFixed(0) ?? '-', style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.P?.toStringAsFixed(0) ?? '-', style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.mq.toStringAsFixed(3), style: pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text('${m.qta}', style: pw.TextStyle(fontSize: 8))),
                  ]),
              ]),
              pw.SizedBox(height: 10),
            ]),
          pw.Container(
            decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(color: PdfColors.grey400)),
            child: pw.Padding(
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Materiale + lavorazioni', style: pw.TextStyle(fontSize: 10)), pw.Text(fmtPDF(t['materiale']!), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))]),
                pw.SizedBox(height: 4),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('IVA ${iva.toInt()}%', style: pw.TextStyle(fontSize: 9)), pw.Text(fmtPDF(t['iva']!), style: pw.TextStyle(fontSize: 9))]),
                pw.SizedBox(height: 6),
                pw.Container(
                  decoration: pw.BoxDecoration(color: PdfColors.green100),
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Text('TOTALE IVATO N. $anno-$numF:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text(fmtPDF(t['totale']!), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.green900)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          pw.Text('NOTA: Prezzi variabili mercato, validita 15/30 giorni. N. $anno-$numF', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        ]);
      },
    ));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Preventivo_${anno}_${numF}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Preventivo N. $anno-$numF - ${fmtPDF(t['totale']!)}');
  }

  @override
  Widget build(BuildContext context) {
    final t = calcola();
    final hasData = t['totale']! > 0 || manufatti.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('Bart v5.8 - N. ${DateTime.now().year}-${preventivoNumero.toString().padLeft(3, '0')}'), actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.red), tooltip: 'Pulisci tutto', onPressed: resetTutto)]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('FALEGNAME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), TextField(controller: falNomeCtrl, decoration: const InputDecoration(labelText: 'Nome')), TextField(controller: falIndirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo')), TextField(controller: falPivaCtrl, decoration: const InputDecoration(labelText: 'P.IVA')), TextField(controller: falTelCtrl, decoration: const InputDecoration(labelText: 'Tel'))])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CLIENTE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)), TextField(controller: cliNomeCtrl, decoration: const InputDecoration(labelText: 'Nome Cliente')), TextField(controller: cliTelCtrl, decoration: const InputDecoration(labelText: 'Tel')), TextField(controller: cliLuogoCtrl, decoration: const InputDecoration(labelText: 'Luogo')), TextField(controller: cliIndirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo')), TextField(controller: cliCfCtrl, decoration: const InputDecoration(labelText: 'CF'))])),
        const SizedBox(height: 12),
        const Text('MANUFATTI L/l/H/P', style: TextStyle(fontWeight: FontWeight.bold)),
        for (int i = 0; i < manufatti.length; i++)
          Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [TextField(decoration: const InputDecoration(labelText: 'Descrizione'), onChanged: (v) { manufatti[i].nome = v; setState(() {}); }), Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'L', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manufatti[i].L = double.tryParse(v.replaceAll(',', '.')); setState(() {}); })), const SizedBox(width: 4), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'l', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manufatti[i].l = double.tryParse(v.replaceAll(',', '.')); setState(() {}); })), const SizedBox(width: 4), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'H', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manufatti[i].H = double.tryParse(v.replaceAll(',', '.')); setState(() {}); })), const SizedBox(width: 4), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'P', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manufatti[i].P = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }))]), const SizedBox(height: 6), Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qta', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manufatti[i].qta = double.tryParse(v.replaceAll(',', '.')) ?? 1; setState(() {}); })), const SizedBox(width: 12), Text('mq ${manufatti[i].mq.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold))]), Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () { setState(() => manufatti.removeAt(i)); }, child: const Text('Elimina', style: TextStyle(color: Colors.red))))]))),
        ElevatedButton(onPressed: () => setState(() => manufatti.add(Manufatto())), child: const Text('+ Aggiungi Manufatto')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('LEGNI', style: TextStyle(fontWeight: FontWeight.bold)), DropdownButtonFormField<String>(value: essenzaSelezionata, hint: const Text('Essenza'), items: essenzeCatalogo.map((e) => DropdownMenuItem<String>(value: e['nome'] as String, child: Text(e['nome'] as String))).toList(), onChanged: (v) => setState(() => essenzaSelezionata = v), decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 6), Row(children: [Expanded(child: DropdownButtonFormField<double>(value: essenzaSpessore, items: spessoriLegno.map((s) => DropdownMenuItem<double>(value: s, child: Text('${s.toInt()} mm'))).toList(), onChanged: (v) => setState(() => essenzaSpessore = v ?? 20.0), decoration: const InputDecoration(labelText: 'Spess.', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 6), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Mq', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { essenzaMq = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }))]), const SizedBox(height: 6), ElevatedButton(onPressed: () { if (essenzaSelezionata == null || essenzaMq == null) return; final cat = essenzeCatalogo.firstWhere((e) => e['nome'] == essenzaSelezionata); setState(() { legni.add(LegnoItem(essenza: essenzaSelezionata!, prezzoMq: (cat['prezzo'] as double), extra: (cat['extra'] as double), mq: essenzaMq!, spessore: essenzaSpessore)); essenzaSelezionata = null; essenzaMq = null; }); }, child: const Text('+ Legno')), for (int i = 0; i < legni.length; i++) Card(child: ListTile(dense: true, title: Text('${legni[i].essenza} ${legni[i].spessore}mm ${legni[i].mq}mq'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => legni.removeAt(i)); }))) ])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.brown.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PANNELLI', style: TextStyle(fontWeight: FontWeight.bold)), DropdownButtonFormField<String>(value: pannelloSelezionato, hint: const Text('Pannello'), items: pannelliCatalogo.map((e) => DropdownMenuItem<String>(value: e['nome'] as String, child: Text(e['nome'] as String))).toList(), onChanged: (v) => setState(() => pannelloSelezionato = v), decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 6), Row(children: [Expanded(child: DropdownButtonFormField<double>(value: pannelloSpessore, items: spessoriPannello.map((s) => DropdownMenuItem<double>(value: s, child: Text('${s.toInt()} mm'))).toList(), onChanged: (v) => setState(() => pannelloSpessore = v ?? 18.0), decoration: const InputDecoration(labelText: 'Spess.', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 6), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qta', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { pannelloQta = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }))]), const SizedBox(height: 6), ElevatedButton(onPressed: () { if (pannelloSelezionato == null || pannelloQta == null) return; final cat = pannelliCatalogo.firstWhere((e) => e['nome'] == pannelloSelezionato); setState(() { pannelli.add(PannelloItem(nome: pannelloSelezionato!, prezzo: (cat['prezzo'] as double), extra: (cat['extra'] as double), qta: pannelloQta!, spessore: pannelloSpessore)); pannelloSelezionato = null; pannelloQta = null; }); }, child: const Text('+ Pannello')), for (int i = 0; i < pannelli.length; i++) Card(child: ListTile(dense: true, title: Text('${pannelli[i].nome} ${pannelli[i].spessore}mm x${pannelli[i].qta}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => pannelli.removeAt(i)); }))) ])),
        const SizedBox(height: 12),
        const Text('Lavorazioni', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'h', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manoH = double.tryParse(v.replaceAll(',', '.')); setState(() {}); })), const SizedBox(width: 6), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'EUR/h', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { manoPrezzo = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }))]),
        TextField(decoration: const InputDecoration(labelText: 'Levigatura', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { levig = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }),
        TextField(decoration: const InputDecoration(labelText: 'Finitura', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { finitura = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }),
        TextField(decoration: const InputDecoration(labelText: 'Verniciatura', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { vern = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }),
        TextField(decoration: const InputDecoration(labelText: 'Extra', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { extra = double.tryParse(v.replaceAll(',', '.')); setState(() {}); }),
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('UTILE - SOLO TU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 11)), TextField(decoration: InputDecoration(labelText: 'Utile % (${30})', border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v) { margin = double.tryParse(v.replaceAll(',', '.')) ?? 30; setState(() {}); }), Text('Utile: ${fmtUI(t['utile']!)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 12),
        if (hasData) Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text('TOTALE N. ${DateTime.now().year}-${preventivoNumero.toString().padLeft(3, '0')} - ${fmtUI(t['totale']!)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
        const SizedBox(height: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)), onPressed: resetTutto, child: const Text('🔄 PULISCI TUTTO - NUOVO PREVENTIVO', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: generaPDF, child: Text('GENERA PDF N. ${DateTime.now().year}-${preventivoNumero.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        const SizedBox(height: 60),
      ]),
    );
  }
}
