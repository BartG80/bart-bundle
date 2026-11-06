import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() { runApp(const BartApp()); }

class BartApp extends StatelessWidget {
  const BartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wood Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown, useMaterial3: false),
      home: const PrevPage(),
    );
  }
}

class LegnoItem {
  String essenza;
  double prezzo;
  double extra;
  double scarto;
  int lunghezzaMm;
  int larghezzaMm;
  int spessoreMm;
  int qty;
  LegnoItem({this.essenza = 'Pino', this.prezzo = 0, this.extra = 0, this.scarto = 10, this.lunghezzaMm = 2000, this.larghezzaMm = 100, this.spessoreMm = 30, this.qty = 1});
}

class PannelloItem {
  String tipo;
  double prezzo;
  double extra;
  double scarto;
  int spessoreMm;
  int qty;
  PannelloItem({this.tipo = 'Multistrato Okume', this.prezzo = 0, this.extra = 0, this.scarto = 5, this.spessoreMm = 18, this.qty = 1});
}

class ManufattoItem {
  TextEditingController nome = TextEditingController();
  TextEditingController larghezza = TextEditingController();
  TextEditingController altezza = TextEditingController();
  TextEditingController profondita = TextEditingController();
  TextEditingController lunghezzaTop = TextEditingController();
  String tipo = 'Mobile';
  int qty = 1;
}

class LavorazioneItem {
  String nome;
  TextEditingController ore = TextEditingController(text: '0');
  TextEditingController prezzoOra = TextEditingController(text: '0');
  LavorazioneItem(this.nome);
  double totale() {
    double o = double.tryParse(ore.text.replaceAll(',', '.')) ?? 0;
    double pr = double.tryParse(prezzoOra.text.replaceAll(',', '.')) ?? 0;
    return o * pr;
  }
}

class FerramentaItem {
  TextEditingController nome = TextEditingController();
  int qty;
  TextEditingController prezzoPz = TextEditingController(text: '0');
  FerramentaItem({this.qty = 1});
  double totale() {
    double pr = double.tryParse(prezzoPz.text.replaceAll(',', '.')) ?? 0;
    return qty * pr;
  }
}

class PrevPage extends StatefulWidget {
  const PrevPage({super.key});
  @override
  State<PrevPage> createState() => _S();
}

class _S extends State<PrevPage> {
  int prog = 9;

  @override
  void initState() {
    super.initState();
    _caricaProg();
  }

