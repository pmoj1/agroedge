"use client";
import { Section, StatCard } from "@/components/ui";
import { expensesList, totals, naira } from "@/lib/data";

export default function Expenses() {
  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Expenses</h1>
          <p className="text-sm text-sub">Track every naira going out — seeds, labour, transport, power.</p>
        </div>
        <button className="btn-green">+ Add expense</button>
      </div>
      <div className="grid sm:grid-cols-2 gap-4 max-w-xl">
        <StatCard label="Total expenses" value={naira(totals.expenses)} sub="This season" />
        <StatCard label="Cost per acre" value={naira(totals.costPerAcre)} sub="Across 20 acres" />
      </div>
      <Section title="Recent expenses">
        <table className="w-full text-[13px]">
          <thead><tr className="text-left text-xs text-sub border-b border-line">
            <th className="py-2 font-medium">Date</th><th className="py-2 font-medium">Category</th>
            <th className="py-2 font-medium">Note</th><th className="py-2 font-medium text-right">Amount</th>
          </tr></thead>
          <tbody className="divide-y divide-line">
            {expensesList.map((e, i) => (
              <tr key={i}>
                <td className="py-2.5 text-sub">{e.date}</td>
                <td className="py-2.5 font-medium">{e.category}</td>
                <td className="py-2.5 text-sub">{e.note}</td>
                <td className="py-2.5 text-right">{naira(e.amount)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
    </div>
  );
}
