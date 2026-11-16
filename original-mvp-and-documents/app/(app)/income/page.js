"use client";
import { Section, StatCard } from "@/components/ui";
import { incomeList, totals, naira } from "@/lib/data";

export default function Income() {
  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Income</h1>
          <p className="text-sm text-sub">Every sale recorded, by crop and buyer.</p>
        </div>
        <button className="btn-green">+ Record sale</button>
      </div>
      <div className="grid sm:grid-cols-2 gap-4 max-w-xl">
        <StatCard label="Total income" value={naira(totals.income)} sub="From all crop sales" valueClass="text-leaf" />
        <StatCard label="Profit margin" value={totals.margin + "%"} sub="Profit over income" />
      </div>
      <Section title="Recent sales">
        <table className="w-full text-[13px]">
          <thead><tr className="text-left text-xs text-sub border-b border-line">
            <th className="py-2 font-medium">Date</th><th className="py-2 font-medium">Buyer</th>
            <th className="py-2 font-medium">Crop</th><th className="py-2 font-medium text-right">Amount</th>
          </tr></thead>
          <tbody className="divide-y divide-line">
            {incomeList.map((s, i) => (
              <tr key={i}>
                <td className="py-2.5 text-sub">{s.date}</td>
                <td className="py-2.5 font-medium">{s.buyer}</td>
                <td className="py-2.5">{s.crop}</td>
                <td className="py-2.5 text-right text-leaf font-medium">{naira(s.amount)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
    </div>
  );
}
