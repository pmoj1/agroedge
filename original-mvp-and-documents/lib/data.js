export const fmt = (n) => new Intl.NumberFormat("en-NG").format(n);
export const naira = (n) => "₦" + fmt(n);

export const farm = {
  name: "Demo Farm",
  farmer: "Demo Farmer",
  currentCrop: "Sorghum",
  sizeAcres: 20,
  location: "Kano, Nigeria",
  healthScore: 78,
  healthLabel: "Healthy",
  health: [
    { k: "Profit direction", v: "Improving", tone: "green" },
    { k: "Expense vs revenue", v: "Balanced", tone: "green" },
    { k: "Yield stability", v: "Watch", tone: "gold" },
    { k: "Activity frequency", v: "Active", tone: "green" },
  ],
};

export const totals = {
  income: 3378200,
  expenses: 314900,
  net: 3063300,
  margin: 90.68,
  activities: 22,
  costPerAcre: 15745,
  yieldPerAcre: 412,
};

export const revenueVsExpenses = [
  { m: "Jan", revenue: 610000, expenses: 92000 },
  { m: "Feb", revenue: 880000, expenses: 71000 },
  { m: "Mar", revenue: 560000, expenses: 86000 },
  { m: "Apr", revenue: 1328200, expenses: 65900 },
];

export const monthlyProfit = [
  { m: "Jan", profit: 518000 },
  { m: "Feb", profit: 809000 },
  { m: "Mar", profit: 474000 },
  { m: "Apr", profit: 1262300 },
  { m: "May", profit: 1410000 },
];

export const cashFlowMonths = [
  { m: "Jan", net: 518000 },
  { m: "Feb", net: 809000 },
  { m: "Mar", net: -86000 },
  { m: "Apr", net: 1262300 },
];

export const yieldBySeason = [
  { s: "S1", yield: 6200 },
  { s: "S2", yield: 7900 },
  { s: "S3", yield: 9400 },
];

export const expenseTrends = [
  { c: "Seeds", v: 78000 },
  { c: "Fertiliser", v: 112000 },
  { c: "Labour", v: 84000 },
  { c: "Transport", v: 40900 },
];

export const revenueTrends = [
  { c: "Maize", v: 255000 },
  { c: "Cassava", v: 480000 },
  { c: "Sorghum", v: 310000 },
];

export const seasonalComparison = [
  { k: "Spending change", v: "+8% higher", sub: "vs previous season", tone: "gold" },
  { k: "Earnings change", v: "+15% higher", sub: "vs previous season", tone: "green" },
  { k: "Yield change", v: "+11% higher", sub: "vs previous season", tone: "green" },
];

export const bestCrops = [
  { crop: "Cocoa", margin: "74% margin", revenue: 180000 },
  { crop: "Cassava", margin: "61% margin", revenue: 480000 },
  { crop: "Maize", margin: "55% margin", revenue: 255000 },
];

export const yieldSnapshot = {
  topCrop: "Tobacco",
  topChange: "+12%",
  rows: [
    { crop: "Cassava", date: "Mar 1, 2026 3:00 pm", qty: "5,000 crates" },
    { crop: "Cocoa", date: "May 25, 2026 2:30 pm", qty: "1,800 kg" },
    { crop: "Groundnut", date: "Feb 15, 2026 2:30 pm", qty: "1,200 bags" },
    { crop: "Maize", date: "May 28, 2026 2:00 pm", qty: "4,200 kg" },
    { crop: "Maize", date: "Apr 30, 2026 3:00 pm", qty: "3,500 kg" },
    { crop: "Sorghum", date: "Apr 20, 2026 2:45 pm", qty: "2,100 bags" },
    { crop: "Soybean", date: "May 29, 2026 2:00 pm", qty: "800 tonnes" },
  ],
};

export const cropPlans = [
  {
    crop: "Cassava",
    action: "Contact Delta Fresh Processors about value-added cassava processing",
    body: "Cassava yielded 5,000 crates with ₦180,000 revenue. Processing into flour or starch locally could increase revenue by up to 40%. Explore cooperative processing arrangements in your region.",
    lastYield: "5,000 crates", profit: "₦180,000",
  },
  {
    crop: "Maize",
    action: "Apply nitrogen-fixing cover crop rotation before next planting season",
    body: "Based on 4,200 kg yield last season and ₦255,000 average revenue, maize remains your highest-volume crop. Rotate with legumes in the next cycle to restore soil nitrogen and target a 10% yield increase.",
    lastYield: "4,200 kg", profit: "₦255,000",
  },
  {
    crop: "Cocoa",
    action: "Schedule fungal spray for cocoa in the next 7 days",
    body: "Cocoa achieved the highest profit margin at 74%, with 1,800 kg harvested. Recommend applying shade management techniques and a fungal spray schedule every 21 days to protect pod quality through the next rainy season.",
    lastYield: "1,800 kg", profit: "₦180,000",
  },
  {
    crop: "Groundnut",
    action: "Source early-maturing groundnut seed variety within 2 weeks",
    body: "Groundnut yielded 1,200 bags with ₦162,000 revenue. Introduce early-maturing varieties to capture a second harvest window within the same calendar year and boost annual income from this crop.",
    lastYield: "1,200 bags", profit: "₦162,000",
  },
];

