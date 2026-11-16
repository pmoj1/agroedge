# AgroEdge — Frontend Design System

Applies to `apps/mobile` and `apps/dashboard`. Read alongside the root `CLAUDE.md`, which governs everything not covered here.

Do not invent a colour. Do not invent a spacing value. Do not invent a font size. If the thing you need is not in this file, stop and ask.

## Two products, one palette, two design languages

`apps/mobile` and `apps/dashboard` are not the same product wearing different sizes.

**The farmer app is low density.** One primary action per screen. Generous whitespace. Large targets. The user is standing in a field, holding the phone one-handed, in direct sunlight.

**The institutional dashboard is high density.** Tables, filters, many things visible at once. The user is a programme officer scanning ten thousand farmer records for anomalies. Whitespace is wasted screen.

Do not homogenise these. Share the *tokens*, not the *components*.

## The farmer's device is the constraint

Buhera. Mahalapye. Serowe. Assume a 3–5 inch screen, ~2GB RAM, an Android several years old, 2G/3G, intermittent and expensive, direct sunlight.

Therefore, in `apps/mobile`:

- **Offline-first.** Never block the UI on a network call. Local write, queue, sync, reconcile.
- Touch targets **>= 48dp**, always. No exceptions for "just an icon."
- No decorative images. No video. No runtime-fetched web fonts — bundle them.
- Contrast >= 4.5:1 for body text, >= 3:1 for large text.
- Every string must survive translation into **Setswana** and **Shona**. Both run longer than English. Never fix a container to the width of its English label. Never truncate a label to make a layout work.
- Never put meaning in colour alone. Pair every status colour with an icon or a word.

## Colour

| Token | Hex | Use |
|---|---|---|
| `forest-900` | `#123F2A` | Mastheads, dark surfaces, dashboard chrome |
| `forest-700` | `#1B5E3B` | Primary action, brand, success |
| `gold-500` | `#C8A24A` | Accent, emphasis, focus ring, warning |
| `cream-100` | `#FBF4E4` | Panels, light surfaces |
| `ink-900` | `#1F1F1F` | Body text |
| `ink-500` | `#6B6B6B` | Secondary text, disabled |

**Error red is not chosen yet.** It will appear in every alert and validation message in both apps. Do not pick one. Stop and ask.

Semantic mapping: success = `forest-700`. Warning = `gold-500`. Error = pending.

`gold-500` is an accent, not a background. Do not fill large areas with it.

## Type

- **Headings, body:** Georgia, fallback Liberation Serif
- **Labels, buttons, tables, numeric data:** Calibri, fallback Liberation Sans

Scale — nothing between these values: `12` `14` `16` `20` `26` `34`

Farmer app body text is `16` minimum. Never `14`, never `12`. Dashboard table text may go to `12`.

## Spacing

Multiples of 4 only: `4` `8` `12` `16` `24` `32` `48`

No `5`, no `15`, no `30`. If a layout needs an in-between value, the layout is wrong.

## The contract layer

Models and API types live in `packages/shared`. Import them. Never redefine a model locally, never write a local interface that shadows a shared one.

If you need a field that does not exist in `packages/shared`, **stop.** Changing the contract is its own pull request, approved by both founders, touching nothing else. This is the single rule that lets five agents work in parallel without collision. Do not route around it.

## Institutional dashboard — data rules

The dashboard shows **aggregates**. Programme-level counts, distributions, trends, anomalies.

It does not render individual farmer personal data — name, phone, national ID — unless the government counterparty owns that data and the query is explicitly scoped to their own programme. Every dashboard query is scoped by programme. There is no unscoped query.

Never log a farmer identifier. Not to console, not to Sentry, not to analytics.

The dashboard is **planned, not built** (root file, language rules). Do not write a comment, README line, or UI string implying otherwise.

## AI agronomist — UI surface

- The assistant answers from three sources only: the farmer's own records, their crop plan, and weather. It does not offer agronomic advice it cannot ground in one of those.
- When it does not know, the UI must say so plainly. A confidently wrong planting date costs someone a season. Design the "I don't know" state before the answer state.
- Never construct a prompt containing a farmer's name, phone, or national ID. Strip or pseudonymise before the call. The call happens in `services/`, never here.
- Every call costs money against a product the farmer does not pay for. Do not poll. Do not call on keystroke. Debounce and require intent.

## When you are unsure

Stop and ask. Do not guess at:

- A colour, size, or spacing value not listed above
- The error red
- A change to `packages/shared`
- Anything rendering farmer personal data
- A new dependency

Guessing is cheap for one agent. It is not cheap across five.
