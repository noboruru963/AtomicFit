# Context/INDEX.md — AtomFit overflow context (Flutter prototype edition, v2)

Read `../AGENTS.md` first. Files here **never override** AGENTS.md Sections 3 (Immutable Rules) and 12 (Behavior Addenda).
Add new files to the right subfolder and list them below. Never delete or rewrite existing files; add a dated replacement note instead.

**Edition note:** the SRS and other source documents were written for a TypeScript/PWA plan. The project now targets a **Flutter prototype**. Product behavior, requirements, screens, and data model still apply; the SRS copy here was **patched to the Flutter edition on 2026-10-18**; where leftover wording mentions TypeScript or PWA, AGENTS.md wins.

## 00-prototype  (read these first when building)
| File | Read it when | Notes |
|---|---|---|
| PROTOTYPE_BRIEF.md | You need scope tiers (P0/P1/Stretch), the demo script, and what is real vs simulated | Defines "done" for the prototype |
| SCREEN_MAP.md | You are creating or wiring a screen | Route, proposed Dart file, source reference, SCR id, tier for every screen |
| DESIGN_TOKENS.md | You are styling anything | Colors, typography, shapes, and a Flutter `ThemeData` starting point |
| SEED_DATA.md | You are creating demo data, the demo clock, or fixtures | Marks invented data as `[DERIVED]`/placeholder |
| QUIZ_CONFIG.md | You are building the quiz or rule engine | Fixed Q1/Q10, placeholder Q2–Q9, **approved** rule table (BA-010) |
| STORAGE_AND_FIREBASE.md | You are building the data layer, auth, seeding, or anything storage-related | Local persistence now (sembast); Firebase-ready design for later |

## 01-requirements  (what to build)
| File | Read it when | Notes |
|---|---|---|
| SOFTWARE_REQUIREMENTS_SPECIFICATION.md | You need exact FR/NFR wording, AC-nnn, traceability, SCR list, data model, TBD register | Patched to the Flutter edition (technology sections, navigation, gender, Lat pulldown). The screen list and traceability tables may still use older wording; AGENTS.md Section 12 wins |
| Comprehensive_Explanation_of_the_MVP.md | You need the rationale and dev responsibilities per MVP story | Narrative form of the MVP deck |
| mvp_breakdown.md | You want the short task breakdown per story | Source deck |
| atomicfit_core_features.md | You want Rep Tracker / Save Feature / Quiz concept ideas | Contains the 14-day quiz trigger (overridden: 7 days, BA-004) |

## 02-discovery  (why we are building it)
| File | Read it when | Notes |
|---|---|---|
| AtomicFit_Compiled_Source_Material_for_SRS.pdf | You need research, personas, journeys, wireframe list in one place | Best single discovery document |
| persona_2_0.md | Raw interview findings per persona | 18 Sep 2026 |
| sre_presentation.md | Survey demographics and six named personas | Kevin, Joshua, Cindy, Jamie, Tony, Sarah |
| how_might_we.md | The 17 HMW questions and Crazy-8 ideas | |
| value_proposition.md | Value proposition, competitors, Adaptive FlexEngine | |
| flow_presentation.md | Core flow and four user journeys | |
| Problems_Detailed_Markdown.md | Historical background only | Says the group chose the AI Validity Checker; later work is AtomFit (AGENTS.md C-9) |

## 03-design  (what it looks like)
| File | Read it when | Notes |
|---|---|---|
| Atomic_Fit_Improved_App_Pages.pdf | You need the current screen layout and copy | **Primary layout reference.** Some copy is outdated (14+ days, 30% ease-in example) |
| Medium-Fidelity.pdf | You need earlier screen text/structure | Older than the Improved pages |
| AtomFit-High-Fidelity-Prototype.html | You need token values and interaction ideas | Open in a browser. **Reference only; never copy code.** Hard-coded data |
| images/ | Screenshots, logo, wireframes | Empty at packaging time |

## 04-reference
| File | Read it when |
|---|---|
| ReqView-Example_Software_Requirements_Specification_SRS_Document.pdf | You need the SRS template style (ISO/IEC/IEEE 29148 structure) |

## 05-feedback
| File | Notes |
|---|---|
| Feedback_from_one_of_the_IT_lecturer.md | Converted into BA-001/002/003 in AGENTS.md Section 12 |

## Precedence inside Context
`00-prototype` > SRS (behavior, ACs) > MVP explanation > discovery docs.
Layout: Improved pages PDF > Medium-fi PDF > HTML prototype. Tokens: DESIGN_TOKENS.md (from the HTML prototype).
