"use client";
import { Section, InsightRow } from "@/components/ui";
import { aiInsights, weeklyReport } from "@/lib/data";
import { resourceInsights } from "@/lib/resource-ai";

export default function Insights() {
  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-2xl font-semibold">AI insights</h1>
        <p className="text-sm text-sub">What your farm data is telling you — money, productivity, water and power.</p>
      </div>

      <Section title="Finance & productivity">
        <div className="grid md:grid-cols-2 gap-3">
          {aiInsights.map((x, i) => <InsightRow key={i} tag={x.tag} text={x.text} />)}
        </div>
      </Section>

      <Section title="Water & energy" pill="New" pillTone="green">
        <div className="grid md:grid-cols-2 gap-3">
          {resourceInsights().map((x, i) => <InsightRow key={i} tag={x.tag} text={x.text} />)}
        </div>
      </Section>

      <Section title="Weekly farm report" action={<button className="btn-green text-xs">📄 Generate new report</button>}>
        <span className="pill-soft-green">In-App Only</span>
        <p className="mt-2 text-[13px] leading-relaxed">{weeklyReport}</p>
        <p className="mt-2 text-[11px] text-sub text-right">This week's summary</p>
      </Section>
    </div>
  );
}
