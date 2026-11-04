import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const BartApp());
}

class BartApp extends StatelessWidget {
  const BartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bart v8.7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: false,
      ),
      home: const PrevPage(),
    );
  }
}

// ================= LEGNO =================
class LegnoItem {
  String essenza;
  double prezzo;
  double extra;
  int lunghezzaMm;
  int spessoreMm;
  int qty;

  LegnoItem({
    this.essenza = 'Pino',
    this.prezzo = 0,
    this.extra = 0,
    this.lunghezzaMm = 2000,
    this.spessoreMm = 30,
    this.qty = 1,
  });
}

// ================= PANNELLO =================
class PannelloItem {
  String tipo;
  double prezzo;
  double extra;
  int spessoreMm;
  int qty;

  PannelloItem({
    this.tipo = 'Multistrato Okume',
    this.prezzo = 0,
    this.extra = 0,
    this.spessoreMm = 18,
    this.qty = 1,
  });
}

// ================= MANUFATTO =================
class ManufattoItem {
  TextEditingController nome = TextEditingController();
  TextEditingController l = TextEditingController();
  TextEditingController ll = TextEditingController();
  TextEditingController h = TextEditingController();
  TextEditingController p = TextEditingController();
}

class PrevPage extends StatefulWidget {
  const PrevPage({super.key});

  @override
  State<PrevPage> createState() => _S();
}

class _S extends State<PrevPage> {
  int prog = 9;

  // FALEGNAME
  final falNome = TextEditingController();
  final falInd = TextEditingController();
  final falPiva = TextEditingController();
  final falTel = TextEditingController();
  final falEmail = TextEditingController();

  // CLIENTE
  final cliNome = TextEditingController();
  final cliInd = TextEditingController();
  final cliCap = TextEditingController();
  final cliTel = TextEditingController();
  final cliEmail = TextEditingController();
  final cliCF = TextEditingController();

  // LAVORAZIONI
  final manodopera = TextEditingController(text: '0');
  final levigatura = TextEditingController(text: '0');
  final finitura = TextEditingController(text: '0');
  final verniciatura = TextEditingController(text: '0');
  final utile = TextEditingController(text: '0');

  List<LegnoItem> legni = [];
  List<PannelloItem> pannelli = [];
  List<ManufattoItem> manufatti = [];

  final essenze = [
    'Pino',
    'Abete',
    'Faggio',
    'Frassino',
    'Rovere',
    'Castagno',
    'Noce',
    'Ciliegio',
    'Canaletto',
    'Wenge',
    'Teak'
  ];

  final tipiPann = [
    'Multistrato Okume',
    'Multistrato Betulla',
    'Multistrato Pino Fenolico',
    'Multistrato Pioppo',
    'Multistrato Faggio',
    'Multistrato Rovere',
    'Lamellare Pino',
    'Lamellare Faggio',
    'Lamellare Rovere',
    'Lamellare Abete',
    'MDF',
    'Truciolare',
    'Marino',
    'OSB',
    'Listellare'
  ];

  final spessoriPann = [4, 6, 8, 10, 12, 15, 18, 20, 25, 27, 30];
  final spessoriLegno = [20, 25, 30, 40, 50, 60, 70];
  final lunghezzeLegno = [1000, 2000, 4000];

  double parse(TextEditingController c) {
    return double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
  }

  double mqSingolo(ManufattoItem m) {
    double L = double.tryParse(m.l.text.replaceAll(',', '.')) ?? 0;
    double l = double.tryParse(m.ll.text.replaceAll(',', '.')) ?? 0;
    if (L == 0 || l == 0) return 0;
    return (L * l) / 1000000;
  }

  double totMq() {
    double t = 0;
    for (var m in manufatti) {
      t += mqSingolo(m);
    }
    return t;
  }

  double calcolaTot() {
    if (legni.isEmpty && pannelli.isEmpty && manufatti.isEmpty) {
      return 0;
    }
    double mq = totMq();
    if (mq == 0) return 0;

    double mat = 0;
    for (var l in legni) {
      mat += (l.prezzo + l.extra) * l.qty * mq;
    }
    for (var p in pannelli) {
      mat += (p.prezzo + p.extra) * p.qty * mq;
    }

    double lavori = parse(manodopera) +
        parse(levigatura) +
        parse(finitura) +
        parse(verniciatura);

    double sub = mat + lavori;
    double u = parse(utile);
    return sub + (sub * u / 100);
  }

  void pulisci() {
    setState(() {
      cliNome.clear();
      cliInd.clear();
      cliCap.clear();
      cliTel.clear();
      cliEmail.clear();
      cliCF.clear();
      legni.clear();
      pannelli.clear();
      manufatti.clear();
      manodopera.text = '0';
      levigatura.text = '0';
      finitura.text = '0';
      verniciatura.text = '0';
      utile.text = '0';
      prog++;
    });
  }

