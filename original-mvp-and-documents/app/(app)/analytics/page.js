"use client";
import { StatCard, Section } from "@/components/ui";
import { GroupedBars, SimpleBars } from "@/components/charts";
import {
  totals, naira, fmt, revenueVsExpenses, monthlyProfit, yieldBySeason,
  expenseTrends, revenueTrends, seasonalComparison, bestCrops, farm,
} from "@/lib/data";

const toneClass = { green: "text-leaf", gold: "text-gold-deep" };

export default function Analytics() {
  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">Farm analytics</h1>
          <p className="text-sm text-sub">Understand your profit, yields, and trends across seasons.</p>
        </div>
        <label className="text-xs text-sub">
          Period
          <select className="ml-2 rounded-lg border border-line bg-white px-3 py-1.5 text-sm text-ink">
            <option>All seasons</option>
            <option>Season 3</option>
            <option>Season 2</option>
            <option>Season 1</option>
          </select>
        </label>
      </div>

      <div className="grid sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon="📈" label="Total income" value={naira(totals.income)} sub="From all crop sales" />
        <StatCard icon="🧾" label="Total expenses" value={naira(totals.expenses)} sub="Across all categories" />
        <StatCard icon="🌱" label="Net profit" value={naira(totals.net)} sub="Income minus expenses" valueClass="text-leaf" />
        <StatCard icon="📊" label="Profit margin" value={totals.margin + "%"} sub="Profit over income" />
      </div>

      <div className="grid lg:grid-cols-2 gap-4">
        <Section title="Revenue vs expenses" pill="By period">
          <GroupedBars data={revenueVsExpenses} xKey="m" aKey="revenue" bKey="expenses" aName="Revenue" bName="Expenses" />
        </Section>
        <Section title="Monthly profit trend" pill="Up 12%" pillTone="green">
          <SimpleBars data={monthlyProfit} xKey="m" yKey="profit" />
        </Section>
      </div>

      <Section title="Profit & Loss statement" pill="By season / date range">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs text-sub border-b border-line">
              <th className="py-2 font-medium">Line item</th>
              <th className="py-2 font-medium text-right">Amount</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-line">
            <tr><td className="py-2.5">Total income</td><td className="py-2.5 text-right">{naira(totals.income)}</td></tr>
            <tr><td className="py-2.5">Total expenses</td><td className="py-2.5 text-right">({naira(totals.expenses)})</td></tr>
            <tr className="font-semibold"><td className="py-2.5">Net profit</td><td className="py-2.5 text-right text-leaf">{naira(totals.net)}</td></tr>
          </tbody>
        </table>
      </Section>

      <div className="grid lg:grid-cols-2 gap-4">
        <Section title="Yield trends over time" pill="By crop & season">
          <SimpleBars data={yieldBySeason} xKey="s" yKey="yield" color="#E2A60C" money={false} />
          <p className="text-[11px] text-sub mt-1">Total harvested yield grouped by season label</p>
        </Section>
        <Section title="Best-performing crops" pill="Ranked" pillTone="green">
          <ol className="space-y-2">
            {bestCrops.map((c, i) => (
              <li key={c.crop} className="flex items-center justify-between rounded-lg border border-line p-3 text-sm">
                <span className="font-medium">{i + 1}. {c.crop}</span>
                <span className="text-sub text-xs">{c.margin} · {naira(c.revenue)}</span>
              </li>
            ))}
          </ol>
        </Section>
      </div>

      <div className="grid lg:grid-cols-2 gap-4">
        <Section title="Expense trends" pill="By month & category">
          <SimpleBars data={expenseTrends} xKey="c" yKey="v" color="#E2A60C" />
        </Section>
        <Section title="Revenue trends" pill="By month & crop" pillTone="green">
          <SimpleBars data={revenueTrends} xKey="c" yKey="v" />
        </Section>
      </div>

      <Section title="Seasonal comparison" pill="Current vs previous">
        <div className="grid sm:grid-cols-3 gap-4">
          {seasonalComparison.map((s) => (
            <div key={s.k} className="rounded-lg border border-line p-3">
              <p className="stat-label">{s.k}</p>
              <p className={`mt-1 font-semibold ${toneClass[s.tone]}`}>{s.v}</p>
              <p className="text-[11px] text-sub">{s.sub}</p>
            </div>
          ))}
        </div>
      </Section>

      <div className="grid sm:grid-cols-2 gap-4">
        <StatCard label="Cost per acre" value={naira(totals.costPerAcre)} sub="Total expenses divided by farm size" />
        <StatCard label="Yield per acre" value={fmt(totals.yieldPerAcre) + " kg"} sub="Total harvest divided by farm size" />
      </div>

      <Section title="Farm health score" pill={farm.healthLabel} pillTone="green">
        <div className="grid sm:grid-cols-2 xl:grid-cols-4 gap-4">
          {farm.health.map((h) => (
            <div key={h.k} className="rounded-lg border border-line p-3">
              <p className="stat-label">{h.k}</p>
              <p className={`mt-1 font-semibold ${toneClass[h.tone]}`}>{h.v}</p>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}
