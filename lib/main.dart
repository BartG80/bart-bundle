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
    'Rovere': {10: 80, 12: 95, 15: 115, 18: 135, 20: 150, 22: 165, 25: 185, 30: 220, 40: 290, 50: 370, 60: 450},
    'Frassino': {10: 70, 12: 85, 15: 105, 18: 125, 20: 140, 22: 155, 25: 175, 30: 205, 40: 270, 50: 340, 60: 410},
    'Noce Nazionale': {10: 95, 12: 115, 15: 135, 18: 160, 20: 180, 25: 220, 30: 260, 40: 340, 50: 430, 60: 520},
    'Abete': {10: 35, 12: 42, 15: 52, 18: 62, 20: 70, 22: 78, 25: 88, 30: 105, 40: 135, 50: 170, 60: 205},
  };
  static const Map<String, Map<int, double>> pannelli = {
    'Multistrato Pioppo 2440x1220': {4: 22, 6: 26, 8: 30, 9: 32, 10: 34, 12: 38, 15: 44, 18: 48, 20: 54, 25: 68, 30: 82},
    'Multistrato Betulla 2500x1280': {4: 38, 6: 45, 8: 52, 9: 58, 10: 62, 12: 68, 15: 76, 18: 85, 20: 96, 25: 118, 30: 142},
    'MDF 2800x2070': {4: 22, 6: 26, 8: 32, 10: 36, 12: 40, 15: 44, 18: 48, 20: 54, 25: 68, 30: 85},
    'Nobilitato Bianco 2800x2070': {8: 32, 10: 36, 12: 40, 15: 44, 18: 48, 20: 54, 25: 65, 30: 78},
    'Nobilitato Rovere 2800x2070': {8: 42, 10: 46, 12: 50, 15: 56, 18: 62, 20: 70, 25: 82, 30: 96},
    'Nobilitato Grigio/Nero 2800x2070': {8: 38, 10: 42, 12: 46, 15: 52, 18: 58, 20: 66, 25: 78, 30: 92},
    'Listellare Rovere': {15: 110, 18: 130, 22: 155, 27: 185, 30: 205, 40: 270},
    'Lamellare Abete': {10: 32, 12: 36, 15: 42, 18: 48, 20: 52, 22: 58, 25: 66, 30: 78, 40: 105, 50: 135, 60: 165},
    'Lamellare Rovere': {10: 95, 12: 110, 15: 130, 18: 150, 20: 165, 22: 182, 25: 205, 30: 245, 40: 320, 50: 395, 60: 475},
  };
}

