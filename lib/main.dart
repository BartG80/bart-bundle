import 'package:flutter/material.dart';

void main() => runApp(const FalegnameApp());

class FalegnameApp extends StatelessWidget {
  const FalegnameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preventivo Falegname Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.brown),
      home: const HomePage(),
    );
  }
}

class PriceList {
  static const Map<String, Map<int, double>> legni = {
    'Rovere': {10: 80, 12: 95, 15: 115, 18: 135, 20: 150, 22: 165, 25: 185, 30: 220, 35: 250, 40: 290, 50: 370, 60: 450},
    'Frassino': {10: 70, 12: 85, 15: 105, 18: 125, 20: 140, 22: 155, 25: 175, 30: 205, 40: 270, 50: 340, 60: 410},
    'Noce Nazionale': {10: 95, 12: 115, 15: 135, 18: 160, 20: 180, 25: 220, 30: 260, 40: 340, 50: 430, 60: 520},
    'Abete': {10: 35, 12: 42, 15: 52, 18: 62, 20: 70, 22: 78, 25: 88, 30: 105, 40: 135, 50: 170, 60: 205},
    'Pino': {10: 40, 12: 48, 15: 58, 18: 70, 20: 78, 22: 86, 25: 98, 30: 118, 40: 150, 50: 190, 60: 230},
    'Faggio': {10: 55, 12: 65, 15: 80, 18: 95, 20: 105, 25: 130, 30: 155, 40: 200, 50: 255, 60: 310},
  };

  static const Map<String, Map<int, double>> pannelli = {
    'Multistrato Pioppo 2440x1220': {4: 22, 6: 26, 8: 30, 9: 32, 10: 34, 12: 38, 15: 44, 18: 48, 20: 54, 25: 68, 30: 82},
    'Multistrato Betulla 2500x1280': {4: 38, 6: 45, 8: 52, 9: 58, 10: 62, 12: 68, 15: 76, 18: 85, 20: 96, 25: 118, 30: 142},
    'Pino Fenolico 2440x1220': {9: 32, 12: 38, 15: 46, 18: 40, 20: 55, 21: 58, 25: 72, 27: 78, 30: 88},
    'Okumè 2500x1220': {4: 32, 6: 38, 8: 45, 10: 52, 12: 60, 15: 68, 18: 68, 20: 78, 25: 98, 30: 120},
    'OSB 2440x1220': {12: 24, 15: 28, 18: 32, 20: 36, 22: 39, 25: 45},
    'MDF 2800x2070': {4: 22, 6: 26, 8: 32, 9: 34, 10: 36, 12: 40, 15: 44, 18: 48, 20: 54, 25: 68, 30: 85},
    'MDF 2440x1220': {4: 18, 6: 22, 8: 26, 10: 30, 12: 34, 15: 38, 18: 42, 20: 48, 25: 60, 30: 75},
    'Truciolare 2800x2070': {15: 28, 18: 34, 20: 38, 25: 48, 30: 58},
    'Nobilitato Bianco 2800x2070': {8: 32, 10: 36, 12: 40, 15: 44, 18: 48, 20: 54, 25: 65, 30: 78},
    'Nobilitato Rovere 2800x2070': {8: 42, 10: 46, 12: 50, 15: 56, 18: 62, 20: 70, 25: 82, 30: 96},
    'Nobilitato Grigio/Nero 2800x2070': {8: 38, 10: 42, 12: 46, 15: 52, 18: 58, 20: 66, 25: 78, 30: 92},
    'Nobilitato Frassino/Noce 2800x2070': {8: 44, 10: 48, 12: 52, 15: 58, 18: 65, 20: 74, 25: 86, 30: 102},
    'Listellare Rovere': {15: 110, 18: 130, 22: 155, 27: 185, 30: 205, 35: 235, 40: 270},
    'Listellare Frassino': {15: 95, 18: 115, 22: 135, 27: 165, 30: 185, 35: 210, 40: 245},
    'Lamellare Abete 400-800x1200-4000': {10: 32, 12: 36, 15: 42, 18: 48, 20: 52, 22: 58, 25: 66, 30: 78, 40: 105, 50: 135, 60: 165},
    'Lamellare Pino': {10: 35, 12: 40, 15: 46, 18: 52, 20: 58, 22: 64, 25: 72, 30: 86, 40: 115, 50: 145, 60: 178},
    'Lamellare Rovere': {10: 95, 12: 110, 15: 130, 18: 150, 20: 165, 22: 182, 25: 205, 30: 245, 40: 320, 50: 395, 60: 475},
  };
}

