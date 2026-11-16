"use client";
import Link from "next/link";
import { StatCard, Section } from "@/components/ui";
import { PosNegBars } from "@/components/charts";
import { farm, totals, naira, yieldSnapshot, cashFlowMonths, aiInsights } from "@/lib/data";
import { resourceInsights } from "@/lib/resource-ai";

const toneClass = { green: "text-leaf", gold: "text-gold-deep" };

export default function Dashboard() {
  const resource = resourceInsights().slice(0, 2);
  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-2xl font-semibold">Welcome back to your farm</h1>
        <p className="text-sm text-sub">Here is how things are looking today.</p>
      </div>

      <div className="rounded-xl bg-gold text-white p-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="font-semibold text-sm">Finish setting up your farm profile</p>
          <p className="text-xs text-white/85">Add your farm size, crops, and location so we can tailor your insights.</p>
        </div>
        <Link href="/farm-profile" className="rounded-lg bg-white/15 hover:bg-white/25 px-3 py-1.5 text-xs font-medium">
          Edit profile
        </Link>
      </div>

      <div className="grid sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon="📈" label="Total income" value={naira(totals.income)} sub="From all crop sales" />
        <StatCard icon="🧾" label="Total expenses" value={naira(totals.expenses)} sub="Seeds, labour, transport & more" />
        <StatCard icon="💹" label="Net profit / loss" value={naira(totals.net)} sub="Income minus expenses" valueClass="text-leaf" />
        <StatCard icon="📋" label="Activities logged" value={totals.activities} sub="Across all your fields" />
      </div>

      <div className="grid lg:grid-cols-3 gap-4">
        <Section title="Farm health score" pill={farm.healthLabel} pillTone="green">
          <p className="font-display text-3xl font-semibold">{farm.healthScore}<span className="text-base text-sub font-body"> / 100</span></p>
          <p className="text-xs text-sub mt-1">Your farm is on the right track.</p>
          <div className="mt-4 space-y-2">
            {farm.health.map((h) => (
              <div key={h.k} className="flex justify-between text-[13px]">
                <span className="text-sub">{h.k}</span>
                <span className={`font-medium ${toneClass[h.tone]}`}>{h.v}</span>
              </div>
            ))}
          </div>
        </Section>

        <Section title="My farm">
          <div className="space-y-3">
            <div className="rounded-lg border border-line p-3">
              <p className="stat-label">Current crop</p>
              <p className="font-display text-lg font-semibold">{farm.currentCrop}</p>
            </div>
            <div className="rounded-lg border border-line p-3">
              <p className="stat-label">Farm size</p>
              <p className="font-display text-lg font-semibold">{farm.sizeAcres} acres</p>
            </div>
            <Link href="/farm-profile" className="text-leaf text-xs font-medium hover:underline">View full farm profile</Link>
          </div>
        </Section>

        <Section title="Yield snapshot">
          <div className="rounded-lg border border-line p-3 flex items-center justify-between">
            <div>
              <p className="stat-label">Top crop</p>
              <p className="font-display text-lg font-semibold">{yieldSnapshot.topCrop}</p>
            </div>
            <span className="pill-soft-green">↑ {yieldSnapshot.topChange}</span>
          </div>
          <ul className="mt-3 divide-y divide-line max-h-56 overflow-y-auto pr-1">
            {yieldSnapshot.rows.map((r, i) => (
              <li key={i} className="flex items-center justify-between py-2 text-[13px]">
                <div>
                  <p className="font-medium">{r.crop}</p>
                  <p className="text-[11px] text-sub">{r.date}</p>
                </div>
                <span className="text-leaf font-medium">{r.qty} ↑</span>
              </li>
            ))}
          </ul>
          <Link href="/analytics" className="mt-2 inline-block text-leaf text-xs font-medium hover:underline">See full yield analytics</Link>
        </Section>
      </div>

      <div className="rounded-xl bg-leaf-deep text-white p-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="font-semibold text-sm">💡 Latest AI insight</p>
          <Link href="/insights" className="rounded-lg bg-white text-leaf-deep px-3 py-1.5 text-xs font-semibold">View all insights</Link>
        </div>
        <span className="pill-gold mt-3">{aiInsights[1].tag}</span>
        <p className="mt-2 text-sm text-white/90">{aiInsights[1].text}</p>
      </div>

      <div className="rounded-xl bg-water-soft border border-line p-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="font-semibold text-sm text-water">💧⚡ Today's water & energy plan</p>
          <Link href="/resources" className="rounded-lg bg-water text-white px-3 py-1.5 text-xs font-semibold">Open Water & Energy</Link>
        </div>
        <div className="mt-3 grid md:grid-cols-2 gap-3">
          {resource.map((r, i) => (
            <p key={i} className="text-[13px] leading-relaxed"><span className="font-semibold">{r.tag}: </span>{r.text}</p>
          ))}
        </div>
      </div>

      <Section title="Cash flow">
        <div className="grid sm:grid-cols-3 gap-4">
          <StatCard label="Total inflows" value={naira(totals.income)} valueClass="text-leaf" />
          <StatCard label="Total outflows" value={naira(totals.expenses)} valueClass="text-red-700" />
          <StatCard label="Net cash flow" value={naira(totals.net)} />
        </div>
        <div className="mt-4">
          <PosNegBars data={cashFlowMonths} xKey="m" yKey="net" />
        </div>
      </Section>

      <div className="rounded-xl bg-gold text-white p-4 flex items-center justify-between gap-4">
        <div>
          <p className="text-xs text-white/85">Target revenue to break even</p>
          <p className="font-display text-2xl font-semibold">{naira(totals.expenses)}</p>
          <p className="text-xs text-white/85">Roughly 2,330 crates of produce to cover stored costs</p>
        </div>
        <span className="text-2xl">⚖️</span>
      </div>
    </div>
  );
}
