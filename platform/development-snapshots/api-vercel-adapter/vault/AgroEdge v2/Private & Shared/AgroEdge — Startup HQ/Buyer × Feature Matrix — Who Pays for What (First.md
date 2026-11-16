# Buyer × Feature Matrix — Who Pays for What (First Customer Pick)

> **TL;DR** — Farmers feel the problems but can't pay. Under B2G, the buyer with the budget is the **government** — national agricultural programmes already spend to register and support these farmers. The sharpest *first* customer is a **national programme** (self-funded like Botswana's Temo Letlotlo, or donor-funded like Zimbabwe's IDEA registry): it pays per-farmer / per-programme for exactly what the MVP already does — a clean farmer registry plus an M&E / impact dashboard. **Lenders and insurers are the highest-value endgame but come last** — they only pay once you have months of farmer data proving the credit score predicts repayment.
> 

## The matrix

How much each buyer values each existing MVP feature. *Core* = a thing they'd pay for. *Supporting* = strengthens the case. *Low* = nice-to-have.

| MVP Feature | Government / National Programme | Donor / Development Funder | Lender / Input Financier / Insurer |
| --- | --- | --- | --- |
| Farm Profile | **Core** — national farmer registry / identity | Supporting — verified beneficiary base | **Core** — borrower identity / KYC |
| Activity Logger | **Core** — programme adoption & input-use tracking | Supporting — proof of delivery | **Core** — behavioural data for risk |
| Expense Tracker | **Core** — input/cost baseline per farmer | Supporting — value-for-money evidence | **Core** — affordability signal |
| Income Tracker | **Core** — yield & income outcomes (programme KPI) | **Core** — income change = headline impact | **Core** — repayment-capacity signal |
| Dashboard analytics | **Core** — programme M&E + national reporting *(the thing they buy)* | **Core** — donor / impact reporting | Supporting — portfolio risk view |
| AI Insights | **Core** — where to target inputs & support | Low | **Core (later)** — credit / loan-readiness score |

## Buyer 1 — Government / National Agricultural Programme  ✅ start here

- **What they pay for:** A clean national farmer registry + the Dashboard as a programme monitoring & national-reporting layer. Programmes must show farmers-reached, input use, and yield/income outcomes — today that's done manually and expensively.
- **Two funding routes:** (a) self-funded programmes that pay from their own budget — Botswana's **Temo Letlotlo**; (b) donor-funded registries where AfDB / FAO / World Bank underwrite the spend — Zimbabwe's **IDEA**.
- **Willingness to pay:** High and budgeted. Programmes already carry M&E and digitisation line items; they pay per-farmer or per-programme.
- **Wedge feature:** Dashboard analytics over Farm Profile + Income/Expense data, in the programme's reporting format.
- **Why first:** Needs *only* what the MVP already does. No credit-scoring history required. Funds your data accumulation while you build toward the lender play.
- **The catch:** Procurement and tender cycles are slow — start with a small paid pilot (one district/province, one season) inside a programme that already has budget.

## Buyer 2 — Donor / Development Funder  ↪ underwrites the pilot

- **What they pay for:** Impact they can report — verified farmers reached, income change, value-for-money. They fund the programme that buys you.
- **Willingness to pay:** Via the programme budget, not directly — they're the reason a donor-funded registry (e.g. Zimbabwe IDEA) can afford you.
- **Wedge feature:** M&E / impact dashboard exportable in donor format.
- **Why they matter:** They de-risk entry into markets that can't self-fund, and a strong impact story with one funder opens doors to others (AfDB → FAO → World Bank).
- **The catch:** Project-based and lumpy (ends with the grant cycle); reporting must be in *their* format.

## Buyer 3 — Lender / Input Financier / Insurer  💰 endgame

- **What they pay for:** The data trail itself, turned into a credit / loan-readiness score that lowers default risk. This is where the real per-farmer margin sits — they earn on the loan, so they'll pay for data that de-risks it.
- **Willingness to pay:** Highest per farmer.
- **Wedge feature:** AI Insights repurposed as a risk score (your V3 item).
- **Why last:** Chicken-and-egg. You need months of logged farmer data before the score is credible, and lenders won't pay until you can show the data predicts repayment.
- **The catch:** Longest sales cycle; requires a proven track record first. Monetisation *phase 2*, powered by the data *phase 1* generates.

## The sequence (one clean story)

**Government programme pays for the registry + intelligence → accumulated data enables credit scoring → lenders pay the premium.** Each phase pays for the next, and the same MVP serves all three — you're just selling a different slice of it to each.

## First customer to chase

One national agricultural programme in a priority market (start: **Botswana, Zimbabwe, Mozambique**) that already registers smallholders and has to report farmer-level outcomes. Sell them the farmer registry + M&E dashboard, priced per farmer. **Botswana's Temo Letlotlo** (≈105,000 farmers, self-funded, no intelligence layer) is the cleanest first door — and your best reference story for the investor. That's the shortest path to first revenue *and* the start of the data moat.

## What to validate next (don't skip)

This matrix is a hypothesis — same caveat as the User Research personas. Before committing the build, talk to **2–3 real buyers** and confirm:

- **Programme / ministry:** do they hold a digitisation / M&E budget, what reporting do they owe (and to whom), and would they pay per farmer?
- **Donor:** would a development funder underwrite a pilot, and what impact evidence do they need?
- **Lender:** what would the score need to prove before they'd pay, and over how many seasons?

The answers tell you which single feature to harden first.