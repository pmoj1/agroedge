"use client";
import { useState } from "react";
import { Section } from "@/components/ui";
import { farm } from "@/lib/data";

export default function FarmProfile() {
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({ name: farm.name, location: farm.location, size: farm.sizeAcres, crop: farm.currentCrop });
  const set = (k) => (e) => { setForm({ ...form, [k]: e.target.value }); setSaved(false); };
  return (
    <div className="space-y-5 max-w-2xl">
      <div>
        <h1 className="font-display text-2xl font-semibold">Farm profile</h1>
        <p className="text-sm text-sub">Your farm details tailor every AI insight, water plan and pump schedule.</p>
      </div>
      <Section title="Farm details">
        <div className="grid sm:grid-cols-2 gap-4">
          {[
            ["Farm name", "name", "text"],
            ["Location", "location", "text"],
            ["Farm size (acres)", "size", "number"],
            ["Current crop", "crop", "text"],
          ].map(([label, key, type]) => (
            <label key={key} className="block">
              <span className="text-xs font-medium text-sub">{label}</span>
              <input type={type} value={form[key]} onChange={set(key)}
                className="mt-1 w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm focus:border-leaf focus:ring-2 focus:ring-leaf-soft" />
            </label>
          ))}
        </div>
        <button onClick={() => setSaved(true)} className="btn-green mt-4">Save changes</button>
        {saved && <p className="text-xs text-leaf mt-2">Changes saved.</p>}
      </Section>
      <Section title="Irrigation & power setup" pill="Used by Water & Energy AI" pillTone="green">
        <ul className="text-[13px] space-y-2">
          <li className="flex justify-between border-b border-line pb-2"><span className="text-sub">Pump rating</span><span className="font-medium">5.5 kW · 14,000 L/h</span></li>
          <li className="flex justify-between border-b border-line pb-2"><span className="text-sub">Irrigation type</span><span className="font-medium">Drip lines (Blocks B, C) · Sprinkler (Block A)</span></li>
          <li className="flex justify-between"><span className="text-sub">Power source</span><span className="font-medium">Grid + diesel backup</span></li>
        </ul>
      </Section>
    </div>
  );
}
