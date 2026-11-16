"use client";
import { useState, useRef, useEffect } from "react";
import { Section } from "@/components/ui";
import { assistantSeed, suggestedPrompts, reminders, alerts } from "@/lib/data";

export default function Assistant() {
  const [messages, setMessages] = useState(assistantSeed);
  const [input, setInput] = useState("");
  const [busy, setBusy] = useState(false);
  const [alertList, setAlertList] = useState(alerts);
  const endRef = useRef(null);

  useEffect(() => { endRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  async function send(text) {
    const q = (text ?? input).trim();
    if (!q || busy) return;
    setInput("");
    const next = [...messages, { role: "user", text: q }];
    setMessages(next);
    setBusy(true);
    try {
      const res = await fetch("/api/assistant", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ mode: "chat", messages: next }),
      });
      const data = await res.json();
      setMessages((m) => [...m, { role: "ai", text: data.reply }]);
    } catch {
      setMessages((m) => [...m, { role: "ai", text: "I couldn't reach the AI service. Please try again." }]);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-semibold">AI Assistant & Reminders</h1>
          <p className="text-sm text-sub">Ask questions about your farm and never miss an important task.</p>
        </div>
        <button className="btn-green">+ New reminder</button>
      </div>

      <div className="grid lg:grid-cols-5 gap-4 items-start">
        <div className="lg:col-span-3 space-y-4">
          <div className="card p-4 flex flex-col">
            <div className="flex items-center gap-2">
              <span className="grid h-9 w-9 place-items-center rounded-full bg-leaf text-white text-sm">🤖</span>
              <div>
                <p className="font-display font-semibold text-sm">Farm Assistant</p>
                <p className="text-[11px] text-sub">Knows your records, yields and finances</p>
              </div>
            </div>
            <div className="mt-4 h-80 overflow-y-auto space-y-3 pr-1">
              {messages.map((m, i) => (
                <div key={i} className={`max-w-[85%] rounded-xl p-3 text-[13px] leading-relaxed ${
                  m.role === "user" ? "bg-canvas border border-line" : "bg-leaf-soft text-leaf-deep ml-auto"
                }`}>
                  <p className="text-[10px] font-semibold text-sub mb-1">{m.role === "user" ? "You" : "AI"}</p>
                  {m.text}
                </div>
              ))}
              {busy && <p className="text-xs text-sub">Farm Assistant is thinking…</p>}
              <div ref={endRef} />
            </div>
            <div className="mt-3 flex flex-wrap gap-2">
              {suggestedPrompts.map((p) => (
                <button key={p} onClick={() => send(p)} className="btn-ghost text-xs">{p}</button>
              ))}
            </div>
            <div className="mt-3 flex gap-2">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && send()}
                placeholder="Ask your farm assistant anything…"
                className="flex-1 rounded-lg border border-line bg-white px-3 py-2.5 text-sm focus:border-leaf focus:ring-2 focus:ring-leaf-soft"
              />
              <button onClick={() => send()} className="btn-green">▷ Send</button>
            </div>
          </div>

          <div className="rounded-xl bg-gold text-white p-4">
            <p className="font-semibold text-sm">💡 Suggested reminders</p>
            <p className="text-xs text-white/85 mt-1">
              Based on your crop calendar: fungal spray for cocoa (every 21 days), maize nitrogen top-dressing window,
              and tonight's 04:00 irrigation cycle for Block B.
            </p>
          </div>
        </div>

        <div className="lg:col-span-2 space-y-4">
          <Section title="Your reminders" action={<span>⏰</span>}>
            <ul className="divide-y divide-line">
              {reminders.map((r) => (
                <li key={r.title} className="py-2.5 flex items-center justify-between text-[13px]">
                  <div>
                    <p className="font-medium">{r.title}</p>
                    <p className="text-[11px] text-sub">Due {r.due}</p>
                  </div>
                  <span className="pill-soft-gold">{r.tag}</span>
                </li>
              ))}
            </ul>
          </Section>

          <Section title="In-app alerts" action={<span>🔔</span>}>
            <select className="w-full rounded-lg border border-line bg-white px-3 py-2 text-sm text-sub">
              <option>All types</option>
              <option>Water</option>
              <option>Electricity</option>
              <option>Records</option>
            </select>
            <ul className="mt-3 space-y-2">
              {alertList.map((a, i) => (
                <li key={i} className="rounded-lg border border-line p-3 text-[13px]">
                  <span className="pill-soft-green">{a.type}</span>
                  <p className="mt-1.5">{a.text}</p>
                  <p className="text-[11px] text-sub mt-1">{a.time}</p>
                </li>
              ))}
              {alertList.length === 0 && <p className="text-sm text-sub py-4 text-center">All clear — no alerts right now.</p>}
            </ul>
            <div className="mt-3 flex gap-2">
              <button className="btn-ghost text-xs">✓ Mark all read</button>
              <button onClick={() => setAlertList([])} className="btn-ghost text-xs">🗑 Clear all</button>
            </div>
          </Section>
        </div>
      </div>
    </div>
  );
}
