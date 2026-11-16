"use client";
import { cropPlans } from "@/lib/data";

export default function CropPlanning() {
  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-2xl font-semibold">AI crop planning suggestions</h1>
        <p className="text-sm text-sub">Next moves for each crop, ranked by impact on your bottom line.</p>
      </div>
      <div className="grid lg:grid-cols-2 gap-4">
        {cropPlans.map((c) => (
          <div key={c.crop} className="card p-4">
            <div className="flex flex-wrap items-start justify-between gap-2">
              <h2 className="section-title">{c.crop}</h2>
              <span className="pill-green text-right max-w-[60%]">{c.action}</span>
            </div>
            <p className="mt-3 text-[13px] leading-relaxed">{c.body}</p>
            <div className="mt-4 grid grid-cols-2 gap-3">
              <div className="rounded-lg border border-line p-3">
                <p className="stat-label">Last yield</p>
                <p className="font-semibold text-sm mt-1">{c.lastYield}</p>
              </div>
              <div className="rounded-lg border border-line p-3">
                <p className="stat-label">Profit</p>
                <p className="font-semibold text-sm mt-1 text-leaf">{c.profit}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
