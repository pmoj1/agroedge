# services/integrations — Third-Party Adapters

**Owner: Agent B3.** Do not edit `apps/`, `services/api/`, or `packages/shared`.

## Purpose
Every external dependency lives behind an adapter in this package. Nothing else in
the codebase imports a vendor SDK directly.

## Adapters
| Adapter | Vendor | Notes |
|---|---|---|
| `ai/` | Anthropic Claude API | AI agronomist |
| `sms/` | Africa's Talking | Alerts, reminders, USSD |
| `weather/` | Open-Meteo, Tomorrow.io fallback | Forecasts, drought/frost alerts |

## Non-negotiables

**AI (`ai/`)**
- The Claude API is called server-side only. The API key never reaches a client.
- **Strip PII before constructing any prompt.** No names, no phone numbers, no
  national ID, no precise GPS. Send crop, region-level location, and the farmer's
  own agronomic records only.
- Every prompt and response is logged with a pseudonymous farmer reference for
  quality review, retained per the data retention policy.
- Multilingual output quality for Setswana, Shona and Ndebele is **not guaranteed**
  by the model. Route low-resource languages through a review path and validate with
  real farmers during UAT before enabling in production.
- Never let the model give advice that could destroy a season. Pesticide dosage,
  chemical application rates, and anything with an irreversible outcome must be
  templated from a verified agronomic source, not generated freely.
- Hard cost ceilings per farmer per month. Fail closed with a cached or templated
  response, never with an unbounded spend.

**SMS (`sms/`)**
- SMS costs real money per message and is the largest line item at scale. Every send
  is metered and attributed to a programme.
- Never send unsolicited messages. Consent is per-farmer and revocable.
- Message length matters. Compose for a single 160-character segment where possible.

**Weather (`weather/`)**
- Cache aggressively. Weather for a ward is the same for every farmer in it.
- Never present a forecast as a certainty. Always attach the confidence and the
  issue time.

## Port
Runs on `:3001` locally.
