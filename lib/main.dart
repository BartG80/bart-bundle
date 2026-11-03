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
      title: 'Falegnameria di Bart v4.12',
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
  Manufatto({this.nome='', this.L, this.l, this.H, this.P, this.qta=1});
  double get mq => (L==null || H==null) ? 0 : (L!/1000)*(H!/1000)*qta;
}

class LegnoItem {
  String essenza;
  double prezzoMq;
  double extra;
  double mq;
  double spessore;
  LegnoItem({required this.essenza, required this.prezzoMq, required this.extra, required this.mq, required this.spessore});
  double get tot => (prezzoMq+extra)*mq;
}

class PannelloItem {
  String nome;
  double prezzo;
  double extra;
  double qta;
  double spessore;
  PannelloItem({required this.nome, required this.prezzo, required this.extra, required this.qta, required this.spessore});
  double get tot => (prezzo+extra)*qta;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final falNomeCtrl = TextEditingController();
  final falIndirizzoCtrl = TextEditingController();
  final falPivaCtrl = TextEditingController();
  final falTelCtrl = TextEditingController();
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

  final List<Map<String,dynamic>> essenzeCatalogo = [
    {'nome':'Noce Nazionale','prezzo':100.0,'extra':5.0},
    {'nome':'Noce Canaletto','prezzo':130.0,'extra':6.0},
    {'nome':'Noce Europeo','prezzo':110.0,'extra':5.0},
    {'nome':'Rovere Naturale','prezzo':90.0,'extra':5.0},
    {'nome':'Rovere Rustico','prezzo':85.0,'extra':5.0},
    {'nome':'Rovere Sbiancato','prezzo':95.0,'extra':5.0},
    {'nome':'Frassino','prezzo':80.0,'extra':5.0},
    {'nome':'Frassino Ulivo','prezzo':85.0,'extra':5.0},
    {'nome':'Ciliegio','prezzo':110.0,'extra':5.0},
    {'nome':'Castagno','prezzo':95.0,'extra':5.0},
    {'nome':'Faggio','prezzo':75.0,'extra':4.0},
    {'nome':'Abete','prezzo':60.0,'extra':3.0},
    {'nome':'Pino','prezzo':55.0,'extra':3.0},
    {'nome':'Wenge','prezzo':150.0,'extra':8.0},
    {'nome':'Teak','prezzo':180.0,'extra':8.0},
    {'nome':'Iroko','prezzo':120.0,'extra':6.0},
    {'nome':'Mogano','prezzo':140.0,'extra':7.0},
  ];

  final List<Map<String,dynamic>> pannelliCatalogo = [
    {'nome':'Lamellare Abete','prezzo':38.0,'extra':6.0},
    {'nome':'Lamellare Rovere','prezzo':65.0,'extra':6.0},
    {'nome':'Lamellare Faggio','prezzo':55.0,'extra':6.0},
    {'nome':'Multistrato Pioppo','prezzo':35.0,'extra':5.0},
    {'nome':'Multistrato Betulla','prezzo':55.0,'extra':5.0},
    {'nome':'Multistrato Okume','prezzo':45.0,'extra':5.0},
    {'nome':'MDF Grezzo','prezzo':28.0,'extra':4.0},
    {'nome':'MDF Idrofugo','prezzo':35.0,'extra':4.0},
    {'nome':'MDF Laccato Bianco','prezzo':45.0,'extra':4.0},
    {'nome':'Truciolare Grezzo','prezzo':20.0,'extra':3.0},
    {'nome':'Truciolare Nobilitato','prezzo':32.0,'extra':3.0},
    {'nome':'Compensato Marino','prezzo':60.0,'extra':6.0},
    {'nome':'OSB','prezzo':22.0,'extra':3.0},
    {'nome':'HPL / Laminato','prezzo':40.0,'extra':5.0},
    {'nome':'Listellare','prezzo':50.0,'extra':6.0},
  ];

  final List<double> spessoriLegno = [10,15,20,25,30,35,40,50,60];
  final List<double> spessoriPannello = [6,8,10,12,15,18,20,22,25,30];

  String? essenzaSelezionata;
  double? essenzaMq;
  double essenzaSpessore = 20;

  String? pannelloSelezionato;
  double? pannelloQta;
  double pannelloSpessore = 18;

  double scartoLegni = 0;
  double scartoPannelli = 0;
  double? manoH;
  double? manoPrezzo;
  double? levig;
  double? finitura;
  double? extra;
  double? vern;
  double margin = 30;
  double iva = 22;

