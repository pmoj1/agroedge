"use client";
import { Section } from "@/components/ui";
import { reminders } from "@/lib/data";

export default function Reminders() {
  return (
    <div className="space-y-5 max-w-2xl">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Reminders</h1>
          <p className="text-sm text-sub">Never miss a spray, a sale record, or tonight's irrigation window.</p>
        </div>
        <button className="btn-green">+ New reminder</button>
      </div>
      <Section title="Upcoming">
        <ul className="divide-y divide-line">
          {reminders.map((r) => (
            <li key={r.title} className="py-3 flex items-center justify-between text-[13px]">
              <div>
                <p className="font-medium">{r.title}</p>
                <p className="text-[11px] text-sub">Due {r.due}</p>
              </div>
              <span className="pill-soft-gold">{r.tag}</span>
            </li>
          ))}
        </ul>
      </Section>
    </div>
  );
}
