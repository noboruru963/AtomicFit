# Context/INDEX.md — AtomFit overflow context

Read `../AGENTS.md` first. Files here **never override** AGENTS.md Sections 3 (Immutable Rules) and 12 (Behavior Addenda).
Add new files to the right subfolder and list them below. Never delete or rewrite existing files; add a dated replacement note instead.

## 01-requirements  (what to build)
| File | Read it when | Notes |
|---|---|---|
| SOFTWARE_REQUIREMENTS_SPECIFICATION.md | You need exact FR/NFR wording, AC-nnn, traceability, screen list (SCR-xx), data model, TBD register | Authoritative requirements. Draft dated 2026-10-14. FR-015 nav order is superseded by BA-001 |
| Comprehensive_Explanation_of_the_MVP.md | You need the rationale and dev responsibilities for the six MVP stories | Narrative form of the MVP deck |
| mvp_breakdown.md | You want the short task-breakdown per story | Source deck |
| atomicfit_core_features.md | You want Rep Tracker / Save Feature / Quiz concept ideas | Contains the **14-day** quiz trigger (conflicts with MVP's 7 days, see AGENTS.md C-1) |

## 02-discovery  (why we are building it)
| File | Read it when | Notes |
|---|---|---|
| AtomicFit_Compiled_Source_Material_for_SRS.pdf | You need everything in one place: research, personas, journeys, wireframe list, items to reconcile | Best single discovery document |
| persona_2_0.md | You need raw interview findings per persona | 18 Sep 2026 interviews |
| sre_presentation.md | You need survey demographics and the six named personas | Kevin, Joshua, Cindy, Jamie, Tony, Sarah |
| how_might_we.md | You need the 17 HMW questions and Crazy-8 ideas | |
| value_proposition.md | You need value proposition, competitor analysis, Adaptive FlexEngine | |
| flow_presentation.md | You need the core flow and four user journeys | |
| Problems_Detailed_Markdown.md | Historical background only | States the group chose Jonathan's AI Validity Checker; later work is AtomFit. See AGENTS.md C-9 |

## 03-design  (what it looks like)
| File | Read it when | Notes |
|---|---|---|
| Atomic_Fit_Improved_App_Pages.pdf | You need the newest screen content | Preferred layout reference. Includes ease-in explainer, lock-screen concept, Micro filter, Discover tab (Discover/Profile nav is not decided) |
| Medium-Fidelity.pdf | You need earlier screen text/structure | Older than Improved pages |
| AtomFit-High-Fidelity-Prototype.html | You need colors, fonts, interactions, quiz flow behavior | Open in a browser. **Reference only; never copy code.** In-memory, hard-coded data |
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
SRS > MVP explanation > discovery docs > design files for *behavior*;
Improved pages PDF > Medium-fi PDF > HTML prototype for *layout*; HTML prototype for *tokens/typography*.
