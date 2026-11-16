export function StatCard({ label, value, sub, icon, valueClass = "" }) {
  return (
    <div className="card p-4">
      <div className="flex items-center gap-2 stat-label">
        {icon && <span>{icon}</span>}
        {label}
      </div>
      <p className={`mt-2 font-display text-2xl font-semibold tracking-tight ${valueClass}`}>{value}</p>
      {sub && <p className="mt-1 text-[11px] text-sub">{sub}</p>}
    </div>
  );
}

export function Section({ title, pill, pillTone = "gold", children, action }) {
  return (
    <section className="card p-4 md:p-5">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <h2 className="section-title">{title}</h2>
        <div className="flex items-center gap-2">
          {action}
          {pill && <span className={pillTone === "green" ? "pill-green" : "pill-gold"}>{pill}</span>}
        </div>
      </div>
      <div className="mt-4">{children}</div>
    </section>
  );
}

export function InsightRow({ tag, text }) {
  return (
    <div className="card p-3">
      <div className="flex justify-center">
        <span className="pill-gold w-full justify-center rounded-md py-1">{tag}</span>
      </div>
      <p className="mt-2 text-[13px] leading-relaxed">{text}</p>
    </div>
  );
}
