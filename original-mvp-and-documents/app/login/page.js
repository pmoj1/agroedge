"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { login } from "@/lib/auth";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [mode, setMode] = useState("login");

  function submit() {
    const res = login(email, password);
    if (!res.ok) return setError(res.error);
    router.push("/dashboard");
  }

  return (
    <main className="min-h-screen grid lg:grid-cols-2">
      <section className="hidden lg:flex flex-col justify-between bg-leaf-deep text-white p-12">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🌿</span>
          <div>
            <p className="font-display text-xl font-semibold leading-none">AgroEdge</p>
            <p className="text-xs text-white/70">Smart tools for small farms</p>
          </div>
        </div>
        <div>
          <h1 className="font-display text-4xl font-semibold leading-tight max-w-md">
            Turning farm data into smarter decisions.
          </h1>
          <p className="mt-4 text-white/80 max-w-md text-sm leading-relaxed">
            Track activities, money, yields — and let AI tell you the cheapest hour to run
            your pump and the best time to irrigate.
          </p>
          <div className="mt-8 grid grid-cols-3 gap-3 max-w-md">
            {[
              ["₦", "Income & expense tracking"],
              ["💧", "AI water management"],
              ["⚡", "Pump & power scheduling"],
            ].map(([icon, label]) => (
              <div key={label} className="rounded-xl bg-white/10 p-3">
                <p className="text-lg">{icon}</p>
                <p className="text-xs mt-1 text-white/85">{label}</p>
              </div>
            ))}
          </div>
        </div>
        <p className="text-xs text-white/60">Smarter farms. Stronger futures. 🌍</p>
      </section>

      <section className="flex items-center justify-center p-6">
        <div className="w-full max-w-sm">
          <div className="lg:hidden mb-8 flex items-center gap-2">
            <span className="text-2xl">🌿</span>
            <p className="font-display text-xl font-semibold">AgroEdge</p>
          </div>
          <h2 className="font-display text-2xl font-semibold">
            {mode === "login" ? "Welcome back, farmer" : "Create your farm account"}
          </h2>
          <p className="text-sm text-sub mt-1">
            {mode === "login"
              ? "Sign in to see how your farm is doing today."
              : "One account for your fields, money and AI insights."}
          </p>

          <div className="mt-6 space-y-4">
            <label className="block">
              <span className="text-xs font-medium text-sub">Email or phone</span>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@farm.com"
                className="mt-1 w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm focus:border-leaf focus:ring-2 focus:ring-leaf-soft"
              />
            </label>
            <label className="block">
              <span className="text-xs font-medium text-sub">Password</span>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && submit()}
                placeholder="At least 6 characters"
                className="mt-1 w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm focus:border-leaf focus:ring-2 focus:ring-leaf-soft"
              />
            </label>
            {error && <p className="text-xs text-red-600">{error}</p>}
            <button onClick={submit} className="btn-green w-full justify-center py-2.5">
              {mode === "login" ? "Sign in" : "Create account"}
            </button>
            <button
              onClick={() => { setMode(mode === "login" ? "signup" : "login"); setError(""); }}
              className="w-full text-center text-sm text-leaf hover:underline"
            >
              {mode === "login" ? "New to AgroEdge? Create an account" : "Already have an account? Sign in"}
            </button>
            <p className="text-[11px] text-sub text-center">
              Demo build — any email and a 6+ character password works.
            </p>
          </div>
        </div>
      </section>
    </main>
  );
}
