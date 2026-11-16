"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import { getUser } from "@/lib/auth";

export default function AppLayout({ children }) {
  const router = useRouter();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!getUser()) router.replace("/login");
    else setReady(true);
  }, [router]);

  if (!ready) return <div className="min-h-screen grid place-items-center text-sub text-sm">Loading your farm…</div>;

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 min-w-0">
        <header className="flex items-center gap-2 border-b border-line bg-white/70 backdrop-blur px-4 md:px-8 py-3 sticky top-0 z-10">
          <span className="text-lg md:hidden">🌿</span>
          <div>
            <p className="font-display font-semibold leading-none text-sm">AgroEdge</p>
            <p className="text-[11px] text-sub">Farm health and finances at a glance</p>
          </div>
        </header>
        <main className="p-4 md:p-8 max-w-[1400px]">{children}</main>
      </div>
    </div>
  );
}