  Future<void> pdf() async {
    final d = pw.Document();
    double mq = totMq();
    double tot = calcolaTot();
    double iva = tot * 0.22;

    d.addPage(
      pw.MultiPage(
        build: (c) => [
          pw.Text(
            'PREVENTIVO N. ${prog.toString().padLeft(3, '0')} - Bart v8.7',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'FALEGNAME: ${falNome.text} - ${falInd.text} - P.IVA ${falPiva.text}'),
                pw.Text('Tel ${falTel.text} - ${falEmail.text}'),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CLIENTE: ${cliNome.text}'),
                pw.Text('${cliInd.text} - CAP ${cliCap.text}'),
                pw.Text(
                    'Tel ${cliTel.text} - Email ${cliEmail.text} - CF ${cliCF.text}'),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'MANUFATTI (${manufatti.length}) - TOT MQ: ${mq.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          for (var m in manufatti)
            pw.Text(
                '${m.nome.text} - L ${m.l.text}mm x l ${m.ll.text}mm x H ${m.h.text}mm x P ${m.p.text}mm - Mq ${mqSingolo(m).toStringAsFixed(2)}'),
          pw.SizedBox(height: 6),
          pw.Text('LEGNI:'),
          for (var l in legni)
            pw.Text(
                '${l.qty}x ${l.essenza} - Lung. ${l.lunghezzaMm}mm - Spessore ${l.spessoreMm}mm - Prezzo fisso ${l.prezzo.toStringAsFixed(0)}€ + extra ${l.extra.toStringAsFixed(0)}€'),
          pw.Text('PANNELLI:'),
          for (var p in pannelli)
            pw.Text(
                '${p.qty}x ${p.tipo} - Spessore ${p.spessoreMm}mm - Prezzo fisso ${p.prezzo.toStringAsFixed(0)}€ + extra ${p.extra.toStringAsFixed(0)}€'),
          pw.SizedBox(height: 6),
          pw.Text(
              'Manodopera: ${manodopera.text}€ - Levigatura: ${levigatura.text}€ - Finitura: ${finitura.text}€ - Verniciatura: ${verniciatura.text}€'),
          pw.SizedBox(height: 10),
          pw.Text(
            'TOTALE: ${tot.toStringAsFixed(2)}€ + IVA 22% ${iva.toStringAsFixed(2)}€ = ${(tot + iva).toStringAsFixed(2)}€',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'NOTE LEGALI:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
              '1. Validità 15 giorni (30 su richiesta)\n2. Prezzi soggetti a variazione mercato\n3. Venature/nodi naturali\n4. Tolleranza +/-2mm\n5. Tempi consegna indicativi\n6. Trasporto/montaggio esclusi\n7. Pagamento 40% acconto, 60% alla consegna\n8. Garanzia 24 mesi\n9. Modifiche in corso d\'opera\n10. Foro Mantova'),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (f) async => d.save());
  }

  Widget qtyRow(int qty, Function(int) onCh) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle),
          onPressed: () => setState(() => onCh(qty > 1 ? qty - 1 : 1)),
        ),
        Text(
          '$qty pz',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: () => setState(() => onCh(qty + 1)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bart v8.7 - N.${prog.toString().padLeft(3, '0')}'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: pulisci,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INTESTAZIONE FALEGNAME',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: falNome,
              decoration: const InputDecoration(labelText: 'Nome Falegname'),
            ),
            TextField(
              controller: falInd,
              decoration: const InputDecoration(labelText: 'Indirizzo'),
            ),
            TextField(
              controller: falPiva,
              decoration: const InputDecoration(labelText: 'P.IVA'),
            ),
            TextField(
              controller: falTel,
              decoration: const InputDecoration(labelText: 'Tel'),
            ),
            TextField(
              controller: falEmail,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const Divider(),
            const Text(
              'CLIENTE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: cliNome,
              decoration: const InputDecoration(labelText: 'Nome Cliente'),
            ),
            TextField(
              controller: cliInd,
              decoration: const InputDecoration(labelText: 'Indirizzo Cliente'),
            ),
            TextField(
              controller: cliCap,
              decoration: const InputDecoration(labelText: 'CAP'),
            ),
            TextField(
              controller: cliTel,
              decoration: const InputDecoration(labelText: 'Tel'),
            ),
            TextField(
              controller: cliEmail,
              decoration: const InputDecoration(labelText: 'Email Cliente'),
            ),
            TextField(
              controller: cliCF,
              decoration: const InputDecoration(labelText: 'CF'),
            ),
            const Divider(),

            // LEGNI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ESSENZE LEGNO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => legni.add(LegnoItem())),
                  child: const Text('+ AGGIUNGI LEGNO'),
                ),
              ],
            ),
            for (int i = 0; i < legni.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: legni[i].essenza,
                              isExpanded: true,
                              items: essenze
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => legni[i].essenza = v!),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => legni.removeAt(i)),
                          ),
                        ],
                      ),
                      qtyRow(legni[i].qty, (v) => legni[i].qty = v),
                      const Text('Lunghezza legno in mm:'),
                      DropdownButton<int>(
                        value: legni[i].lunghezzaMm,
                        isExpanded: true,
                        items: lunghezzeLegno
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text('$e mm')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => legni[i].lunghezzaMm = v!),
                      ),
                      const Text('Spessore legno in mm:'),
                      DropdownButton<int>(
                        value: legni[i].spessoreMm,
                        isExpanded: true,
                        items: spessoriLegno
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text('$e mm')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => legni[i].spessoreMm = v!),
                      ),
                      Text(
                        'Prezzo fisso essenza: ${legni[i].prezzo.toInt()}€ (slide 0-500) - ${legni[i].qty} pz x ${legni[i].lunghezzaMm}mm x ${legni[i].spessoreMm}mm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: legni[i].prezzo,
                        min: 0,
                        max: 500,
                        divisions: 500,
                        label: '${legni[i].prezzo.toInt()}€',
                        onChanged: (v) =>
                            setState(() => legni[i].prezzo = v),
                      ),
                      Text('Extra essenza: ${legni[i].extra.toInt()}€'),
                      Slider(
                        value: legni[i].extra,
                        min: 0,
                        max: 100,
                        onChanged: (v) =>
                            setState(() => legni[i].extra = v),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(),

            // PANNELLI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PANNELLI MULTISTRATO / LISTELLARE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => pannelli.add(PannelloItem())),
                  child: const Text('+ AGGIUNGI PANNELLO'),
                ),
              ],
            ),
            for (int i = 0; i < pannelli.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: pannelli[i].tipo,
                              isExpanded: true,
                              items: tipiPann
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => pannelli[i].tipo = v!),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => pannelli.removeAt(i)),
                          ),
                        ],
                      ),
                      qtyRow(pannelli[i].qty, (v) => pannelli[i].qty = v),
                      const Text('Spessore pannello in mm:'),
                      DropdownButton<int>(
                        value: pannelli[i].spessoreMm,
                        isExpanded: true,
                        items: spessoriPann
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text('$e mm')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => pannelli[i].spessoreMm = v!),
                      ),
                      Text(
                        'Prezzo fisso pannello: ${pannelli[i].prezzo.toInt()}€ (slide 0-250) - ${pannelli[i].qty} pz x ${pannelli[i].spessoreMm}mm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: pannelli[i].prezzo,
                        min: 0,
                        max: 250,
                        divisions: 250,
                        label: '${pannelli[i].prezzo.toInt()}€',
                        onChanged: (v) =>
                            setState(() => pannelli[i].prezzo = v),
                      ),
                      Text('Extra pannello: ${pannelli[i].extra.toInt()}€'),
                      Slider(
                        value: pannelli[i].extra,
                        min: 0,
                        max: 100,
                        onChanged: (v) =>
                            setState(() => pannelli[i].extra = v),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(),

            // MANUFATTI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MANUFATTI DA CREARE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => manufatti.add(ManufattoItem())),
                  child: const Text('+ AGGIUNGI MANUFATTO'),
                ),
              ],
            ),
            for (int i = 0; i < manufatti.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: manufatti[i].nome,
                              decoration: const InputDecoration(
                                  labelText: 'Descrizione manufatto'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => manufatti.removeAt(i)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: manufatti[i].l,
                              decoration: const InputDecoration(
                                  labelText: 'L mm'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: manufatti[i].ll,
                              decoration: const InputDecoration(
                                  labelText: 'l mm'),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: manufatti[i].h,
                              decoration: const InputDecoration(
                                  labelText: 'H mm'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: manufatti[i].p,
                              decoration: const InputDecoration(
                                  labelText: 'P mm'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Mq questo manufatto: ${mqSingolo(manufatti[i]).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              'TOT MQ: ${totMq().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const Text(
              'LAVORAZIONI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: manodopera,
              decoration: const InputDecoration(labelText: 'Manodopera €'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: levigatura,
              decoration: const InputDecoration(labelText: 'Levigatura €'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: finitura,
              decoration: const InputDecoration(labelText: 'Finitura €'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: verniciatura,
              decoration: const InputDecoration(labelText: 'Verniciatura €'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: utile,
              decoration:
                  const InputDecoration(labelText: 'Utile % (nascosto)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text(
              'TOT STIMATO: ${calcolaTot().toStringAsFixed(2)} EUR - MQ ${totMq().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'NOTE LEGALI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '1. Validità 15 gg (30 su richiesta)\n2. Prezzi soggetti a variazione mercato\n3. Venature/nodi naturali\n4. Tolleranza +/-2mm\n5. Tempi consegna indicativi\n6. Trasporto/montaggio esclusi\n7. Pagamento 40% acconto, 60% alla consegna\n8. Garanzia 24 mesi\n9. Modifiche in corso d\'opera\n10. Foro Mantova',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pdf,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                child: Text(
                    'GENERA PDF v8.7 N.${prog.toString().padLeft(3, '0')} - ${calcolaTot().toStringAsFixed(0)}€'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pulisci,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('PULISCI TUTTO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