export const aiInsights = [
  { tag: "Cost Optimisation", text: "Your fertiliser spending in Season 2 exceeded your budget by 18%. Consider bulk purchasing through a cooperative to reduce cost per unit next season." },
  { tag: "Revenue Performance", text: "Cocoa delivered your highest margin crop this season at 74% profit ratio. Expanding cocoa acreage by 2 hectares could yield an additional ₦180,000." },
  { tag: "Revenue Performance", text: "Maize revenue has grown by 22% compared to the same season last year, driven by improved yield and stable buyer pricing from Kano Grain Cooperative." },
  { tag: "Cost Optimisation", text: "Labour expenses for weeding account for 31% of total costs. Introducing cover crops could reduce weeding frequency and save approximately ₦12,000 per season." },
  { tag: "Productivity", text: "Your Harvesting activity frequency has increased by 3 events this season compared to last, suggesting improved crop cycle management." },
  { tag: "Productivity", text: "Field activity logging is most consistent in Season 1 and Rainy Season. Logging gaps in Season 3 may be affecting yield tracking accuracy." },
  { tag: "Alerts", text: "No income record has been logged for Sorghum in the last 60 days despite a completed harvest activity. Please confirm sale details to complete your records." },
  { tag: "Alerts", text: "Maize transport costs exceeded seasonal budget by ₦1,700. Monitor road accessibility during peak harvest to plan cost-efficient haulage windows." },
];

export const weeklyReport =
  "Week ending 01/06/2026: You recorded 3 farm activities this week including Harvesting of Maize (4,200 kg), a sales transaction with Kano Grain Cooperative for ₦255,000, and a Seeds expense of ₦15,000. Your farm net position this week is +₦240,000. Top performing crop: Maize. AI Tip: Consider storing a portion of your maize harvest to benefit from post-harvest price increases in 6–8 weeks.";

export const assistantSeed = [
  { role: "user", text: "My maize yield this season was lower than expected. What could have caused this and what should I do differently next time?" },
  { role: "user", text: "How does my cocoa revenue compare to last season?" },
  { role: "ai", text: "Based on your activity logs, your maize field had a gap in Fertilising activities during the critical tasseling stage in Season 1. Late fertiliser application can reduce grain fill significantly. For next season, I recommend applying top-dressing nitrogen fertiliser between 4–6 weeks after planting. I also suggest setting an automatic reminder tied to your planting date so the window is never missed." },
];

export const suggestedPrompts = [
  "What time should I irrigate today?",
  "How can I cut my pump electricity cost?",
  "Which crop should I expand next season?",
  "Summarise this week on my farm",
];

export const reminders = [
  { title: "Fungal spray for cocoa", due: "Jun 14, 2026", tag: "Crop care" },
  { title: "Confirm Sorghum sale record", due: "Jun 12, 2026", tag: "Records" },
  { title: "Top-dress maize (nitrogen)", due: "Jun 20, 2026", tag: "Fertilising" },
];

export const alerts = [
  { type: "Water", text: "Soil moisture in Block B is at 31% — below the 35% comfort range for sorghum at grain-fill stage.", time: "Today, 6:10 am" },
  { type: "Electricity", text: "Grid supply expected to be unstable 12:00–16:00. Pumping during this window risks diesel backup costs.", time: "Today, 5:45 am" },
  { type: "Records", text: "No income record logged for Sorghum in the last 60 days despite a completed harvest.", time: "Yesterday" },
];

export const activities = [
  { date: "Jun 8, 2026", type: "Harvesting", crop: "Maize", note: "4,200 kg from Block A" },
  { date: "Jun 6, 2026", type: "Irrigation", crop: "Sorghum", note: "Night cycle, 2.5 hrs, Block B" },
  { date: "Jun 3, 2026", type: "Weeding", crop: "Cassava", note: "Hired labour, 6 workers" },
  { date: "May 29, 2026", type: "Harvesting", crop: "Soybean", note: "800 tonnes cooperative batch" },
  { date: "May 25, 2026", type: "Harvesting", crop: "Cocoa", note: "1,800 kg, pod quality high" },
];

export const expensesList = [
  { date: "Jun 5, 2026", category: "Seeds", amount: 15000, note: "Improved sorghum variety" },
  { date: "May 30, 2026", category: "Transport", amount: 12700, note: "Maize haulage to Kano" },
  { date: "May 22, 2026", category: "Fertiliser", amount: 46000, note: "NPK top-dressing" },
  { date: "May 18, 2026", category: "Labour", amount: 28000, note: "Weeding crew" },
  { date: "May 10, 2026", category: "Electricity", amount: 9800, note: "Pump grid usage" },
];

export const incomeList = [
  { date: "Jun 1, 2026", buyer: "Kano Grain Cooperative", crop: "Maize", amount: 255000 },
  { date: "May 26, 2026", buyer: "Delta Fresh Processors", crop: "Cassava", amount: 480000 },
  { date: "May 25, 2026", buyer: "Golden Pod Exports", crop: "Cocoa", amount: 180000 },
  { date: "Apr 21, 2026", buyer: "Local market", crop: "Sorghum", amount: 310000 },
];

export const documents = [
  { name: "Land lease agreement.pdf", added: "Jan 12, 2026" },
  { name: "Cooperative membership certificate.pdf", added: "Feb 3, 2026" },
  { name: "Season 2 input receipts.zip", added: "Apr 18, 2026" },
];
