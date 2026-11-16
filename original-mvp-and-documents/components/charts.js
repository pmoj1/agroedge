"use client";
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, CartesianGrid, Cell, LineChart, Line,
} from "recharts";

const GREEN = "#1E6B40";
const GOLD = "#E2A60C";
const RED = "#C03A2B";
const WATER = "#1B6E8C";
const VOLT = "#7A5AF8";

const axis = { stroke: "#9AA396", fontSize: 11, tickLine: false, axisLine: false };
const tip = { contentStyle: { borderRadius: 10, border: "1px solid #E7E5DB", fontSize: 12 } };

export function GroupedBars({ data, xKey, aKey, bKey, aName, bName }) {
  return (
    <ResponsiveContainer width="100%" height={220}>
      <BarChart data={data} barGap={4}>
        <CartesianGrid vertical={false} stroke="#EFEDE4" />
        <XAxis dataKey={xKey} {...axis} />
        <YAxis {...axis} width={50} tickFormatter={(v) => (v >= 1000 ? `${v / 1000}k` : v)} />
        <Tooltip {...tip} formatter={(v) => "₦" + v.toLocaleString()} />
        <Legend iconType="circle" wrapperStyle={{ fontSize: 11 }} />
        <Bar dataKey={aKey} name={aName} fill={GREEN} radius={[3, 3, 0, 0]} maxBarSize={18} />
        <Bar dataKey={bKey} name={bName} fill={GOLD} radius={[3, 3, 0, 0]} maxBarSize={18} />
      </BarChart>
    </ResponsiveContainer>
  );
}

export function SimpleBars({ data, xKey, yKey, color = GREEN, money = true, height = 220 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={data}>
        <CartesianGrid vertical={false} stroke="#EFEDE4" />
        <XAxis dataKey={xKey} {...axis} />
        <YAxis {...axis} width={50} tickFormatter={(v) => (v >= 1000 ? `${v / 1000}k` : v)} />
        <Tooltip {...tip} formatter={(v) => (money ? "₦" + v.toLocaleString() : v.toLocaleString())} />
        <Bar dataKey={yKey} fill={color} radius={[4, 4, 0, 0]} maxBarSize={120} />
      </BarChart>
    </ResponsiveContainer>
  );
}

export function PosNegBars({ data, xKey, yKey, height = 160 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={data}>
        <XAxis dataKey={xKey} {...axis} />
        <YAxis hide />
        <Tooltip {...tip} formatter={(v) => "₦" + v.toLocaleString()} />
        <Bar dataKey={yKey} radius={[3, 3, 3, 3]} maxBarSize={10}>
          {data.map((d, i) => (
            <Cell key={i} fill={d[yKey] >= 0 ? GREEN : RED} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}

export function DualLine({ data, xKey, aKey, bKey, aName, bName, height = 220 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={data}>
        <CartesianGrid vertical={false} stroke="#EFEDE4" />
        <XAxis dataKey={xKey} {...axis} />
        <YAxis {...axis} width={40} />
        <Tooltip {...tip} />
        <Legend iconType="circle" wrapperStyle={{ fontSize: 11 }} />
        <Line type="monotone" dataKey={aKey} name={aName} stroke={WATER} strokeWidth={2} dot={false} />
        <Line type="monotone" dataKey={bKey} name={bName} stroke={VOLT} strokeWidth={2} dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
}
