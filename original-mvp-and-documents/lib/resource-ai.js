// AgroEdge Resource Intelligence — rule-based engine for water + electricity.
// Mirrors the logic a Claude-powered backend would apply, so the app works
// offline and the API route can fall back to it.

export const weatherForecast = [
  { day: "Wed", date: "Jun 10", tempC: 34, rainMm: 0, rainProb: 5, et0: 6.1 },
  { day: "Thu", date: "Jun 11", tempC: 35, rainMm: 0, rainProb: 10, et0: 6.4 },
  { day: "Fri", date: "Jun 12", tempC: 33, rainMm: 4, rainProb: 45, et0: 5.6 },
  { day: "Sat", date: "Jun 13", tempC: 30, rainMm: 18, rainProb: 80, et0: 4.2 },
  { day: "Sun", date: "Jun 14", tempC: 31, rainMm: 6, rainProb: 55, et0: 4.8 },
];

export const blocks = [
  { id: "A", crop: "Maize", stage: "Post-harvest", moisture: 48, targetMin: 30 },
  { id: "B", crop: "Sorghum", stage: "Grain fill", moisture: 31, targetMin: 35 },
  { id: "C", crop: "Cassava", stage: "Vegetative", moisture: 44, targetMin: 32 },
];

export const tariff = {
  currency: "₦/kWh",
  offPeak: { window: "21:00 – 05:00", rate: 38 },
  standard: { window: "05:00 – 17:00", rate: 68 },
  peak: { window: "17:00 – 21:00", rate: 112 },
  gridRiskWindow: "12:00 – 16:00",
  dieselPerKwh: 210,
};

export const pump = { kw: 5.5, flowLph: 14000 };

// Hourly plan score: lower evaporation + cheaper power + grid stability = better.
export function irrigationWindows() {
  return [
    { window: "04:00 – 06:30", score: 96, why: "Coolest hours, lowest evaporation, off-peak tariff until 05:00, stable grid.", tone: "best" },
    { window: "21:30 – 23:30", score: 88, why: "Off-peak tariff, low evaporation. Slightly higher fungal risk on leaves overnight — prefer drip lines.", tone: "good" },
    { window: "12:00 – 16:00", score: 22, why: "Avoid. Peak evaporation (~35% water loss), grid instability forecast, diesel backup at ₦210/kWh.", tone: "avoid" },
  ];
}

export function waterPlan() {
  const need = blocks
    .filter((b) => b.moisture < b.targetMin)
    .map((b) => {
      const deficitPct = b.targetMin - b.moisture;
      const litres = Math.round(deficitPct * 1800); // ~1,800 L per moisture point for this block size
      const hours = +(litres / pump.flowLph).toFixed(1);
      return { ...b, deficitPct, litres, hours };
    });
  const totalLitres = need.reduce((s, b) => s + b.litres, 0);
  const totalHours = +(totalLitres / pump.flowLph).toFixed(1);
  // Sat rain ≥ 15mm → skip the next cycle
  const rainSkip = weatherForecast.find((d) => d.rainMm >= 15);
  return { need, totalLitres, totalHours, rainSkip };
}

export function energyPlan() {
  const { totalHours } = waterPlan();
  const kwh = +(totalHours * pump.kw).toFixed(1);
  const costOffPeak = Math.round(kwh * tariff.offPeak.rate);
  const costStandard = Math.round(kwh * tariff.standard.rate);
  const costPeak = Math.round(kwh * tariff.peak.rate);
  return {
    kwh,
    costOffPeak,
    costStandard,
    costPeak,
    saveVsPeak: costPeak - costOffPeak,
    saveVsStandard: costStandard - costOffPeak,
  };
}

export const weekUsage = [
  { d: "Thu", water: 36, kwh: 14 },
  { d: "Fri", water: 41, kwh: 16 },
  { d: "Sat", water: 0, kwh: 2 },
  { d: "Sun", water: 28, kwh: 11 },
  { d: "Mon", water: 33, kwh: 13 },
  { d: "Tue", water: 39, kwh: 15 },
  { d: "Wed", water: 13, kwh: 5 },
];

export function resourceInsights() {
  const w = waterPlan();
  const e = energyPlan();
  const out = [
    {
      tag: "Irrigation timing",
      text: `Irrigate Block B (Sorghum, grain fill) tonight between 04:00–06:30 for ${w.need[0]?.hours ?? 0} hours (~${w.need[0]?.litres?.toLocaleString() ?? 0} L). Soil moisture is ${blocks[1].moisture}%, below the ${blocks[1].targetMin}% target for this stage.`,
    },
    {
      tag: "Electricity",
      text: `Running tonight's full cycle off-peak (21:00–05:00 at ₦${tariff.offPeak.rate}/kWh) instead of peak hours saves about ₦${e.saveVsPeak.toLocaleString()} on ${e.kwh} kWh of pumping.`,
    },
    {
      tag: "Water saving",
      text: `Rain of ~18 mm is forecast Saturday (80% probability). Skip Saturday's irrigation cycle to save roughly ${(18 * 1000).toLocaleString()} L equivalent and one full pump run.`,
    },
    {
      tag: "Grid alert",
      text: `Grid instability is expected ${tariff.gridRiskWindow} today. Avoid pumping in this window — diesel backup costs ₦${tariff.dieselPerKwh}/kWh, about 5.5× the off-peak grid rate.`,
    },
    {
      tag: "Efficiency",
      text: "Midday irrigation loses up to 35% of water to evaporation at 34°C. Shifting all cycles to pre-dawn hours this season could cut total water use by ~20%.",
    },
  ];
  return out;
}
