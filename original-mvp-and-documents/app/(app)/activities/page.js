"use client";
import { Section } from "@/components/ui";
import { activities } from "@/lib/data";

export default function Activities() {
  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Activities</h1>
          <p className="text-sm text-sub">Everything you've done on the farm, in one log.</p>
        </div>
        <button className="btn-green">+ Log activity</button>
      </div>
      <Section title="Recent activities" pill="22 this season" pillTone="green">
        <ul className="divide-y divide-line">
          {activities.map((a, i) => (
            <li key={i} className="py-3 flex flex-wrap items-center justify-between gap-2 text-[13px]">
              <div>
                <p className="font-medium">{a.type} — {a.crop}</p>
                <p className="text-[11px] text-sub">{a.note}</p>
              </div>
              <span className="text-xs text-sub">{a.date}</span>
            </li>
          ))}
        </ul>
      </Section>
    </div>
  );
}
