# QUIZ_CONFIG.md — quiz questions and draft rule table

Decisions already made (AGENTS.md BA-004): inactivity trigger **7 days** · **10 questions** · when a weight reduction applies it is **10–20%** · flow Q10 → "Why we changed your program" → Adjusted program → Accept program / Keep my old program.
**The rule table in Section 3 was approved by the team on 2026-10-18 (BA-010).** Everything marked **PLACEHOLDER** (Q2–Q9 wording) is **not approved**. Implement it as typed config (`lib/domain/rules/quiz_questions.dart`, `ease_in_table.dart`) so it can be replaced without touching UI or engine code, and report it as an assumption.

## 1. Question list
Each question: `key`, `text`, `options[]` (`key`, `label`). One per screen, progress "n/10", Next disabled until answered, Back from Q2. Every screen shows: *"Non-diagnostic quiz · used only to adjust your workouts"*.

| # | Key | Text | Options | Status |
|---|---|---|---|---|
| 1 | `target` | What is your current fitness target? | Muscle gain · Staying healthy · Look fit · No target | **Fixed** (IP, MF, SRS FR-078) |
| 2 | `days_per_week` | How many days a week can you train? | 2 days · 3 days · 4 days · 5+ days | Candidate from HF (SRS FR-081); wording to confirm |
| 3 | `energy` | How is your energy today? | High, ready to go · Normal · Low, take it easy | Candidate from HF (SRS FR-079); wording to confirm |
| 4 | `motivation` | How motivated do you feel to train right now? | **PLACEHOLDER** options (e.g., Very · Somewhat · Not much) | MVP text requires a motivation question; wording TBD-10 |
| 5–9 | `q5`…`q9` | **PLACEHOLDER** questions covering topics the team chooses (e.g., available session time, sleep, soreness, equipment, preferred split) | **PLACEHOLDER** | **Need team wording (TBD-10)** |
| 10 | `push` | Do you still want to push? | Yes, progress the weight · No, same program as last · No, reduced intensity | **Fixed** (IP, MF, SRS FR-082). Button: **See what changed** |

Placeholder questions must be visibly marked in code (`// PLACEHOLDER (TBD-10)`) and must **never** be diagnostic in tone (no health, mood-disorder, or injury-assessment wording; AGENTS.md F-10).

## 2. Adjustment outputs
The rule engine returns one `Adjustment`:
`sessionLength` (e.g., short / normal) · `intensity` (e.g., lighter / same / progress) · `frequency` (days per week) · `weightReductionPercent` (0, or 10–20) · optional `setsDelta`.
`Adjusted program` = copy of the Current program version with weights multiplied by `(1 − reduction)` rounded to the nearest 0.5 kg, then stored as a **new `program_version`** only after Accept. Keep the previous version for revert.

## 3. Rule table (APPROVED 2026-10-18; BA-010)
Precedence (first match wins):
1. If `push` = **Yes, progress the weight** → reduction **0%**, intensity **progress**.
2. If `push` = **No, same program as last** → reduction **0%**, intensity **same**.
3. If `push` = **No, reduced intensity** → apply the energy-based reduction below, intensity **lighter**.

Energy-based reduction (only for rule 3):
| `energy` | Reduction |
|---|---|
| Low, take it easy | **20%** |
| Normal | **15%** |
| High, ready to go | **10%** |

Frequency: use `days_per_week` (2/3/4/5+), capped to a safe maximum of 5.
Session length: `short` when energy is Low **or** motivation is lowest; otherwise `normal`.
Safety limits (hard): reduction is never below 10% nor above 20% **when it applies**; never increase weight by more than one program step when `push` = progress (step size default +2.5 kg).

Assumptions made by approving the table as written (tell the agent if any is wrong): (a) answering *No, same program as last* applies no ease-in; (b) sets do not decrease (`setsDelta = 0`); (c) there is **no weekly ramp-back** in the prototype (the Improved pages' 4-week ramp is not built); (d) the progress step defaults to +2.5 kg. Still open: final Q2–Q9 wording (TBD-10).

## 4. Explainer screen example ("Why we changed your program")
The Improved pages' example (10 kg → 7, 8, 9, 10 kg over four weeks) used a 30% cut and **no longer matches the decision**. Use an example consistent with 10–20%, e.g. **20% reduction: 10 kg → 8 kg** (no weekly ramp in the prototype). Compute the example from the same table; do not hard-code numbers in the widget.

## 5. Tests that must exist (domain, pure Dart)
- 6 days since last workout → not inactive; 7 → inactive (calendar-day math with an injected clock and zone).
- Each row of the rule table → expected `Adjustment`.
- Any reduction falls in [10%, 20%]; rounding to 0.5 kg; 0% cases leave weights unchanged.
- Preview does not change the Current program; Accept creates a new version and keeps the old; Revert restores it.
- Abandoned quiz stores an attempt with status `incomplete`.