  Future<void> _caricaProg() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { prog = prefs.getInt('prog_preventivo') ?? 9; });
  }

  Future<void> _salvaProg() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prog_preventivo', prog);
  }

  final falNome = TextEditingController();
  final falInd = TextEditingController();
  final falProvincia = TextEditingController();
  final falPiva = TextEditingController();
  final falTel = TextEditingController();
  final falEmail = TextEditingController();

  final cliNome = TextEditingController();
  final cliInd = TextEditingController();
  final cliCap = TextEditingController();
  final cliTel = TextEditingController();
  final cliEmail = TextEditingController();
  final cliCF = TextEditingController();

  // NIENTE PIU' UTILE - IL GUADAGNO E' NELLE LAVORAZIONI

  List<LegnoItem> legni = [];
  List<PannelloItem> pannelli = [];
  List<ManufattoItem> manufatti = [];
  List<LavorazioneItem> lavorazioni = [
    LavorazioneItem('Manodopera'),
    LavorazioneItem('Levigatura'),
    LavorazioneItem('Finitura'),
    LavorazioneItem('Verniciatura'),
  ];
  List<FerramentaItem> ferramenta = [FerramentaItem()];

  final essenze = ['Pino', 'Abete', 'Faggio', 'Frassino', 'Rovere', 'Castagno', 'Noce', 'Ciliegio', 'Canaletto', 'Wenge', 'Teak'];
  final tipiPann = ['Multistrato Okume', 'Multistrato Betulla', 'Multistrato Pino Fenolico', 'Multistrato Pioppo', 'Multistrato Faggio', 'Multistrato Rovere', 'Lamellare Pino', 'Lamellare Faggio', 'Lamellare Rovere', 'Lamellare Abete', 'MDF', 'Truciolare', 'Marino', 'OSB', 'Listellare'];
  final tipiManufatto = ['Mobile', 'Top / Tavolo', 'Anta / Porta', 'Altro'];
  final spessoriPann = [4, 6, 8, 10, 12, 15, 18, 20, 25, 27, 30];
  final spessoriLegno = [20, 25, 30, 40, 50, 60, 70];

  double parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  double mqSingolo(ManufattoItem m) {
    double L = double.tryParse(m.larghezza.text.replaceAll(',', '.')) ?? 0;
    double H = double.tryParse(m.altezza.text.replaceAll(',', '.')) ?? 0;
    double P = double.tryParse(m.profondita.text.replaceAll(',', '.')) ?? 0;
    double lungTop = double.tryParse(m.lunghezzaTop.text.replaceAll(',', '.')) ?? 0;
    if (m.tipo == 'Mobile') {
      if (L == 0 || H == 0 || P == 0) return 0;
      return (2 * (H * P) + 2 * (L * P)) / 1000000;
    }
    if (m.tipo == 'Top / Tavolo') {
      if (lungTop > 0 && L > 0) return (lungTop * L) / 1000000;
      if (L == 0 || P == 0) return 0;
      return (L * P) / 1000000;
    }
    if (L == 0 || H == 0) return 0;
    return (L * H) / 1000000;
  }

  double totMq() {
    double t = 0;
    for (var m in manufatti) t += mqSingolo(m) * m.qty;
    return t;
  }

  double totLavorazioni() {
    double t = 0;
    for (var l in lavorazioni) t += l.totale();
    return t;
  }

  double totFerramenta() {
    double t = 0;
    for (var f in ferramenta) t += f.totale();
    return t;
  }

  double totMateriale() {
    double mat = 0;
    for (var l in legni) mat += (l.prezzo + l.extra) * l.qty * (1 + l.scarto / 100);
    for (var p in pannelli) mat += (p.prezzo + p.extra) * p.qty * (1 + p.scarto / 100);
    return mat;
  }

  // TOTALE SEMPLICE: Materiale + Lavorazioni (guadagno) + Ferramenta
  double calcolaTot() {
    if (legni.isEmpty && pannelli.isEmpty && manufatti.isEmpty && totLavorazioni() == 0 && totFerramenta() == 0) return 0;
    return totMateriale() + totLavorazioni() + totFerramenta();
  }

  double calcolaIva() => calcolaTot() * 0.22;
  String foroTesto() => falProvincia.text.isEmpty ? '________' : falProvincia.text;

  String dataOggi() {
    final ora = DateTime.now();
    String g = ora.day.toString().padLeft(2, '0');
    String m = ora.month.toString().padLeft(2, '0');
    return '$g/$m/${ora.year}';
  }
  String luogoPreventivo() => falProvincia.text.isEmpty ? '________' : falProvincia.text;

  void pulisci() {
    setState(() {
      cliNome.clear(); cliInd.clear(); cliCap.clear(); cliTel.clear(); cliEmail.clear(); cliCF.clear();
      legni.clear(); pannelli.clear(); manufatti.clear();
      for (var l in lavorazioni) { l.ore.text = '0'; l.prezzoOra.text = '0'; }
      ferramenta = [FerramentaItem()];
      prog++;
    });
    _salvaProg();
  }

  pw.Document buildPdf() {
    final d = pw.Document();
    double mq = totMq();
    double tot = calcolaTot();
    double iva = calcolaIva();

    d.addPage(pw.MultiPage(build: (c) => [
      pw.Text('Wood Pro', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text('PREVENTIVO N. 2026-${prog.toString().padLeft(3, '0')}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.Text('${luogoPreventivo()}, ${dataOggi()}', style: pw.TextStyle(fontSize: 13)),
      pw.SizedBox(height: 8),
      pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('FALEGNAME: ${falNome.text} - ${falInd.text} - ${falProvincia.text} - P.IVA ${falPiva.text}'),
        pw.Text('Tel ${falTel.text} - ${falEmail.text}'),
      ])),
      pw.SizedBox(height: 8),
      pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('CLIENTE: ${cliNome.text}'),
        pw.Text('${cliInd.text} - CAP ${cliCap.text}'),
        pw.Text('Tel ${cliTel.text} - Email ${cliEmail.text} - CF ${cliCF.text}'),
      ])),
      pw.SizedBox(height: 10),
      pw.Text('MANUFATTI (${manufatti.length}) - TOT MQ: ${mq.toStringAsFixed(3)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      for (var m in manufatti) pw.Text('${m.qty}x [${m.tipo}] ${m.nome.text} - L ${m.larghezza.text}mm x H ${m.altezza.text}mm x P ${m.profondita.text}mm ${m.lunghezzaTop.text.isNotEmpty ? "- Lunghezza Top ${m.lunghezzaTop.text}mm" : ""} - Mq ${mqSingolo(m).toStringAsFixed(3)} cad. / Tot ${(mqSingolo(m) * m.qty).toStringAsFixed(3)}'),
      pw.SizedBox(height: 6),
      pw.Text('LEGNI:'),
      for (var l in legni) pw.Text('${l.qty}x ${l.essenza} - Lung. ${l.lunghezzaMm}mm - Larg. ${l.larghezzaMm}mm - Spessore ${l.spessoreMm}mm - ${l.prezzo.toStringAsFixed(0)} EUR/pz + extra ${l.extra.toStringAsFixed(0)} EUR + scarto ${l.scarto.toStringAsFixed(0)}% = ${((l.prezzo + l.extra) * l.qty * (1 + l.scarto / 100)).toStringAsFixed(2)} EUR'),
      pw.Text('PANNELLI:'),
      for (var p in pannelli) pw.Text('${p.qty}x ${p.tipo} - Spessore ${p.spessoreMm}mm - ${p.prezzo.toStringAsFixed(0)} EUR/pz + extra ${p.extra.toStringAsFixed(0)} EUR + scarto ${p.scarto.toStringAsFixed(0)}% = ${((p.prezzo + p.extra) * p.qty * (1 + p.scarto / 100)).toStringAsFixed(2)} EUR'),
      pw.Text('Totale Materiale: ${totMateriale().toStringAsFixed(2)} EUR'),
      pw.SizedBox(height: 6),
      pw.Text('LAVORAZIONI (Ore x EUR/ora):'),
      for (var l in lavorazioni) pw.Text('${l.nome}: ${l.ore.text.isEmpty ? "0" : l.ore.text}h x ${l.prezzoOra.text.isEmpty ? "0" : l.prezzoOra.text} EUR/h = ${l.totale().toStringAsFixed(2)} EUR'),
      pw.Text('Totale Lavorazioni: ${totLavorazioni().toStringAsFixed(2)} EUR'),
      pw.SizedBox(height: 6),
      pw.Text('FERRAMENTA E VARIE (Quantita x EUR/pz):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      for (var f in ferramenta) pw.Text('${f.nome.text.isEmpty ? "Ferramenta" : f.nome.text}: ${f.qty} pz x ${f.prezzoPz.text.isEmpty ? "0" : f.prezzoPz.text} EUR/pz = ${f.totale().toStringAsFixed(2)} EUR'),
      pw.Text('Totale Ferramenta: ${totFerramenta().toStringAsFixed(2)} EUR'),
      pw.SizedBox(height: 10),
      pw.Text('TOTALE: ${tot.toStringAsFixed(2)} EUR + IVA 22% ${iva.toStringAsFixed(2)} EUR = ${(tot + iva).toStringAsFixed(2)} EUR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 14),
      pw.Text('NOTE LEGALI:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text('1. Validita 15 giorni (30 su richiesta)\n2. Prezzi soggetti a variazione mercato\n3. Venature/nodi naturali\n4. Tolleranza +/-2mm\n5. Tempi consegna indicativi\n6. Trasporto/montaggio esclusi\n7. Pagamento 40% acconto, 60% alla consegna\n8. Garanzia 24 mesi\n9. Modifiche in corso d\'opera\n10. Foro competente di ${foroTesto()}'),
    ]));
    return d;
  }

  Future<void> pdfCondividi() async {
    final d = buildPdf();
    double tot = calcolaTot();
    double iva = calcolaIva();
    final dir = await getTemporaryDirectory();
    String nomeCliente = cliNome.text.isEmpty ? 'Cliente' : cliNome.text.replaceAll(' ', '_');
    final file = File('${dir.path}/Preventivo_2026-${prog.toString().padLeft(3, '0')}_$nomeCliente.pdf');
    await file.writeAsBytes(await d.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Preventivo N. 2026-${prog.toString().padLeft(3, '0')} - Totale ${(tot + iva).toStringAsFixed(2)} EUR - ${falNome.text}');
  }

  Future<void> pdfStampa() async {
    final d = buildPdf();
    await Printing.layoutPdf(onLayout: (f) async => d.save());
  }

  Widget qtyRow(int qty, Function(int) onCh) {
    return Row(children: [
      IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => setState(() => onCh(qty > 1 ? qty - 1 : 1))),
      Text('$qty pz', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => onCh(qty + 1))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wood Pro - N.2026-${prog.toString().padLeft(3, '0')}'), backgroundColor: Colors.brown, actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: pulisci)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('INTESTAZIONE FALEGNAME', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: falNome, decoration: const InputDecoration(labelText: 'Nome Falegname')),
          TextField(controller: falInd, decoration: const InputDecoration(labelText: 'Indirizzo - Via')),
          TextField(controller: falProvincia, decoration: const InputDecoration(labelText: 'Provincia / Città - es. Chieti (CH) - per Foro'), onChanged: (_) => setState(() {})),
          TextField(controller: falPiva, decoration: const InputDecoration(labelText: 'P.IVA')),
          TextField(controller: falTel, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: falEmail, decoration: const InputDecoration(labelText: 'Email')),
          const Divider(),
          const Text('CLIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: cliNome, decoration: const InputDecoration(labelText: 'Nome Cliente')),
          TextField(controller: cliInd, decoration: const InputDecoration(labelText: 'Indirizzo Cliente')),
          TextField(controller: cliCap, decoration: const InputDecoration(labelText: 'CAP')),
          TextField(controller: cliTel, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: cliEmail, decoration: const InputDecoration(labelText: 'Email Cliente')),
          TextField(controller: cliCF, decoration: const InputDecoration(labelText: 'CF')),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('ESSENZE LEGNO', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => setState(() => legni.add(LegnoItem())), child: const Text('+ AGGIUNGI LEGNO'))]),
          for (int i = 0; i < legni.length; i++)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: DropdownButton<String>(value: legni[i].essenza, isExpanded: true, items: essenze.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => legni[i].essenza = v!))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => legni.removeAt(i))),
              ]),
              qtyRow(legni[i].qty, (v) => legni[i].qty = v),
              Text('Lunghezza legno: ${legni[i].lunghezzaMm} mm', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(value: legni[i].lunghezzaMm.toDouble(), min: 500, max: 6000, divisions: 55, label: '${legni[i].lunghezzaMm} mm', onChanged: (v) => setState(() => legni[i].lunghezzaMm = v.round())),
              Text('Larghezza legno: ${legni[i].larghezzaMm} mm', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(value: legni[i].larghezzaMm.toDouble(), min: 10, max: 500, divisions: 49, label: '${legni[i].larghezzaMm} mm', onChanged: (v) => setState(() => legni[i].larghezzaMm = v.round())),
              const Text('Spessore legno in mm:'),
              DropdownButton<int>(value: legni[i].spessoreMm, isExpanded: true, items: spessoriLegno.map((e) => DropdownMenuItem(value: e, child: Text('$e mm'))).toList(), onChanged: (v) => setState(() => legni[i].spessoreMm = v!)),
              Text('Prezzo legno: ${legni[i].prezzo.toInt()}€/pz - Totale: ${((legni[i].prezzo + legni[i].extra) * legni[i].qty * (1 + legni[i].scarto / 100)).toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(value: legni[i].prezzo, min: 0, max: 500, divisions: 500, label: '${legni[i].prezzo.toInt()}€', onChanged: (v) => setState(() => legni[i].prezzo = v)),
              Text('Extra essenza: ${legni[i].extra.toInt()}€'),
              Slider(value: legni[i].extra, min: 0, max: 100, onChanged: (v) => setState(() => legni[i].extra = v)),
              Text('Scarto legno: ${legni[i].scarto.toInt()}%'),
              Slider(value: legni[i].scarto, min: 0, max: 30, onChanged: (v) => setState(() => legni[i].scarto = v)),
            ]))),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('PANNELLI', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => setState(() => pannelli.add(PannelloItem())), child: const Text('+ AGGIUNGI PANNELLO'))]),
          for (int i = 0; i < pannelli.length; i++)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: DropdownButton<String>(value: pannelli[i].tipo, isExpanded: true, items: tipiPann.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => pannelli[i].tipo = v!))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => pannelli.removeAt(i))),
              ]),
              qtyRow(pannelli[i].qty, (v) => pannelli[i].qty = v),
              const Text('Spessore pannello in mm:'),
              DropdownButton<int>(value: pannelli[i].spessoreMm, isExpanded: true, items: spessoriPann.map((e) => DropdownMenuItem(value: e, child: Text('$e mm'))).toList(), onChanged: (v) => setState(() => pannelli[i].spessoreMm = v!)),
              Text('Prezzo pannello: ${pannelli[i].prezzo.toInt()}€/pz - Totale: ${((pannelli[i].prezzo + pannelli[i].extra) * pannelli[i].qty * (1 + pannelli[i].scarto / 100)).toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(value: pannelli[i].prezzo, min: 0, max: 250, divisions: 250, label: '${pannelli[i].prezzo.toInt()}€', onChanged: (v) => setState(() => pannelli[i].prezzo = v)),
              Text('Extra pannello: ${pannelli[i].extra.toInt()}€'),
              Slider(value: pannelli[i].extra, min: 0, max: 100, onChanged: (v) => setState(() => pannelli[i].extra = v)),
              Text('Scarto pannello: ${pannelli[i].scarto.toInt()}%'),
              Slider(value: pannelli[i].scarto, min: 0, max: 30, onChanged: (v) => setState(() => pannelli[i].scarto = v)),
            ]))),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('MANUFATTI DA CREARE', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => setState(() => manufatti.add(ManufattoItem())), child: const Text('+ AGGIUNGI MANUFATTO'))]),
          for (int i = 0; i < manufatti.length; i++)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
              Row(children: [
                Expanded(child: TextField(controller: manufatti[i].nome, decoration: const InputDecoration(labelText: 'Descrizione manufatto'))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => manufatti.removeAt(i))),
              ]),
              DropdownButton<String>(value: manufatti[i].tipo, isExpanded: true, items: tipiManufatto.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => manufatti[i].tipo = v!)),
              qtyRow(manufatti[i].qty, (v) => manufatti[i].qty = v),
              Row(children: [
                Expanded(child: TextField(controller: manufatti[i].larghezza, decoration: const InputDecoration(labelText: 'L - Larghezza mm'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
                Expanded(child: TextField(controller: manufatti[i].altezza, decoration: const InputDecoration(labelText: 'H - Altezza mm'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
                Expanded(child: TextField(controller: manufatti[i].profondita, decoration: const InputDecoration(labelText: 'P - Profondità mm'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
              ]),
              TextField(controller: manufatti[i].lunghezzaTop, decoration: const InputDecoration(labelText: 'Lunghezza Top mm - SOLO se è un Top'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
              Text('Mq: ${mqSingolo(manufatti[i]).toStringAsFixed(3)} x ${manufatti[i].qty} pz = ${(mqSingolo(manufatti[i]) * manufatti[i].qty).toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]))),
          Text('TOT MQ: ${totMq().toStringAsFixed(3)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const Text('LAVORAZIONI - ORE (h) - QUI C\'E\' IL GUADAGNO', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var lav in lavorazioni)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lav.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(children: [
                Expanded(child: TextField(controller: lav.ore, decoration: const InputDecoration(labelText: 'Ore (h)'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: lav.prezzoOra, decoration: const InputDecoration(labelText: '€ / ora'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
              ]),
              Text('Totale ${lav.nome}: ${lav.totale().toStringAsFixed(2)} €  (${lav.ore.text.isEmpty ? "0" : lav.ore.text}h x ${lav.prezzoOra.text.isEmpty ? "0" : lav.prezzoOra.text}€/h)', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]))),
          Text('TOTALE LAVORAZIONI: ${totLavorazioni().toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('FERRAMENTA E VARIE - A QUANTITA', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => setState(() => ferramenta.add(FerramentaItem())), child: const Text('+ AGGIUNGI FERRAMENTA'))]),
          for (int i = 0; i < ferramenta.length; i++)
            Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: ferramenta[i].nome, decoration: const InputDecoration(labelText: 'Es: Cerniere, Binari cassetti, Maniglie...'), onChanged: (_) => setState(() {}))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => ferramenta.removeAt(i))),
              ]),
              qtyRow(ferramenta[i].qty, (v) => ferramenta[i].qty = v),
              TextField(controller: ferramenta[i].prezzoPz, decoration: const InputDecoration(labelText: '€ / pz'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
              Text('Totale: ${ferramenta[i].qty} pz x ${ferramenta[i].prezzoPz.text.isEmpty ? "0" : ferramenta[i].prezzoPz.text} €/pz = ${ferramenta[i].totale().toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]))),
          Text('TOTALE FERRAMENTA: ${totFerramenta().toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('TOTALE MATERIALE: ${totMateriale().toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('TOT STIMATO: ${calcolaTot().toStringAsFixed(2)} EUR - MQ ${totMq().toStringAsFixed(3)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('IVA 22%: ${calcolaIva().toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16)),
          Text('TOTALE + IVA: ${(calcolaTot() + calcolaIva()).toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 12),
          const Text('NOTE LEGALI', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('1. Validità 15 gg (30 su richiesta)\n2. Prezzi soggetti a variazione mercato\n3. Venature/nodi naturali\n4. Tolleranza +/-2mm\n5. Tempi consegna indicativi\n6. Trasporto/montaggio esclusi\n7. Pagamento 40% acconto, 60% alla consegna\n8. Garanzia 24 mesi\n9. Modifiche in corso d\'opera\n10. Foro competente di ${foroTesto()}'),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: pdfCondividi, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text('CONDIVIDI PDF SU WHATSAPP / TELEGRAM / MAIL - ${(calcolaTot() + calcolaIva()).toStringAsFixed(0)}€'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: pdfStampa, style: ElevatedButton.styleFrom(backgroundColor: Colors.brown), child: const Text('STAMPA (solo se serve)'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: pulisci, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('PULISCI TUTTO'))),
        ]),
      ),
    );
  }
}
