"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { farm } from "@/lib/data";
import { logout } from "@/lib/auth";

const nav = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/farm-profile", label: "Farm profile" },
  { href: "/activities", label: "Activities" },
  { href: "/expenses", label: "Expenses" },
  { href: "/income", label: "Income" },
  { href: "/analytics", label: "Analytics" },
  { href: "/resources", label: "Water & Energy", badge: "AI" },
  { href: "/assistant", label: "AI Assistant" },
  { href: "/insights", label: "AI Insights" },
  { href: "/crop-planning", label: "Crop planning" },
  { href: "/reminders", label: "Reminders" },
  { href: "/documents", label: "Documents" },
  { href: "/settings", label: "Communication settings" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  return (
    <aside className="hidden md:flex w-56 shrink-0 flex-col border-r border-line bg-white min-h-screen sticky top-0 max-h-screen">
      <div className="flex items-center gap-2 px-4 py-4">
        <span className="text-xl">🌿</span>
        <div>
          <p className="font-display font-semibold leading-none">AgroEdge</p>
          <p className="text-[10px] text-sub">Smart tools for small farms</p>
        </div>
      </div>
      <nav className="px-2 space-y-0.5 overflow-y-auto flex-1">
        {nav.map((item) => {
          const active = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between rounded-lg px-3 py-2 text-[13px] transition-colors ${
                active ? "bg-leaf-soft text-leaf-deep font-semibold" : "text-ink hover:bg-canvas"
              }`}
            >
              {item.label}
              {item.badge && <span className="pill-soft-green">{item.badge}</span>}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-line p-4 space-y-3">
        <div>
          <p className="text-[11px] text-sub">Farm health score</p>
          <div className="mt-1 flex items-center justify-between">
            <span className="pill-green">{farm.healthLabel}</span>
            <span className="text-xs text-sub">{farm.healthScore} / 100</span>
          </div>
        </div>
        <button
          onClick={() => { logout(); router.push("/login"); }}
          className="btn-ghost w-full justify-center text-sub"
        >
          Sign out
        </button>
      </div>
    </aside>
  );
}
