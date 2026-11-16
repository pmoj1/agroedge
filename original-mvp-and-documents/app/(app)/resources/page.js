"use client";
import { useState } from "react";
import { StatCard, Section, InsightRow } from "@/components/ui";
import { DualLine } from "@/components/charts";
import {
  weatherForecast, blocks, tariff, pump, irrigationWindows, waterPlan, energyPlan, weekUsage, resourceInsights,
} from "@/lib/resource-ai";

const windowTone = {
  best: "border-leaf bg-leaf-soft",
  good: "border-line bg-white",
  avoid: "border-red-200 bg-red-50",
};

export default function Resources() {
  const w = waterPlan();
  const e = energyPlan();
  const [insights, setInsights] = useState(resourceInsights());
  const [loading, setLoading] = useState(false);

  async function refresh() {
    setLoading(true);
    try {
      const res = await fetch("/api/assistant", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ mode: "resources" }),
      });
      const data = await res.json();
      if (Array.isArray(data.insights)) setInsights(data.insights);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Water & Energy</h1>
          <p className="text-sm text-sub">AI-planned irrigation timing and pump scheduling for the cheapest, most efficient farm day.</p>
        </div>
        <button onClick={refresh} disabled={loading} className="btn-green disabled:opacity-60">
          {loading ? "Analysing your farm…" : "Run AI analysis"}
        </button>
      </div>

      <div className="grid sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon="💧" label="Water needed tonight" value={w.totalLitres.toLocaleString() + " L"} sub={`${w.totalHours} hrs of pumping at ${pump.flowLph.toLocaleString()} L/h`} />
        <StatCard icon="⚡" label="Energy for tonight's cycle" value={e.kwh + " kWh"} sub={`${pump.kw} kW pump`} />
        <StatCard icon="₦" label="Cost if run off-peak" value={"₦" + e.costOffPeak.toLocaleString()} sub={`vs ₦${e.costPeak.toLocaleString()} at peak hours`} valueClass="text-leaf" />
        <StatCard icon="💰" label="Saved by smart timing" value={"₦" + e.saveVsPeak.toLocaleString()} sub="Per full irrigation cycle" valueClass="text-leaf" />
      </div>

      <Section title="Best time to irrigate today" pill="AI recommended" pillTone="green">
        <div className="grid lg:grid-cols-3 gap-3">
          {irrigationWindows().map((win) => (
            <div key={win.window} className={`rounded-xl border p-4 ${windowTone[win.tone]}`}>
              <div className="flex items-center justify-between">
                <p className="font-display font-semibold">{win.window}</p>
                <span className={win.tone === "avoid" ? "pill bg-red-600 text-white" : win.tone === "best" ? "pill-green" : "pill-soft-green"}>
                  {win.tone === "best" ? "Best window" : win.tone === "good" ? "Good" : "Avoid"} · {win.score}
                </span>
              </div>
              <p className="mt-2 text-[13px] leading-relaxed text-ink/80">{win.why}</p>
            </div>
          ))}
        </div>
      </Section>

      <div className="grid lg:grid-cols-2 gap-4">
        <Section title="Soil moisture by block" pill="Live sensors">
          <div className="space-y-3">
            {blocks.map((b) => {
              const low = b.moisture < b.targetMin;
              return (
                <div key={b.id} className="rounded-lg border border-line p-3">
                  <div className="flex items-center justify-between text-sm">
                    <p className="font-medium">Block {b.id} · {b.crop} <span className="text-sub text-xs">({b.stage})</span></p>
                    <span className={low ? "pill-gold" : "pill-soft-green"}>{b.moisture}%</span>
                  </div>
                  <div className="mt-2 h-2 rounded-full bg-canvas overflow-hidden">
                    <div className={`h-full rounded-full ${low ? "bg-gold" : "bg-leaf"}`} style={{ width: b.moisture + "%" }} />
                  </div>
                  <p className="mt-1 text-[11px] text-sub">Target minimum {b.targetMin}% for this growth stage{low ? " — irrigation queued tonight." : "."}</p>
                </div>
              );
            })}
          </div>
        </Section>

        <Section title="5-day weather outlook" pill="Drives the plan">
          <div className="grid grid-cols-5 gap-2">
            {weatherForecast.map((d) => (
              <div key={d.day} className="rounded-lg border border-line p-2 text-center">
                <p className="text-xs font-semibold">{d.day}</p>
                <p className="text-[10px] text-sub">{d.date}</p>
                <p className="mt-1 text-lg">{d.rainMm >= 15 ? "🌧️" : d.rainMm > 0 ? "🌦️" : "☀️"}</p>
                <p className="text-xs font-medium">{d.tempC}°C</p>
                <p className="text-[10px] text-water">{d.rainProb}% rain</p>
              </div>
            ))}
          </div>
          {w.rainSkip && (
            <p className="mt-3 rounded-lg bg-water-soft p-3 text-[13px] text-water">
              💧 ~{w.rainSkip.rainMm} mm of rain expected {w.rainSkip.day}. The AI plan skips that irrigation cycle automatically.
            </p>
          )}
        </Section>
      </div>

      <Section title="Pump & electricity schedule" pill="Off-peak optimised" pillTone="green">
        <div className="grid sm:grid-cols-3 gap-3 text-sm">
          <div className="rounded-lg border border-leaf bg-leaf-soft p-3">
            <p className="text-xs text-sub">Off-peak · {tariff.offPeak.window}</p>
            <p className="font-display text-xl font-semibold text-leaf-deep">₦{tariff.offPeak.rate}<span className="text-xs font-body text-sub"> /kWh</span></p>
            <p className="text-[11px] text-leaf-deep mt-1">Run all pumping here</p>
          </div>
          <div className="rounded-lg border border-line p-3">
            <p className="text-xs text-sub">Standard · {tariff.standard.window}</p>
            <p className="font-display text-xl font-semibold">₦{tariff.standard.rate}<span className="text-xs font-body text-sub"> /kWh</span></p>
            <p className="text-[11px] text-sub mt-1">Only for urgent top-ups</p>
          </div>
          <div className="rounded-lg border border-red-200 bg-red-50 p-3">
            <p className="text-xs text-sub">Peak · {tariff.peak.window}</p>
            <p className="font-display text-xl font-semibold text-red-700">₦{tariff.peak.rate}<span className="text-xs font-body text-sub"> /kWh</span></p>
            <p className="text-[11px] text-red-700 mt-1">Avoid — 2.9× off-peak cost</p>
          </div>
        </div>
        <p className="mt-3 rounded-lg bg-volt-soft p-3 text-[13px] text-volt">
          ⚡ Grid instability forecast {tariff.gridRiskWindow}. Diesel backup runs at ₦{tariff.dieselPerKwh}/kWh — schedule nothing in this window.
        </p>
      </Section>

      <Section title="Water & power used this week" pill="kL and kWh">
        <DualLine data={weekUsage} xKey="d" aKey="water" bKey="kwh" aName="Water (kL)" bName="Electricity (kWh)" />
      </Section>

      <Section title="AI resource insights" pill="Updated this morning" pillTone="green">
        <div className="grid md:grid-cols-2 gap-3">
          {insights.map((r, i) => (
            <InsightRow key={i} tag={r.tag} text={r.text} />
          ))}
        </div>
      </Section>
    </div>
  );
}