class MobileItem { String nome; double ml; double mq; int qta; MobileItem({required this.nome, this.ml=0, this.mq=0, this.qta=1}); }
class LegnoItem { String tipo; int spessore; double mq; double prezzoMq; LegnoItem({required this.tipo, required this.spessore, required this.mq, required this.prezzoMq}); double get totale => mq * prezzoMq; }
class PannelloItem { String tipo; int spessore; int qta; double prezzoPannello; PannelloItem({required this.tipo, required this.spessore, required this.qta, required this.prezzoPannello}); double get totale => qta * prezzoPannello; }

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<MobileItem> mobili = []; List<LegnoItem> legni = []; List<PannelloItem> pannelli = [];
  double extraFerramenta = 0; double extraLaccatura = 0; double marginePercent = 30; double ivaPercent = 22;
  double scartoLegniPercent = 15; double scartoPannelliPercent = 10;

  double get totMqMobili => mobili.fold(0, (s,e)=> s + e.mq * e.qta);
  double get totMlMobili => mobili.fold(0, (s,e)=> s + e.ml * e.qta);
  double get totLegniNetto => legni.fold(0, (s,e)=> s + e.totale);
  double get totPannelliNetto => pannelli.fold(0, (s,e)=> s + e.totale);
  double get scartoLegniVal => totLegniNetto * scartoLegniPercent / 100;
  double get scartoPannelliVal => totPannelliNetto * scartoPannelliPercent / 100;
  double get totLegni => totLegniNetto + scartoLegniVal;
  double get totPannelli => totPannelliNetto + scartoPannelliVal;
  double get imponibile => totLegni + totPannelli + extraFerramenta + extraLaccatura;
  double get utile => imponibile * marginePercent / 100;
  double get totaleImponibile => imponibile + utile;
  double get iva => totaleImponibile * ivaPercent / 100;
  double get totaleIvato => totaleImponibile + iva;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preventivo Falegname PRO v4'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(12), children: [_cardMobili(), const SizedBox(height:12), _cardLegni(), const SizedBox(height:12), _cardPannelli(), const SizedBox(height:12), _cardTotali()]),
      floatingActionButton: FloatingActionButton.extended(onPressed: ()=> _showRiepilogoPdf(), label: const Text('Vedi PDF'), icon: const Icon(Icons.picture_as_pdf)),
    );
  }

  Widget _cardMobili(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.chair), const SizedBox(width:8), const Text('MOBILI - ml/mq/qta', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _addMobile, icon: const Icon(Icons.add))]), ...mobili.asMap().entries.map((e){ var i=e.key; var m=e.value; return ListTile(title: Text(m.nome), subtitle: Text('ml:${m.ml} mq:${m.mq} qta:${m.qta}'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> mobili.removeAt(i))));}), Text('Totale: ${totMlMobili.toStringAsFixed(1)} ml | ${totMqMobili.toStringAsFixed(2)} mq', style: const TextStyle(fontWeight: FontWeight.bold))]))); }
  Widget _cardLegni(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.forest), const SizedBox(width:8), const Text('LEGNI + SCARTO', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _addLegno, icon: const Icon(Icons.add))]), Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Scarto legni %'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> scartoLegniPercent = double.tryParse(v)??15))), const SizedBox(width:8), Text('Scarto: +${scartoLegniVal.toStringAsFixed(2)}€', style: const TextStyle(color: Colors.orange))]), ...legni.asMap().entries.map((en){ var i=en.key; var l=en.value; return ListTile(title: Text('${l.tipo} ${l.spessore}mm'), subtitle: Text('${l.mq}mq x ${l.prezzoMq}€ = ${l.totale.toStringAsFixed(2)}€'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> legni.removeAt(i))));}), Text('Netto: ${totLegniNetto.toStringAsFixed(2)}€ + ${scartoLegniPercent}% = ${totLegni.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]))); }
  Widget _cardPannelli(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.layers), const SizedBox(width:8), const Text('PANNELLI + NOBILITATO + SCARTO', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _addPannello, icon: const Icon(Icons.add))]), Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Scarto pannelli %'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> scartoPannelliPercent = double.tryParse(v)??10))), const SizedBox(width:8), Text('Scarto: +${scartoPannelliVal.toStringAsFixed(2)}€', style: const TextStyle(color: Colors.orange))]), ...pannelli.asMap().entries.map((en){ var i=en.key; var p=en.value; return ListTile(title: Text('${p.tipo} ${p.spessore}mm'), subtitle: Text('${p.qta} x ${p.prezzoPannello}€ = ${p.totale.toStringAsFixed(2)}€'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> pannelli.removeAt(i))));}), Text('Netto: ${totPannelliNetto.toStringAsFixed(2)}€ + ${scartoPannelliPercent}% = ${totPannelli.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]))); }
  Widget _cardTotali(){ return Card(color: Colors.brown.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [TextField(decoration: const InputDecoration(labelText: 'Extra ferramenta €'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> extraFerramenta = double.tryParse(v)??0)), TextField(decoration: const InputDecoration(labelText: 'Extra laccatura/trasporto €'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> extraLaccatura = double.tryParse(v)??0)), TextField(decoration: const InputDecoration(labelText: 'Margine %'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> marginePercent = double.tryParse(v)??30)), const Divider(), _rowTot('Legni netto', totLegniNetto), _rowTot('Scarto legni ${scartoLegniPercent}%', scartoLegniVal), _rowTot('Pannelli netto', totPannelliNetto), _rowTot('Scarto pannelli ${scartoPannelliPercent}%', scartoPannelliVal), _rowTot('Materiale + scarti + extra', imponibile), _rowTot('Utile $marginePercent%', utile), _rowTot('IMPONIBILE', totaleImponibile, bold:true), _rowTot('IVA $ivaPercent%', iva), _rowTot('TOTALE IVATO', totaleIvato, bold:true, big:true)]))); }
  Widget _rowTot(String l, double v, {bool bold=false, bool big=false}){ return Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal, fontSize: big?16:13)), Text('${v.toStringAsFixed(2)}€', style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal, fontSize: big?16:13))])); }
  void _addMobile(){ showDialog(context: context, builder: (c){ var nome='Mobile'; double ml=0,mq=0; int qta=1; return AlertDialog(title: const Text('Aggiungi Mobile'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(onChanged: (v)=> nome=v, decoration: const InputDecoration(labelText: 'Nome')), TextField(onChanged: (v)=> ml=double.tryParse(v)??0, decoration: const InputDecoration(labelText: 'ml'), keyboardType: TextInputType.number), TextField(onChanged: (v)=> mq=double.tryParse(v)??0, decoration: const InputDecoration(labelText: 'mq'), keyboardType: TextInputType.number), TextField(onChanged: (v)=> qta=int.tryParse(v)??1, decoration: const InputDecoration(labelText: 'qta'), keyboardType: TextInputType.number)]), actions: [TextButton(onPressed: (){ setState(()=> mobili.add(MobileItem(nome:nome, ml:ml, mq:mq, qta:qta))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);}); }
  void _addLegno(){ String tipo = PriceList.legni.keys.first; int spessore = PriceList.legni[tipo]!.keys.first; double mq = 0; showDialog(context: context, builder: (c){ return StatefulBuilder(builder: (c2,setD){ double prezzo = PriceList.legni[tipo]![spessore]??0; return AlertDialog(title: const Text('Aggiungi Legno'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(value: tipo, isExpanded: true, items: PriceList.legni.keys.map((k)=> DropdownMenuItem(value:k, child: Text(k))).toList(), onChanged: (v){ setD(()=> tipo=v!); spessore = PriceList.legni[tipo]!.keys.first; }), DropdownButton<int>(value: spessore, isExpanded: true, items: PriceList.legni[tipo]!.keys.map((s)=> DropdownMenuItem(value:s, child: Text('$s mm - ${PriceList.legni[tipo]![s]}€/mq'))).toList(), onChanged: (v)=> setD(()=> spessore=v!)), TextField(decoration: const InputDecoration(labelText: 'MQ'), keyboardType: TextInputType.number, onChanged: (v)=> mq=double.tryParse(v)??0)]), actions: [TextButton(onPressed: (){ setState(()=> legni.add(LegnoItem(tipo:tipo, spessore:spessore, mq:mq, prezzoMq:prezzo))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);});}); }
  void _addPannello(){ String tipo = PriceList.pannelli.keys.first; int spessore = PriceList.pannelli[tipo]!.keys.first; int qta=1; showDialog(context: context, builder: (c){ return StatefulBuilder(builder: (c2,setD){ double prezzo = PriceList.pannelli[tipo]![spessore]??0; return AlertDialog(title: const Text('Aggiungi Pannello'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(value: tipo, isExpanded: true, items: PriceList.pannelli.keys.map((k)=> DropdownMenuItem(value:k, child: Text(k, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v){ setD(()=> tipo=v!); spessore = PriceList.pannelli[tipo]!.keys.first; }), DropdownButton<int>(value: spessore, isExpanded: true, items: PriceList.pannelli[tipo]!.keys.map((s)=> DropdownMenuItem(value:s, child: Text('$s mm - ${PriceList.pannelli[tipo]![s]}€'))).toList(), onChanged: (v)=> setD(()=> spessore=v!)), TextField(decoration: const InputDecoration(labelText: 'Qta pannelli'), keyboardType: TextInputType.number, onChanged: (v)=> qta=int.tryParse(v)??1)]), actions: [TextButton(onPressed: (){ setState(()=> pannelli.add(PannelloItem(tipo:tipo, spessore:spessore, qta:qta, prezzoPannello:prezzo))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);});}); }
  void _showRiepilogoPdf(){ showDialog(context: context, builder: (c)=> AlertDialog(title: const Text('Preventivo PDF con scarti'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MOBILI: ${totMqMobili.toStringAsFixed(2)} mq'), Text('LEGNI NETTO: ${totLegniNetto.toStringAsFixed(2)}€ + scarto ${scartoLegniVal.toStringAsFixed(2)}€ = ${totLegni.toStringAsFixed(2)}€'), Text('PANNELLI NETTO: ${totPannelliNetto.toStringAsFixed(2)}€ + scarto ${scartoPannelliVal.toStringAsFixed(2)}€ = ${totPannelli.toStringAsFixed(2)}€'), const Divider(), Text('IMPONIBILE: ${totaleImponibile.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)), Text('IVA: ${iva.toStringAsFixed(2)}€'), Text('TOTALE IVATO: ${totaleIvato.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:16))])), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Chiudi'))])); }
}
