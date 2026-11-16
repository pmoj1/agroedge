"use client";
import { Section } from "@/components/ui";
import { documents } from "@/lib/data";

export default function Documents() {
  return (
    <div className="space-y-5 max-w-2xl">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Documents</h1>
          <p className="text-sm text-sub">Leases, certificates and receipts — kept with your farm records.</p>
        </div>
        <button className="btn-green">⬆ Upload document</button>
      </div>
      <Section title="Your files">
        <ul className="divide-y divide-line">
          {documents.map((d) => (
            <li key={d.name} className="py-3 flex items-center justify-between text-[13px]">
              <p className="font-medium">📄 {d.name}</p>
              <span className="text-xs text-sub">Added {d.added}</span>
            </li>
          ))}
        </ul>
      </Section>
    </div>
  );
}
