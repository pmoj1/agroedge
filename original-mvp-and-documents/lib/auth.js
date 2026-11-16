"use client";

const KEY = "agroedge_user";

export function getUser() {
  if (typeof window === "undefined") return null;
  try { return JSON.parse(localStorage.getItem(KEY)); } catch { return null; }
}

export function login(email, password) {
  // Demo auth: any email + password of 6+ chars. Replace with NextAuth/Supabase in production.
  if (!email.includes("@") || password.length < 6) {
    return { ok: false, error: "Enter a valid email and a password of at least 6 characters." };
  }
  const user = { email, name: email.split("@")[0].replace(/[._]/g, " "), at: Date.now() };
  localStorage.setItem(KEY, JSON.stringify(user));
  return { ok: true, user };
}

export function logout() { localStorage.removeItem(KEY); }
