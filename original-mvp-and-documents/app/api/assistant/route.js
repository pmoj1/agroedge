import { NextResponse } from "next/server";
import { resourceInsights, irrigationWindows, energyPlan, tariff } from "@/lib/resource-ai";
import { totals, farm } from "@/lib/data";

const SYSTEM = `You are the AgroEdge Farm Assistant for a smallholder farmer in Nigeria.
Farm: ${farm.sizeAcres} acres, current crop ${farm.currentCrop}, health score ${farm.healthScore}/100.
Season totals: income ₦${totals.income}, expenses ₦${totals.expenses}, net ₦${totals.net}.
Electricity tariff: off-peak ${tariff.offPeak.window} at ₦${tariff.offPeak.rate}/kWh, peak ${tariff.peak.window} at ₦${tariff.peak.rate}/kWh. Grid risk window ${tariff.gridRiskWindow}.
Best irrigation window today: 04:00–06:30 (lowest evaporation + off-peak power).
Answer in 2-4 short sentences, practical and specific, using ₦ for money.`;

function fallbackReply(question = "") {
  const q = question.toLowerCase();
  const e = energyPlan();
  if (q.includes("irrigat") || q.includes("water")) {
    const best = irrigationWindows()[0];
    return `Irrigate between ${best.window} — it's the coolest part of the day with the least evaporation, and your pump runs on off-peak power until 05:00. ${best.why} Skip Saturday's cycle: ~18 mm of rain is forecast.`;
  }
  if (q.includes("electric") || q.includes("pump") || q.includes("power") || q.includes("cost")) {
    return `Run all pumping in the off-peak window (${tariff.offPeak.window} at ₦${tariff.offPeak.rate}/kWh). Tonight's full cycle needs ${e.kwh} kWh, costing ₦${e.costOffPeak.toLocaleString()} off-peak vs ₦${e.costPeak.toLocaleString()} at peak — a saving of ₦${e.saveVsPeak.toLocaleString()}. Avoid ${tariff.gridRiskWindow}: grid instability means diesel backup at ₦${tariff.dieselPerKwh}/kWh.`;
  }
  if (q.includes("expand") || q.includes("which crop")) {
    return `Cocoa is your strongest candidate: 74% profit margin this season with 1,800 kg harvested. Expanding by 2 hectares could add roughly ₦180,000, and your fungal-spray schedule already protects pod quality. Cassava is second — local processing could lift its revenue up to 40%.`;
  }
  if (q.includes("week") || q.includes("summar")) {
    return `This week: 3 activities logged including a 4,200 kg maize harvest, a ₦255,000 sale to Kano Grain Cooperative, and ₦15,000 in seed costs — net position +₦240,000. AI tip: store part of the maize harvest to catch post-harvest price increases in 6–8 weeks.`;
  }
  return `Your farm is in good shape: ₦${totals.net.toLocaleString()} net profit at a ${totals.margin}% margin, health score ${farm.healthScore}/100. Tonight, irrigate Block B at 04:00–06:30 on off-peak power, and confirm the missing Sorghum sale record so your books stay accurate.`;
}

export async function POST(req) {
  const body = await req.json().catch(() => ({}));

  if (body.mode === "resources") {
    // The rule-based engine already encodes the plan; a Claude key refines the wording.
    return NextResponse.json({ insights: resourceInsights() });
  }

  const history = Array.isArray(body.messages) ? body.messages : [];
  const lastUser = [...history].reverse().find((m) => m.role === "user")?.text ?? "";

  const key = process.env.ANTHROPIC_API_KEY;
  if (key) {
    try {
      const res = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": key,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 500,
          system: SYSTEM,
          messages: history.map((m) => ({
            role: m.role === "ai" ? "assistant" : "user",
            content: m.text,
          })),
        }),
      });
      const data = await res.json();
      const reply = (data.content || []).filter((c) => c.type === "text").map((c) => c.text).join("\n");
      if (reply) return NextResponse.json({ reply, source: "claude" });
    } catch {
      // fall through to rule-based engine
    }
  }

  return NextResponse.json({ reply: fallbackReply(lastUser), source: "engine" });
}