class MobileItem { String nome; double ml; double mq; int qta; MobileItem({required this.nome, this.ml=0, this.mq=0, this.qta=1}); }
class LegnoItem { String tipo; int spessore; double mq; double prezzoBase; double extraRegione; LegnoItem({required this.tipo, required this.spessore, required this.mq, required this.prezzoBase, this.extraRegione=0}); double get prezzoMq => prezzoBase + extraRegione; double get totale => mq * prezzoMq; }
class PannelloItem { String tipo; int spessore; int qta; double prezzoBase; double extraRegione; PannelloItem({required this.tipo, required this.spessore, required this.qta, required this.prezzoBase, this.extraRegione=0}); double get prezzoPannello => prezzoBase + extraRegione; double get totale => qta * prezzoPannello; }

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  String miaRagione = ''; String miaVia = ''; String miaCitta = ''; String miaProv = ''; String miaCap = ''; String mioTel = ''; String miaPiva = '';
  String cliente = ''; String cliVia = ''; String cliCitta = ''; String cliProv = ''; String cliCap = ''; String cliTel = ''; String cliPiva = '';
  String numPrev = ''; String dataPrev = '';
  List<MobileItem> mobili = []; List<LegnoItem> legni = []; List<PannelloItem> pannelli = [];
  double extraFerramenta = 0; double extraLaccatura = 0;
  double scartoLegniPercent = 15; double scartoPannelliPercent = 10;
  double oreManodopera = 0; double costoOra = 35;
  double levigaturaMq = 0; double costoLevigaturaMq = 8;
  String finituraTipo = 'Olio'; double costoFinitura = 0;
  String verniciaturaTipo = 'Vernice trasparente'; int maniVernice = 2; double costoVerniciaturaMq = 12; double mqVerniciatura = 0;
  double marginePercent = 30; double ivaPercent = 22;
  int validitaGiorni = 15;
  String clausolaMercato = "I prezzi dei materiali (legni e pannelli) sono soggetti a variazione in base all'andamento del mercato.";

  double get totMqMobili => mobili.fold(0, (s,e)=> s + e.mq * e.qta);
  double get totMlMobili => mobili.fold(0, (s,e)=> s + e.ml * e.qta);
  double get totLegniNetto => legni.fold(0, (s,e)=> s + e.totale);
  double get totPannelliNetto => pannelli.fold(0, (s,e)=> s + e.totale);
  double get totManodopera => oreManodopera * costoOra;
  double get totLevigatura => levigaturaMq * costoLevigaturaMq;
  double get totVerniciatura => mqVerniciatura * costoVerniciaturaMq * maniVernice;
  double get scartoLegniVal => totLegniNetto * scartoLegniPercent / 100;
  double get scartoPannelliVal => totPannelliNetto * scartoPannelliPercent / 100;
  double get totLegni => totLegniNetto + scartoLegniVal;
  double get totPannelli => totPannelliNetto + scartoPannelliVal;
  double get imponibile => totLegni + totPannelli + extraFerramenta + extraLaccatura + totManodopera + totLevigatura + costoFinitura + totVerniciatura;
  double get utile => imponibile * marginePercent / 100;
  double get totaleImponibile => imponibile + utile;
  double get iva => totaleImponibile * ivaPercent / 100;
  double get totaleIvato => totaleImponibile + iva;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preventivo v4.5 - Validità $validitaGiorni gg'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.fromLTRB(12,12,12,120), children: [
        _cardMiaDitta(), const SizedBox(height:12),
        _cardCliente(), const SizedBox(height:12),
        _cardMobili(), const SizedBox(height:12),
        _cardLegni(), const SizedBox(height:12),
        _cardPannelli(), const SizedBox(height:12),
        _cardLavorazioni(), const SizedBox(height:12),
        _cardTotali(), const SizedBox(height:12),
        _cardNoteLegali(), const SizedBox(height:90)
      ]),
      bottomNavigationBar: Padding(padding: const EdgeInsets.all(12), child: ElevatedButton.icon(onPressed: ()=> _showRiepilogoPdf(), icon: const Icon(Icons.picture_as_pdf), label: const Text('Vedi PDF Completo'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18), backgroundColor: Colors.brown, foregroundColor: Colors.white))),
    );
  }

  Widget _cardMiaDitta(){ return Card(color: Colors.brown.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [Icon(Icons.store), SizedBox(width:8), Text('LA MIA DITTA', style: TextStyle(fontWeight: FontWeight.bold))]),
    TextField(decoration: const InputDecoration(labelText: 'Ragione Sociale'), onChanged: (v)=> setState(()=> miaRagione=v)),
    TextField(decoration: const InputDecoration(labelText: 'Via'), onChanged: (v)=> setState(()=> miaVia=v)),
    Row(children: [Expanded(flex:2, child: TextField(decoration: const InputDecoration(labelText: 'Città'), onChanged: (v)=> setState(()=> miaCitta=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Prov.'), onChanged: (v)=> setState(()=> miaProv=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'CAP'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> miaCap=v)))]),
    Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Telefono'), keyboardType: TextInputType.phone, onChanged: (v)=> setState(()=> mioTel=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'P.IVA'), onChanged: (v)=> setState(()=> miaPiva=v)))]),
  ])));}

  Widget _cardCliente(){ return Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [Icon(Icons.person), SizedBox(width:8), Text('CLIENTE', style: TextStyle(fontWeight: FontWeight.bold))]),
    TextField(decoration: const InputDecoration(labelText: 'Cliente / Ragione Sociale'), onChanged: (v)=> setState(()=> cliente=v)),
    TextField(decoration: const InputDecoration(labelText: 'Via'), onChanged: (v)=> setState(()=> cliVia=v)),
    Row(children: [Expanded(flex:2, child: TextField(decoration: const InputDecoration(labelText: 'Città'), onChanged: (v)=> setState(()=> cliCitta=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Prov.'), onChanged: (v)=> setState(()=> cliProv=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'CAP'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> cliCap=v)))]),
    Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Telefono'), keyboardType: TextInputType.phone, onChanged: (v)=> setState(()=> cliTel=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'P.IVA / CF'), onChanged: (v)=> setState(()=> cliPiva=v)))]),
    Row(children: [Expanded(child: TextField(decoration: const InputDecoration(labelText: 'N° Preventivo'), onChanged: (v)=> setState(()=> numPrev=v))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Data'), onChanged: (v)=> setState(()=> dataPrev=v)))]),
  ])));}

  Widget _cardMobili(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.chair), const SizedBox(width:8), const Text('MOBILI - ml/mq/qta', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _addMobile, icon: const Icon(Icons.add))]), ...mobili.asMap().entries.map((e){ var i=e.key; var m=e.value; return ListTile(title: Text(m.nome), subtitle: Text('ml:${m.ml} mq:${m.mq} qta:${m.qta}'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> mobili.removeAt(i))));}), Text('Totale: ${totMlMobili.toStringAsFixed(1)} ml | ${totMqMobili.toStringAsFixed(2)} mq', style: const TextStyle(fontWeight: FontWeight.bold))]))); }

  Widget _cardLegni(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.forest), const SizedBox(width:8), const Text('LEGNI + SCARTO + SLIDER REGIONE', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)), const Spacer(), IconButton(onPressed: _addLegno, icon: const Icon(Icons.add))]), Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Scarto legni %', hintText: '$scartoLegniPercent'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> scartoLegniPercent = double.tryParse(v)??15))), const SizedBox(width:8), Text('Scarto: +${scartoLegniVal.toStringAsFixed(2)}€', style: const TextStyle(color: Colors.orange))]), ...legni.asMap().entries.map((en){ var i=en.key; var l=en.value; return Card(color: Colors.green.shade50, child: ListTile(title: Text('${l.tipo} ${l.spessore}mm - ${l.mq}mq'), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Base ${l.prezzoBase}€ + Regione ${l.extraRegione.toStringAsFixed(0)}€ = ${l.prezzoMq.toStringAsFixed(0)}€/mq'), Slider(min: 0, max: 35, divisions: 35, label: '+${l.extraRegione.toStringAsFixed(0)}€', value: l.extraRegione, onChanged: (v)=> setState(()=> l.extraRegione=v)), Text('Totale: ${l.totale.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> legni.removeAt(i)))));}), Text('Netto: ${totLegniNetto.toStringAsFixed(2)}€ + ${scartoLegniPercent}% = ${totLegni.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]))); }

  Widget _cardPannelli(){ return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.layers), const SizedBox(width:8), const Text('PANNELLI + SLIDER REGIONE', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)), const Spacer(), IconButton(onPressed: _addPannello, icon: const Icon(Icons.add))]), Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Scarto pannelli %', hintText: '$scartoPannelliPercent'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> scartoPannelliPercent = double.tryParse(v)??10))), const SizedBox(width:8), Text('Scarto: +${scartoPannelliVal.toStringAsFixed(2)}€', style: const TextStyle(color: Colors.orange))]), ...pannelli.asMap().entries.map((en){ var i=en.key; var p=en.value; return Card(color: Colors.blue.shade50, child: ListTile(title: Text('${p.tipo} ${p.spessore}mm x${p.qta}'), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Base ${p.prezzoBase}€ + Regione ${p.extraRegione.toStringAsFixed(0)}€ = ${p.prezzoPannello.toStringAsFixed(0)}€'), Slider(min: 0, max: 35, divisions: 35, label: '+${p.extraRegione.toStringAsFixed(0)}€', value: p.extraRegione, onChanged: (v)=> setState(()=> p.extraRegione=v)), Text('Totale: ${p.totale.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> setState(()=> pannelli.removeAt(i)))));}), Text('Netto: ${totPannelliNetto.toStringAsFixed(2)}€ + ${scartoPannelliPercent}% = ${totPannelli.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold))]))); }

  Widget _cardLavorazioni(){ return Card(color: Colors.orange.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [Icon(Icons.construction), SizedBox(width:8), Text('MANODOPERA - LEVIGATURA - FINITURA - VERNICIATURA', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))]),
    const Divider(),
    Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Ore', hintText: '$oreManodopera'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> oreManodopera = double.tryParse(v)??0))), const SizedBox(width:8), Expanded(child: TextField(decoration: InputDecoration(labelText: '€/ora', hintText: '$costoOra'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> costoOra = double.tryParse(v)??35))), const SizedBox(width:8), Text('${totManodopera.toStringAsFixed(0)}€', style: const TextStyle(fontWeight: FontWeight.bold))]),
    Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Mq levigare'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> levigaturaMq = double.tryParse(v)??0))), const SizedBox(width:8), Expanded(child: TextField(decoration: InputDecoration(labelText: '€/mq'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> costoLevigaturaMq = double.tryParse(v)??8))), const SizedBox(width:8), Text('${totLevigatura.toStringAsFixed(0)}€', style: const TextStyle(fontWeight: FontWeight.bold))]),
    Row(children: [Expanded(child: DropdownButton<String>(value: finituraTipo, isExpanded: true, items: ['Olio','Olio duro','Cera','Olio + Cera','Sbiancatura','Spazzolatura'].map((e)=> DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=> setState(()=> finituraTipo=v!))), const SizedBox(width:8), Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Costo €'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> costoFinitura = double.tryParse(v)??0)))]),
    Row(children: [Expanded(child: DropdownButton<String>(value: verniciaturaTipo, isExpanded: true, items: ['Vernice trasparente','Vernice opaca','Laccatura lucida','Laccatura opaca','Laccatura RAL','Impregnante'].map((e)=> DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=> setState(()=> verniciaturaTipo=v!)))]),
    Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'Mq'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> mqVerniciatura = double.tryParse(v)??0))), const SizedBox(width:8), Expanded(child: TextField(decoration: InputDecoration(labelText: 'Mani'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> maniVernice = int.tryParse(v)??2))), const SizedBox(width:8), Expanded(child: TextField(decoration: InputDecoration(labelText: '€/mq'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> costoVerniciaturaMq = double.tryParse(v)??12)))]),
    Text('Totale verniciatura: ${totVerniciatura.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)),
  ]))); }

  Widget _cardTotali(){ return Card(color: Colors.brown.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
    TextField(decoration: const InputDecoration(labelText: 'Extra ferramenta €'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> extraFerramenta = double.tryParse(v)??0)),
    TextField(decoration: const InputDecoration(labelText: 'Extra laccatura/trasporto €'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> extraLaccatura = double.tryParse(v)??0)),
    TextField(decoration: InputDecoration(labelText: 'Margine % (default $marginePercent)'), keyboardType: TextInputType.number, onChanged: (v)=> setState(()=> marginePercent = double.tryParse(v)??30)),
    const Divider(),
    _rowTot('Legni netto', totLegniNetto),
    _rowTot('Scarto legni ${scartoLegniPercent}%', scartoLegniVal),
    _rowTot('Pannelli netto', totPannelliNetto),
    _rowTot('Scarto pannelli ${scartoPannelliPercent}%', scartoPannelliVal),
    _rowTot('Manodopera $oreManodopera h', totManodopera),
    _rowTot('Levigatura', totLevigatura),
    _rowTot('Finitura $finituraTipo', costoFinitura),
    _rowTot('Verniciatura x$maniVernice', totVerniciatura),
    _rowTot('Materiale + lavorazioni', imponibile),
    _rowTot('Utile $marginePercent%', utile),
    _rowTot('IMPONIBILE', totaleImponibile, bold:true),
    _rowTot('IVA $ivaPercent%', iva),
    _rowTot('TOTALE IVATO', totaleIvato, bold:true, big:true),
  ]))); }

  Widget _cardNoteLegali(){
    return Card(color: Colors.grey.shade200, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.gavel), SizedBox(width:8), Text('NOTE LEGALI - VALIDITÀ', style: TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height:12),
      DropdownButton<int>(
        value: validitaGiorni, isExpanded: true,
        items: [15,30].map((g)=> DropdownMenuItem(value:g, child: Text('Validità preventivo: $g giorni'))).toList(),
        onChanged: (v)=> setState(()=> validitaGiorni=v!),
      ),
      const SizedBox(height:8),
      TextField(
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Dicitura variazione mercato', border: OutlineInputBorder()),
        controller: TextEditingController(text: clausolaMercato),
        onChanged: (v)=> setState(()=> clausolaMercato=v),
      ),
      const SizedBox(height:12),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, border: Border.all()), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ANTEPRIMA NEL PDF:', style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)),
        SizedBox(height:6),
        Text('$clausolaMercato', style: TextStyle(fontSize:11, fontStyle: FontStyle.italic)),
        SizedBox(height:6),
        Text('Il presente preventivo ha validità di $validitaGiorni giorni dalla data di emissione. Oltre tale termine i prezzi potranno subire variazioni.', style: TextStyle(fontSize:11, fontWeight: FontWeight.bold)),
      ])),
    ])));
  }

  Widget _rowTot(String l, double v, {bool bold=false, bool big=false}){ return Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal, fontSize: big?16:12)), Text('${v.toStringAsFixed(2)}€', style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal, fontSize: big?16:12))])); }

  void _addMobile(){ showDialog(context: context, builder: (c){ var nome='Mobile'; double ml=0,mq=0; int qta=1; return AlertDialog(title: const Text('Aggiungi Mobile'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(onChanged: (v)=> nome=v, decoration: const InputDecoration(labelText: 'Nome')), TextField(onChanged: (v)=> ml=double.tryParse(v)??0, decoration: const InputDecoration(labelText: 'ml'), keyboardType: TextInputType.number), TextField(onChanged: (v)=> mq=double.tryParse(v)??0, decoration: const InputDecoration(labelText: 'mq'), keyboardType: TextInputType.number), TextField(onChanged: (v)=> qta=int.tryParse(v)??1, decoration: const InputDecoration(labelText: 'qta'), keyboardType: TextInputType.number)]), actions: [TextButton(onPressed: (){ setState(()=> mobili.add(MobileItem(nome:nome, ml:ml, mq:mq, qta:qta))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);}); }
  void _addLegno(){ String tipo = PriceList.legni.keys.first; int spessore = PriceList.legni[tipo]!.keys.first; double mq = 0; showDialog(context: context, builder: (c){ return StatefulBuilder(builder: (c2,setD){ double prezzo = PriceList.legni[tipo]![spessore]??0; return AlertDialog(title: const Text('Aggiungi Legno'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(value: tipo, isExpanded: true, items: PriceList.legni.keys.map((k)=> DropdownMenuItem(value:k, child: Text(k))).toList(), onChanged: (v){ setD(()=> tipo=v!); spessore = PriceList.legni[tipo]!.keys.first; }), DropdownButton<int>(value: spessore, isExpanded: true, items: PriceList.legni[tipo]!.keys.map((s)=> DropdownMenuItem(value:s, child: Text('$s mm - ${PriceList.legni[tipo]![s]}€/mq'))).toList(), onChanged: (v)=> setD(()=> spessore=v!)), TextField(decoration: const InputDecoration(labelText: 'MQ'), keyboardType: TextInputType.number, onChanged: (v)=> mq=double.tryParse(v)??0)]), actions: [TextButton(onPressed: (){ setState(()=> legni.add(LegnoItem(tipo:tipo, spessore:spessore, mq:mq, prezzoBase:prezzo))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);});}); }
  void _addPannello(){ String tipo = PriceList.pannelli.keys.first; int spessore = PriceList.pannelli[tipo]!.keys.first; int qta=1; showDialog(context: context, builder: (c){ return StatefulBuilder(builder: (c2,setD){ double prezzo = PriceList.pannelli[tipo]![spessore]??0; return AlertDialog(title: const Text('Aggiungi Pannello'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(value: tipo, isExpanded: true, items: PriceList.pannelli.keys.map((k)=> DropdownMenuItem(value:k, child: Text(k, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v){ setD(()=> tipo=v!); spessore = PriceList.pannelli[tipo]!.keys.first; }), DropdownButton<int>(value: spessore, isExpanded: true, items: PriceList.pannelli[tipo]!.keys.map((s)=> DropdownMenuItem(value:s, child: Text('$s mm - ${PriceList.pannelli[tipo]![s]}€'))).toList(), onChanged: (v)=> setD(()=> spessore=v!)), TextField(decoration: const InputDecoration(labelText: 'Qta pannelli'), keyboardType: TextInputType.number, onChanged: (v)=> qta=int.tryParse(v)??1)]), actions: [TextButton(onPressed: (){ setState(()=> pannelli.add(PannelloItem(tipo:tipo, spessore:spessore, qta:qta, prezzoBase:prezzo))); Navigator.pop(c);}, child: const Text('Aggiungi'))]);});}); }

  void _showRiepilogoPdf(){ showDialog(context: context, builder: (c)=> AlertDialog(title: Text('Preventivo $numPrev - ${totaleIvato.toStringAsFixed(2)}€'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('DA: $miaRagione - $miaVia, $miaCap $miaCitta ($miaProv) Tel:$mioTel PIVA:$miaPiva', style: const TextStyle(fontSize:11)),
    const Divider(),
    Text('A: $cliente - $cliVia, $cliCap $cliCitta ($cliProv) Tel:$cliTel PIVA:$cliPiva', style: const TextStyle(fontSize:11)),
    Text('Data: $dataPrev - N° $numPrev', style: const TextStyle(fontSize:11)),
    const Divider(),
    Text('TOTALE IVATO: ${totaleIvato.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:18)),
    const Divider(thickness:2),
    Text('NOTE LEGALI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)),
    SizedBox(height:4),
    Text(clausolaMercato, style: TextStyle(fontSize:10, fontStyle: FontStyle.italic)),
    SizedBox(height:8),
    Text('Validità: $validitaGiorni giorni dalla data di emissione ($dataPrev). Oltre tale termine i prezzi sono soggetti a variazione.', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold)),
  ])), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Chiudi'))])); }
}
