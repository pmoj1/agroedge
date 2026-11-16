"use client";
import { useState } from "react";
import { Section } from "@/components/ui";

const channels = [
  { k: "In-app alerts", d: "Water, power and record alerts inside AgroEdge", on: true },
  { k: "SMS alerts", d: "Irrigation windows and grid warnings by text", on: true },
  { k: "WhatsApp assistant", d: "Chat with your farm assistant on WhatsApp (V2)", on: false },
  { k: "Weekly email report", d: "Your farm summary every Monday morning", on: true },
];

export default function Settings() {
  const [state, setState] = useState(channels);
  return (
    <div className="space-y-5 max-w-2xl">
      <div>
        <h1 className="font-display text-2xl font-semibold">Communication settings</h1>
        <p className="text-sm text-sub">Choose how AgroEdge reaches you with insights and alerts.</p>
      </div>
      <Section title="Channels">
        <ul className="divide-y divide-line">
          {state.map((c, i) => (
            <li key={c.k} className="py-3 flex items-center justify-between gap-4 text-[13px]">
              <div>
                <p className="font-medium">{c.k}</p>
                <p className="text-[11px] text-sub">{c.d}</p>
              </div>
              <button
                onClick={() => setState(state.map((x, j) => (j === i ? { ...x, on: !x.on } : x)))}
                aria-label={`Toggle ${c.k}`}
                className={`h-6 w-11 rounded-full transition-colors relative ${c.on ? "bg-leaf" : "bg-line"}`}
              >
                <span className="absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all" style={{ left: c.on ? "1.375rem" : "0.125rem" }} />
              </button>
            </li>
          ))}
        </ul>
      </Section>
    </div>
  );
}
