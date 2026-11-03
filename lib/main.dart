<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Falegnameria di Bart - v4.8 FIX INVIO</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<style>
:root{--green:#16a34a;--dark:#1f2937;--bg:#f8fafc}
*{box-sizing:border-box;font-family:system-ui,Segoe UI,Roboto}
body{margin:0;background:var(--bg);color:var(--dark);padding:12px;padding-bottom:80px}
h1{margin:0 0 4px;font-size:22px}
h2{margin:14px 0 8px;font-size:17px;border-left:4px solid var(--green);padding-left:8px}
.card{background:#fff;border-radius:12px;padding:12px;margin-bottom:12px;box-shadow:0 2px 8px rgba(0,0,0,.06)}
input,select{width:100%;padding:10px;border:1px solid #d1d5db;border-radius:8px;margin:4px 0;font-size:14px}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:8px}
.grid4{display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:6px}
.btn{padding:12px 16px;border:0;border-radius:10px;font-weight:700;cursor:pointer;width:100%;font-size:15px}
.btn-green{background:var(--green);color:#fff}
.btn-dark{background:var(--dark);color:#fff;margin-top:6px}
.btn-red{background:#ef4444;color:#fff;margin-top:6px}
.small{font-size:12px;color:#6b7280}
.badge{display:inline-block;background:#dcfce7;color:#166534;padding:2px 8px;border-radius:99px;font-size:12px;font-weight:700}
.manufatto{border:1px solid #e5e7eb;border-radius:10px;padding:10px;margin-bottom:10px;background:#f9fafb}
.riga-tot{display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid #f3f4f6}
.riga-tot b{font-size:15px}
</style>
</head>
<body>
<h1>🪵 Falegnameria di Bart <span class="badge">v4.8 FIX INVIO €</span></h1>
<div class="small">Fix: anteprima con € - PDF inviato con EUR (non scompare)</div>

<div class="card">
<h2>Dati Cliente</h2>
<div class="grid2">
<input id="clienteNome" placeholder="Nome cliente (es: Miguelina)">
<input id="clienteTel" placeholder="Tel">
</div>
<input id="clienteLuogo" placeholder="Luogo (es: Cerreto)">
</div>

<div class="card">
<h2>Manufatti - TUTTO L/l/H/P mm + mq auto</h2>
<div id="manufattiList"></div>
<button class="btn btn-dark" onclick="addManufatto()">+ Aggiungi Manufatto</button>
</div>

<div class="card">
<h2>Legni - Essenze</h2>
<div class="grid2">
<select id="essenza">
<option value="Noce Nazionale|100|5">Noce Nazionale 100/mq +5</option>
<option value="Rovere|90|5">Rovere 90/mq +5</option>
<option value="Frassino|80|5">Frassino 80/mq +5</option>
<option value="Lamellare Abete|38|6">Lamellare Abete 38+6</option>
</select>
<input id="legnoMq" type="number" step="0.01" placeholder="mq es: 30">
</div>
<div class="grid2">
<div><span class="small">Spessore mm</span><input id="spessoreLegno" type="number" value="10"></div>
<div style="display:flex;align-items:end"><button class="btn btn-dark" onclick="addLegno()">+ Legno</button></div>
</div>
<div id="legniList" class="small" style="margin-top:8px"></div>
</div>

<div class="card">
<h2>Pannelli</h2>
<div class="grid2">
<select id="pannello">
<option value="Lamellare Abete|38|6">Lamellare Abete 38+6</option>
<option value="Multistrato Pioppo|35|5">Multistrato Pioppo 35+5</option>
</select>
<input id="pannelloQta" type="number" value="5">
</div>
<button class="btn btn-dark" onclick="addPannello()">+ Pannello</button>
<div id="pannelliList" class="small" style="margin-top:8px"></div>
</div>

<div class="card">
<h2>Costi & Margini</h2>
<label class="small">Utile / Margine % (default 30.0) - È una PERCENTUALE di guadagno</label>
<div class="grid2">
<input id="margin" type="number" value="30" placeholder="Utile % default 30">
<input id="iva" type="number" value="22" placeholder="IVA %">
<input id="scartoLegni" type="number" value="15" placeholder="Scarto legni %">
<input id="scartoPannelli" type="number" value="10" placeholder="Scarto pannelli %">
<input id="manodoperaH" type="number" value="15" placeholder="Manodopera h">
<input id="manodoperaPrezzo" type="number" value="35" placeholder="EUR/h">
<input id="levigatura" type="number" value="300" placeholder="Levigatura">
<input id="finitura" type="number" value="55" placeholder="Finitura Cera">
<input id="extraLacc" type="number" value="0" placeholder="Extra laccatura/trasporto">
<input id="verniciatura" type="number" value="3300" placeholder="Verniciatura x2">
</div>
</div>

<div class="card">
<div id="anteprima"></div>
<button class="btn btn-green" onclick="generaPDF()">📄 GENERA PDF + SALVA + CONDIVIDI</button>
<div class="small" style="margin-top:6px">Il PDF userà EUR per non far sparire il simbolo quando invii su WhatsApp</div>
</div>

<script>
let manufatti=[], legni=[], pannelli=[];
// ANTEPRIMA con € - bello da vedere
const fmtUI = n => `${Number(n).toFixed(2)}€`;
// PDF con EUR - non scompare mai quando invii
const fmtPDF = n => `EUR ${Number(n).toFixed(2)}`;

function addManufatto(){
  manufatti.push({id:Date.now(), nome:'Tavolo', L:1000, l:600, H:800, P:400, qta:1, mq:0});
  renderManufatti();
}
function renderManufatti(){
  const c=document.getElementById('manufattiList');
  c.innerHTML='';
  manufatti.forEach((m,i)=>{
    m.mq = (m.L/1000)*(m.H/1000)*m.qta;
    c.innerHTML+=`
    <div class="manufatto">
      <input value="${m.nome}" oninput="manufatti[${i}].nome=this.value" placeholder="Descrizione">
      <div class="grid4">
        <div><span class="small">L mm</span><input type="number" value="${m.L}" oninput="manufatti[${i}].L=parseFloat(this.value)||0;renderManufatti()"></div>
        <div><span class="small">l mm</span><input type="number" value="${m.l}" oninput="manufatti[${i}].l=parseFloat(this.value)||0;renderManufatti()"></div>
        <div><span class="small">H mm</span><input type="number" value="${m.H}" oninput="manufatti[${i}].H=parseFloat(this.value)||0;renderManufatti()"></div>
        <div><span class="small">P mm</span><input type="number" value="${m.P}" oninput="manufatti[${i}].P=parseFloat(this.value)||0"></div>
      </div>
      <div class="grid2"><div><span class="small">Qta</span><input type="number" value="${m.qta}" oninput="manufatti[${i}].qta=parseFloat(this.value)||1;renderManufatti()"></div><div><span class="small">mq auto</span><input value="${m.mq.toFixed(3)} mq" disabled></div></div>
      <button class="btn btn-red" onclick="manufatti.splice(${i},1);renderManufatti();aggiornaAnteprima()">Elimina</button>
    </div>`;
  });
  aggiornaAnteprima();
}
function addLegno(){
  const [nome,prezzo,extra]=document.getElementById('essenza').value.split('|');
  const mq=parseFloat(document.getElementById('legnoMq').value)||0;
  const sp=parseFloat(document.getElementById('spessoreLegno').value)||10;
  if(mq<=0)return;
  legni.push({nome,prezzo:+prezzo,extra:+extra,mq,sp});
  document.getElementById('legnoMq').value='';
  aggiornaAnteprima();
}
function addPannello(){
  const [nome,prezzo,extra]=document.getElementById('pannello').value.split('|');
  const qta=parseFloat(document.getElementById('pannelloQta').value)||1;
  pannelli.push({nome,prezzo:+prezzo,extra:+extra,qta});
  aggiornaAnteprima();
}
function calcola(){
  let legniNetto=0; legni.forEach(l=>legniNetto+=(l.prezzo+l.extra)*l.mq);
  let pannelliNetto=0; pannelli.forEach(p=>pannelliNetto+=(p.prezzo+p.extra)*p.qta);
  const scL = legniNetto * (parseFloat(document.getElementById('scartoLegni').value)||0)/100;
  const scP = pannelliNetto * (parseFloat(document.getElementById('scartoPannelli').value)||0)/100;
  const mano = (parseFloat(document.getElementById('manodoperaH').value)||0)*(parseFloat(document.getElementById('manodoperaPrezzo').value)||0);
  const lev = parseFloat(document.getElementById('levigatura').value)||0;
  const fin = parseFloat(document.getElementById('finitura').value)||0;
  const extra = parseFloat(document.getElementById('extraLacc').value)||0;
  const vern = parseFloat(document.getElementById('verniciatura').value)||0;
  const materiale = legniNetto+scL+pannelliNetto+scP+mano+lev+fin+extra+vern;
  const marginPerc = parseFloat(document.getElementById('margin').value)||30;
  const utile = materiale * marginPerc/100;
  const imponibile = materiale + utile;
  const ivaPerc = parseFloat(document.getElementById('iva').value)||22;
  const iva = imponibile * ivaPerc/100;
  const totale = imponibile + iva;
  return {legniNetto,scL,pannelliNetto,scP,mano,lev,fin,extra,vern,materiale,utile,imponibile,iva,totale,marginPerc,ivaPerc};
}
function aggiornaAnteprima(){
  const t=calcola();
  let html='';
  html+=`<div class="riga-tot"><span>Legni netto</span><span>${fmtUI(t.legniNetto)}</span></div>`;
  html+=`<div class="riga-tot"><span>Scarto legni ${document.getElementById('scartoLegni').value}%</span><span>${fmtUI(t.scL)}</span></div>`;
  html+=`<div class="riga-tot"><span>Pannelli netto</span><span>${fmtUI(t.pannelliNetto)}</span></div>`;
  html+=`<div class="riga-tot"><span>Scarto pannelli ${document.getElementById('scartoPannelli').value}%</span><span>${fmtUI(t.scP)}</span></div>`;
  html+=`<div class="riga-tot"><span>Manodopera ${document.getElementById('manodoperaH').value} h</span><span>${fmtUI(t.mano)}</span></div>`;
  html+=`<div class="riga-tot"><span>Levigatura</span><span>${fmtUI(t.lev)}</span></div>`;
  html+=`<div class="riga-tot"><span>Finitura Cera</span><span>${fmtUI(t.fin)}</span></div>`;
  if(t.extra>0) html+=`<div class="riga-tot"><span>Extra laccatura/trasporto</span><span>${fmtUI(t.extra)}</span></div>`;
  html+=`<div class="riga-tot"><span>Verniciatura x2</span><span>${fmtUI(t.vern)}</span></div>`;
  html+=`<div class="riga-tot"><span>Materiale + lavorazioni</span><span>${fmtUI(t.materiale)}</span></div>`;
  html+=`<div class="riga-tot"><span>Utile ${t.marginPerc}%</span><span>${fmtUI(t.utile)}</span></div>`;
  html+=`<div class="riga-tot"><b>IMPONIBILE</b><b>${fmtUI(t.imponibile)}</b></div>`;
  html+=`<div class="riga-tot"><span>IVA ${t.ivaPerc}%</span><span>${fmtUI(t.iva)}</span></div>`;
  html+=`<div class="riga-tot" style="border-top:2px solid #000"><b>TOTALE IVATO</b><b>${fmtUI(t.totale)}</b></div>`;
  document.getElementById('anteprima').innerHTML=html;
  document.getElementById('legniList').innerHTML=legni.map((l,i)=>`${l.nome} ${l.mq}mq = ${fmtUI((l.prezzo+l.extra)*l.mq)} <a href="#" onclick="legni.splice(${i},1);aggiornaAnteprima();return false">[x]</a>`).join('<br>');
  document.getElementById('pannelliList').innerHTML=pannelli.map((p,i)=>`${p.nome} x${p.qta} = ${fmtUI((p.prezzo+p.extra)*p.qta)} <a href="#" onclick="pannelli.splice(${i},1);aggiornaAnteprima();return false">[x]</a>`).join('<br>');
}
function generaPDF(){
  const {jsPDF}=window.jspdf;
  const doc=new jsPDF();
  const t=calcola();
  const cliente=document.getElementById('clienteNome').value||'Cliente';
  const tel=document.getElementById('clienteTel').value||'';
  const num=`PREV-${new Date().toISOString().slice(0,10).replace(/-/g,'')}-${Math.floor(Math.random()*9000+1000)}`;
  let y=10;
  doc.setFontSize(12);
  doc.text(`PREVENTIVO ${num} - ${new Date().toISOString().slice(0,10)}`,10,y); y+=8;
  doc.setFontSize(9);
  doc.text(`DA: falegnameria di Bart - Tel:3791797758`,10,y); y+=5;
  doc.text(`A: ${cliente} Tel:${tel}`,10,y); y+=10;
  doc.setFontSize(10);
  // QUI USIAMO EUR PER L'INVIO - NON SPARISCE
  doc.text(`Legni netto`,10,y); doc.text(`${fmtPDF(t.legniNetto)}`,150,y); y+=5;
  doc.text(`Scarto legni ${document.getElementById('scartoLegni').value}%`,10,y); doc.text(`${fmtPDF(t.scL)}`,150,y); y+=5;
  doc.text(`Pannelli netto`,10,y); doc.text(`${fmtPDF(t.pannelliNetto)}`,150,y); y+=5;
  doc.text(`Scarto pannelli ${document.getElementById('scartoPannelli').value}%`,10,y); doc.text(`${fmtPDF(t.scP)}`,150,y); y+=5;
  doc.text(`Manodopera ${document.getElementById('manodoperaH').value} h`,10,y); doc.text(`${fmtPDF(t.mano)}`,150,y); y+=5;
  doc.text(`Levigatura`,10,y); doc.text(`${fmtPDF(t.lev)}`,150,y); y+=5;
  doc.text(`Finitura Cera`,10,y); doc.text(`${fmtPDF(t.fin)}`,150,y); y+=5;
  if(t.extra>0){doc.text(`Extra laccatura/trasporto`,10,y); doc.text(`${fmtPDF(t.extra)}`,150,y); y+=5;}
  doc.text(`Verniciatura x2`,10,y); doc.text(`${fmtPDF(t.vern)}`,150,y); y+=5;
  doc.text(`Materiale + lavorazioni`,10,y); doc.text(`${fmtPDF(t.materiale)}`,150,y); y+=5;
  doc.text(`Utile ${t.marginPerc}%`,10,y); doc.text(`${fmtPDF(t.utile)}`,150,y); y+=5;
  doc.setFont('helvetica','bold');
  doc.text(`IMPONIBILE`,10,y); doc.text(`${fmtPDF(t.imponibile)}`,150,y); y+=6;
  doc.setFont('helvetica','normal');
  doc.text(`IVA ${t.ivaPerc}%`,10,y); doc.text(`${fmtPDF(t.iva)}`,150,y); y+=8;
  doc.setFontSize(13); doc.setFont('helvetica','bold');
  doc.text(`TOTALE IVATO: ${fmtPDF(t.totale)}`,10,y);
  doc.save(`${num}.pdf`);
}
addManufatto();
legni.push({nome:'Noce Nazionale',prezzo:100,extra:5,mq:30,sp:10});
pannelli.push({nome:'Lamellare Abete',prezzo:38,extra:6,qta:5});
aggiornaAnteprima();
</script>
</body>
</html>
