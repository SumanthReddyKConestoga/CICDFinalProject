// Instant compute + reset + background save + reliable history refresh
const $ = (id) => document.getElementById(id);
const API_BASE = `${location.protocol}//${location.hostname}:3000`;
const api = (path, opts) => fetch(`${API_BASE}${path}`, opts);

let ticker = null;

/* ---- Local calculations (instant UI) ---- */
function localAge(dobISO){
  const dob = new Date(dobISO);
  const now = new Date();
  let years = now.getFullYear() - dob.getFullYear();
  let months = now.getMonth() - dob.getMonth();
  let days = now.getDate() - dob.getDate();
  if (days < 0){ days += new Date(now.getFullYear(), now.getMonth(), 0).getDate(); months--; }
  if (months < 0){ months += 12; years--; }
  const diff = now - dob;
  return {
    years, months, days,
    totalDays: Math.floor(diff/86400000),
    totalHours: Math.floor(diff/3600000),
    totalMinutes: Math.floor(diff/60000),
    totalSeconds: Math.floor(diff/1000),
  };
}
function localBmi(weightKg, heightCm){
  const w = Number(weightKg), h = Number(heightCm);
  if (!w || !h || w<=0 || h<=0) return { bmi:null, category:null };
  const m = h/100, bmi = +(w/(m*m)).toFixed(2);
  let category = bmi<18.5 ? "Underweight" : bmi<25 ? "Normal" : bmi<30 ? "Overweight" : "Obese";
  return { bmi, category };
}

/* ---- UI helpers ---- */
function renderAge(a){
  $("years").textContent = a.years;
  $("months").textContent = a.months;
  $("days").textContent = a.days;
  $("t-days").textContent = a.totalDays.toLocaleString();
  $("t-hours").textContent = a.totalHours.toLocaleString();
  $("t-mins").textContent = a.totalMinutes.toLocaleString();
  $("t-secs").textContent = a.totalSeconds.toLocaleString();
}
function setGauge(bmi, category){
  const arc = $("arc"), badge = $("badge"), bmiEl = $("bmi");
  if (!bmi){
    arc.setAttribute("stroke-dasharray","0 100");
    badge.textContent="—"; badge.className="badge"; bmiEl.textContent="—";
    $("advice").textContent="Enter height & weight for insights tailored to your age.";
    return;
  }
  const pct = Math.max(0, Math.min(100, ((bmi - 10) / 30) * 100));
  arc.setAttribute("stroke-dasharray", `${pct} ${100 - pct}`);
  bmiEl.textContent = Number(bmi).toFixed(2);
  let cls = "badge";
  if (category === "Underweight") cls += " under";
  else if (category === "Normal") cls += " ok";
  else if (category === "Overweight") cls += " over";
  else cls += " obese";
  badge.className = cls; badge.textContent = category;
  const y = Number($("years").textContent) || 0;
  $("advice").textContent =
    category === "Normal" ? `Balanced. Maintain the momentum. Age ${y}.` :
    category === "Underweight" ? `Add nutrient-dense foods & strength work. Age ${y}.` :
    category === "Overweight" ? `Move more; manage portions. Age ${y}.` :
    `Consider a professional plan. Age ${y}.`;
}
function startTicker(dobISO){
  clearInterval(ticker);
  ticker = setInterval(()=> renderAge(localAge(dobISO)), 1000);
}

/* ---- History ---- */
async function loadHistory(){
  try{
    const r = await api("/api/calc");
    const rows = await r.json();
    const tbody = document.querySelector("#history tbody");
    tbody.innerHTML = rows.map(x=>`
      <tr>
        <td>${x.name}</td><td>${String(x.dob).substring(0,10)}</td>
        <td>${x.years}</td><td>${x.months}</td><td>${x.days}</td>
        <td>${x.height_cm ?? ""}</td><td>${x.weight_kg ?? ""}</td>
        <td>${x.bmi ?? ""}</td><td>${x.bmi_category ?? ""}</td>
        <td>${new Date(x.calculated_at).toLocaleString()}</td>
      </tr>`).join("");
    return rows;
  }catch(e){ return []; }
}

/* ---- Helper: refresh history a few times to catch async DB write ---- */
function refreshHistoryProgressively() {
  [0, 300, 1200, 3000].forEach(ms => setTimeout(loadHistory, ms));
}

/* ---- Submit (instant UI, background save) ---- */
$("calc-form").addEventListener("submit", async (e)=>{
  e.preventDefault();
  const name = $("name").value.trim() || "Guest";
  const dob = $("dob").value;
  const height = Number($("height").value);
  const weight = Number($("weight").value);
  $("msg").textContent = "";

  if (!dob){ $("msg").textContent = "Pick a valid date of birth."; return; }

  // 1) Instant local results
  const a = localAge(dob);
  const { bmi, category } = localBmi(weight, height);
  renderAge(a);
  setGauge(bmi, category);
  startTicker(dob);

  // 2) Background save, then progressive refresh
  try{
    const res = await api("/api/calc", {
      method:"POST",
      headers:{ "Content-Type":"application/json" },
      body: JSON.stringify({ name, dob, heightCm: height || null, weightKg: weight || null })
    });
    if (!res.ok) {
      const j = await res.json().catch(()=> ({}));
      $("msg").textContent = j.error || "Saved locally; DB not ready.";
    }
    refreshHistoryProgressively();
  }catch{
    $("msg").textContent = "Saved locally; API unreachable.";
  }
});

/* ---- Reset ---- */
$("reset").addEventListener("click", ()=>{
  clearInterval(ticker);
  $("name").value = "";
  $("dob").value = "";
  $("height").value = "";
  $("weight").value = "";
  $("msg").textContent = "";
  renderAge({ years:"—", months:"—", days:"—", totalDays:"—", totalHours:"—", totalMinutes:"—", totalSeconds:"—" });
  setGauge(null, null);
  $("name").focus();
});

/* init */
renderAge({ years:"—", months:"—", days:"—", totalDays:"—", totalHours:"—", totalMinutes:"—", totalSeconds:"—" });
loadHistory();