  String fmtUI(double n) => '${n.toStringAsFixed(2)} EUR';
  String fmtPDF(double n) => 'EUR ${n.toStringAsFixed(2)}';

  Map<String,double> calcola() {
    double legniNetto = legni.fold(0, (s,l)=>s+l.tot);
    double pannelliNetto = pannelli.fold(0, (s,p)=>s+p.tot);
    double mh = manoH ?? 0;
    double mp = manoPrezzo ?? 0;
    double lv = levig ?? 0;
    double fn = finitura ?? 0;
    double ex = extra ?? 0;
    double vn = vern ?? 0;
    double scL = legniNetto * scartoLegni/100;
    double scP = pannelliNetto * scartoPannelli/100;
    double mano = mh * mp;
    double materiale = legniNetto+scL+pannelliNetto+scP+mano+lv+fn+ex+vn;
    double utile = materiale * margin/100;
    double imponibile = materiale + utile;
    double ivaVal = imponibile * iva/100;
    double totale = imponibile + ivaVal;
    return {'legni': legniNetto, 'scL': scL, 'pannelli': pannelliNetto, 'scP': scP, 'mano': mano, 'materiale': materiale, 'utile': utile, 'imponibile': imponibile, 'iva': ivaVal, 'totale': totale};
  }

  Future<void> generaPDF() async {
    final t = calcola();
    if (t['totale']! == 0 && manufatti.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserisci almeno qualcosa')));
      return;
    }
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (ctx){
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('PREVENTIVO - ${DateTime.now().toIso8601String().substring(0,10)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (falNomeCtrl.text.isNotEmpty) pw.Text('Falegname: ${falNomeCtrl.text} ${falIndirizzoCtrl.text} P.IVA:${falPivaCtrl.text} Tel:${falTelCtrl.text} ${falEmailCtrl.text}', style: const pw.TextStyle(fontSize: 9)),
        if (cliNomeCtrl.text.isNotEmpty) pw.Text('Cliente: ${cliNomeCtrl.text} ${cliLuogoCtrl.text} ${cliIndirizzoCtrl.text} Tel:${cliTelCtrl.text} ${cliEmailCtrl.text} CF:${cliCfCtrl.text}', style: const pw.TextStyle(fontSize: 9)),
        pw.Divider(),
        for (var m in manufatti) pw.Text('${m.nome.isEmpty ? "Manufatto" : m.nome} L:${m.L?.toStringAsFixed(0) ?? "-"} l:${m.l?.toStringAsFixed(0) ?? "-"} H:${m.H?.toStringAsFixed(0) ?? "-"} P:${m.P?.toStringAsFixed(0) ?? "-"} mm [${m.mq.toStringAsFixed(3)} mq] x${m.qta}', style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 6),
        for (var l in legni) pw.Text('Legno: ${l.essenza} sp.${l.spessore}mm ${l.mq}mq - ${fmtPDF(l.tot)}', style: const pw.TextStyle(fontSize: 9)),
        for (var p in pannelli) pw.Text('Pannello: ${p.nome} sp.${p.spessore}mm x${p.qta} - ${fmtPDF(p.tot)}', style: const pw.TextStyle(fontSize: 9)),
        pw.Divider(),
        pw.Text('Materiale+lavorazioni ${fmtPDF(t['materiale']!)} Utile ${margin}% ${fmtPDF(t['utile']!)}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('IMPONIBILE ${fmtPDF(t['imponibile']!)} IVA ${iva}% ${fmtPDF(t['iva']!)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('TOTALE IVATO: ${fmtPDF(t['totale']!)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.Text(
          'NOTA: I prezzi dei materiali possono variare in base all andamento del mercato e il preventivo ha validita di 15/30 giorni dalla data di emissione.',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
        ),
      ]);
    }));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/preventivo_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Preventivo ${fmtPDF(t['totale']!)} - Validita 15/30 gg');
  }

  @override
  Widget build(BuildContext context) {
    final t = calcola();
    final hasData = t['totale']! > 0 || manufatti.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Bart v4.12 CATALOGO + NOTA 15/30')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('FALEGNAME - CREDENZIALI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          TextField(controller: falNomeCtrl, decoration: const InputDecoration(labelText: 'Nome / Ragione Sociale')),
          TextField(controller: falIndirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo')),
          TextField(controller: falPivaCtrl, decoration: const InputDecoration(labelText: 'P.IVA')),
          TextField(controller: falTelCtrl, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: falEmailCtrl, decoration: const InputDecoration(labelText: 'Email')),
        ])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CLIENTE - CREDENZIALI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          TextField(controller: cliNomeCtrl, decoration: const InputDecoration(labelText: 'Nome Cliente *')),
          TextField(controller: cliTelCtrl, decoration: const InputDecoration(labelText: 'Tel')),
          TextField(controller: cliLuogoCtrl, decoration: const InputDecoration(labelText: 'Luogo')),
          TextField(controller: cliIndirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo')),
          TextField(controller: cliCfCtrl, decoration: const InputDecoration(labelText: 'CF / P.IVA')),
          TextField(controller: cliEmailCtrl, decoration: const InputDecoration(labelText: 'Email')),
        ])),
        const SizedBox(height: 12),
        const Text('MANUFATTI - L/l/H/P mm VUOTI (falegname inserisce)', style: TextStyle(fontWeight: FontWeight.bold)),
        for (int i=0;i<manufatti.length;i++) Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
          TextField(decoration: const InputDecoration(labelText: 'Descrizione (Tavolo, Mensola, Porta, Armadio...)'), onChanged: (v){manufatti[i].nome=v; setState((){});}),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'L mm', hintText: 'vuoto', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manufatti[i].L=double.tryParse(v.replaceAll(',','.')); setState((){});})),
            const SizedBox(width: 4),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'l mm', hintText: 'vuoto', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manufatti[i].l=double.tryParse(v.replaceAll(',','.')); setState((){});})),
            const SizedBox(width: 4),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'H mm', hintText: 'vuoto', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manufatti[i].H=double.tryParse(v.replaceAll(',','.')); setState((){});})),
            const SizedBox(width: 4),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'P mm', hintText: 'vuoto', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manufatti[i].P=double.tryParse(v.replaceAll(',','.')); setState((){});})),
          ]),
          const SizedBox(height: 6),
          Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qta', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manufatti[i].qta=double.tryParse(v.replaceAll(',','.'))??1; setState((){});})), const SizedBox(width: 12), Text('mq auto: ${manufatti[i].mq.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: (){setState(()=>manufatti.removeAt(i));}, child: const Text('Elimina', style: TextStyle(color: Colors.red)))),
        ]))),
        ElevatedButton(onPressed: ()=>setState(()=>manufatti.add(Manufatto())), child: const Text('+ Aggiungi Manufatto (vuoto)')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('LEGNI - TUTTE LE ESSENZE + SPESSORI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          DropdownButtonFormField<String>(value: essenzaSelezionata, hint: const Text('Seleziona essenza (vuoto)'), items: essenzeCatalogo.map((e)=>DropdownMenuItem<String>(value: e['nome'] as String, child: Text('${e['nome']} - ${e['prezzo']} EUR/mq'))).toList(), onChanged: (v)=>setState(()=>essenzaSelezionata=v), decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: DropdownButtonFormField<double>(value: essenzaSpessore, items: spessoriLegno.map((s)=>DropdownMenuItem(value: s, child: Text('${s.toInt()} mm'))).toList(), onChanged: (v)=>setState(()=>essenzaSpessore=v??20), decoration: const InputDecoration(labelText: 'Spessore', border: OutlineInputBorder(), isDense: true))),
            const SizedBox(width: 6),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Mq (vuoto)', hintText: 'es: 3.5', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){essenzaMq=double.tryParse(v.replaceAll(',','.')); setState((){});})),
          ]),
          const SizedBox(height: 6),
          ElevatedButton(onPressed: (){if (essenzaSelezionata==null || essenzaMq==null) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleziona essenza e mq'))); return;} final cat = essenzeCatalogo.firstWhere((e)=>e['nome']==essenzaSelezionata); setState((){legni.add(LegnoItem(essenza: essenzaSelezionata!, prezzoMq: cat['prezzo'], extra: cat['extra'], mq: essenzaMq!, spessore: essenzaSpessore)); essenzaSelezionata=null; essenzaMq=null;});}, child: const Text('+ Aggiungi Legno')),
          for (int i=0;i<legni.length;i++) Card(child: ListTile(dense: true, title: Text('${legni[i].essenza} ${legni[i].spessore}mm ${legni[i].mq}mq = ${fmtUI(legni[i].tot)}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){setState(()=>legni.removeAt(i));}))),
        ])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.brown.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PANNELLI - TUTTE LE SEZIONI + SPESSORI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          DropdownButtonFormField<String>(value: pannelloSelezionato, hint: const Text('Seleziona pannello (vuoto)'), items: pannelliCatalogo.map((e)=>DropdownMenuItem<String>(value: e['nome'] as String, child: Text('${e['nome']} - ${e['prezzo']} EUR'))).toList(), onChanged: (v)=>setState(()=>pannelloSelezionato=v), decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: DropdownButtonFormField<double>(value: pannelloSpessore, items: spessoriPannello.map((s)=>DropdownMenuItem(value: s, child: Text('${s.toInt()} mm'))).toList(), onChanged: (v)=>setState(()=>pannelloSpessore=v??18), decoration: const InputDecoration(labelText: 'Spessore', border: OutlineInputBorder(), isDense: true))),
            const SizedBox(width: 6),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Qta (vuoto)', hintText: 'es: 2', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){pannelloQta=double.tryParse(v.replaceAll(',','.')); setState((){});})),
          ]),
          const SizedBox(height: 6),
          ElevatedButton(onPressed: (){if (pannelloSelezionato==null || pannelloQta==null) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleziona pannello e qta'))); return;} final cat = pannelliCatalogo.firstWhere((e)=>e['nome']==pannelloSelezionato); setState((){pannelli.add(PannelloItem(nome: pannelloSelezionato!, prezzo: cat['prezzo'], extra: cat['extra'], qta: pannelloQta!, spessore: pannelloSpessore)); pannelloSelezionato=null; pannelloQta=null;});}, child: const Text('+ Aggiungi Pannello')),
          for (int i=0;i<pannelli.length;i++) Card(child: ListTile(dense: true, title: Text('${pannelli[i].nome} ${pannelli[i].spessore}mm x${pannelli[i].qta} = ${fmtUI(pannelli[i].tot)}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){setState(()=>pannelli.removeAt(i));}))),
        ])),
        const SizedBox(height: 12),
        const Text('Lavorazioni e Costi - tutto vuoto', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Manodopera h', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manoH=double.tryParse(v.replaceAll(',','.')); setState((){});})),
          const SizedBox(width: 6),
          Expanded(child: TextField(decoration: const InputDecoration(labelText: 'EUR/h', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){manoPrezzo=double.tryParse(v.replaceAll(',','.')); setState((){});})),
        ]),
        const SizedBox(height: 6),
        TextField(decoration: const InputDecoration(labelText: 'Levigatura EUR (vuoto)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){levig=double.tryParse(v.replaceAll(',','.')); setState((){});}),
        TextField(decoration: const InputDecoration(labelText: 'Finitura EUR (vuoto)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){finitura=double.tryParse(v.replaceAll(',','.')); setState((){});}),
        TextField(decoration: const InputDecoration(labelText: 'Verniciatura EUR (vuoto)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){vern=double.tryParse(v.replaceAll(',','.')); setState((){});}),
        TextField(decoration: const InputDecoration(labelText: 'Extra laccatura/trasporto EUR (vuoto)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (v){extra=double.tryParse(v.replaceAll(',','.')); setState((){});}),
        const SizedBox(height: 6),
        TextField(decoration: InputDecoration(labelText: 'Utile / Margine % (default ${margin.toInt()}) - PERCENTUALE', border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, controller: TextEditingController(text: margin.toString()), onChanged: (v){margin=double.tryParse(v.replaceAll(',','.'))??30; setState((){});}),
        const SizedBox(height: 12),
        if (!hasData) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('Nessun dato - Inserisci manufatti, legni, pannelli per vedere totale', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center)),
        if (hasData) Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Legni netto ${fmtUI(t['legni']!)}'),
          Text('Pannelli netto ${fmtUI(t['pannelli']!)}'),
          Text('Materiale + lavorazioni ${fmtUI(t['materiale']!)}'),
          Text('Utile / Margine ${margin}% ${fmtUI(t['utile']!)}'),
          const Divider(),
          Text('IMPONIBILE ${fmtUI(t['imponibile']!)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('IVA ${iva}% ${fmtUI(t['iva']!)}'),
          const Divider(),
          Text('TOTALE IVATO ${fmtUI(t['totale']!)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]))),
        const SizedBox(height: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: generaPDF, child: const Text('GENERA PDF + CONDIVIDI - FIX EUR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: const Text(
            'NOTA: I prezzi dei materiali possono variare in base all andamento del mercato e il preventivo ha validita di 15/30 giorni dalla data di emissione.',
            style: TextStyle(fontSize: 11, color: Colors.black87, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}
