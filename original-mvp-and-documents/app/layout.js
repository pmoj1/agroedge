import "./globals.css";
import { Fraunces, Inter } from "next/font/google";

const display = Fraunces({ subsets: ["latin"], variable: "--font-display", weight: ["500", "600", "700"] });
const body = Inter({ subsets: ["latin"], variable: "--font-body" });

export const metadata = {
  title: "AgroEdge — Turning Farm Data Into Smarter Decisions",
  description: "Farm health, finances, water and energy at a glance.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable}`}>
      <body>{children}</body>
    </html>
  );
}
