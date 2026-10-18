# SCREEN_MAP.md — screens, routes, files, fidelity

Routes use `go_router`. Paths and file names are **proposals**; keep them consistent once created. Source column: **IP** = `Atomic_Fit_Improved_App_Pages.pdf` (primary layout reference), **MF** = medium-fidelity PDF, **HF** = HTML prototype, **MVP** = MVP text (no design exists; design it with the tokens in `DESIGN_TOKENS.md`). SCR IDs are the SRS traceability keys.

Tiers: P0 must demo · P1 should demo · S stretch (see `PROTOTYPE_BRIEF.md`).

## Shell and global
| Route | Screen | File | Source | Tier | Notes |
|---|---|---|---|---|---|
| (shell) | Bottom navigation `Home \| History \| Discover \| Profile` | `lib/app/shell/app_shell.dart` | IP + lecturer | P0 | BA-001: Home leftmost; **highlighted and not tappable while on Home** (`aria-current` equivalent: `Semantics(selected: true)` + `onTap: null`) |
| (top bar) | Header with bell + **⋮ menu** → Settings | `lib/app/shell/app_top_bar.dart` | IP + lecturer | P0 | BA-003; bell is decoration (TBD-29), no notifications feature |

## Auth
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| `/login` | Login | `lib/features/auth/login_screen.dart` | IP | 01 | P0 |
| `/register` | Register (+ gender, BA-002) | `lib/features/auth/register_screen.dart` | IP | 02 | P0 |

## Home and quiz
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| `/home` | Home (calendar, count, Continue last workout, Empty workout, My programs) | `lib/features/home/home_screen.dart` | IP | 03 | P0 |
| (sheet on `/home`) | Quiz prompt "Let's restart at your pace" — Start quiz / Not now | `lib/features/quiz/quiz_prompt_sheet.dart` | IP | 18 | P0 |
| `/quiz/:n` | Quiz question n of 10 | `lib/features/quiz/quiz_question_screen.dart` | IP, MF | 06 | P0 |
| `/quiz/why` | "Why we changed your program" (ease-in explainer; example uses 10–20%) | `lib/features/quiz/quiz_why_screen.dart` | IP | — | P0 |
| `/quiz/preview` | Adjusted program — Accept program / Keep my old program | `lib/features/quiz/adjusted_program_screen.dart` | IP | 07 | P0 |

## Programs and discovery
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| `/programs` | My programs (Adjusted program tagged New, built-ins, New empty workout) | `lib/features/programs/programs_screen.dart` | IP | 08, 09 | P0 |
| `/programs/:id` | Program detail + Edit with "Confirm edit?" dialog | `lib/features/programs/program_detail_screen.dart` | MF, HF | 10 | P0 |
| `/discover` | Discover (exercise library, search) | `lib/features/discover/discover_screen.dart` | IP | 11 | P0 |
| `/workout/add-exercise` | Add exercise picker (search; All/Push/Pull/Legs) | `lib/features/workout/add_exercise_screen.dart` | IP | 11 | P0 |

## Workout
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| `/workout/active` | Active workout (program) with Add set, rest bar, Finish | `lib/features/workout/active_workout_screen.dart` | IP | 12 | P0 |
| `/workout/empty` | Empty workout (Add exercise, Add set, Finish) | `lib/features/workout/empty_workout_screen.dart` | IP | 13 | P0 |
| `/workout/rest-timer` | Rest timer (−15s/+15s, Pause, Skip, "Show on lock screen" is concept only) | `lib/features/rest_timer/rest_timer_screen.dart` | IP | 14 | P0 |
| `/workout/complete` | Workout complete (time, sets; PRs/volume chart held) | `lib/features/workout/workout_complete_screen.dart` | IP | 15 | P0 |
| (sheet) | Quick-add bar (+1 rep / +1 set) inside active workout | `lib/features/workout/quick_add_bar.dart` | MVP | 21 (in-app) | P1 |
| `/workout/count` | Auto-count live counter (simulated signal), +1/−1, editable final count, error state | `lib/features/autocount/auto_count_screen.dart` | MVP | 19 | P1 |
| (sheet) | Voice logging: phrase input → confirmation card (confirm/edit/cancel) → retry message | `lib/features/voice/voice_log_sheet.dart` | MVP | 20 | P1 |
| (concept) | Lock-screen concept card (UI only) | `lib/features/lockscreen/lockscreen_concept_screen.dart` | IP | 21 | P1 |

## Micro sessions and stitching
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| (sheet) | Exit sheet: Save as micro session / Discard (confirm) / Continue workout | `lib/features/microsession/exit_sheet.dart` | MVP | 22 | P1 |
| `/history/:id` (micro) | Micro-session detail with completed summary and **Resume** | `lib/features/history/history_detail_screen.dart` | IP + MVP | 23 | P1 |
| `/history` (selection mode) | Select exactly two sessions; eligibility message | `lib/features/stitching/stitch_selection.dart` | MVP | 24 | P1 |
| `/history/stitch/preview` | Combined metrics preview + Confirm | `lib/features/stitching/stitch_preview_screen.dart` | MVP | 24 | P1 |
| (card in `/history`) | Expandable stitched card + Unstitch dialog | `lib/features/stitching/stitched_card.dart` | MVP | 25 | P1 |

## History, profile, settings
| Route | Screen | File | Source | SCR | Tier |
|---|---|---|---|---|---|
| `/history` | History list (filter All/Full/Micro, search, delete with confirm) | `lib/features/history/history_screen.dart` | IP | 16 | P0 |
| `/history/:id` | History detail (read-only table) | `lib/features/history/history_detail_screen.dart` | IP | 17 | P0 |
| `/profile` | Profile (username, email, DOB, **gender**, weight, height; Update profile; Log out) | `lib/features/profile/profile_screen.dart` | IP | 04 | P0 |
| `/settings` | Settings (Appearance light/dark, persisted; Personalization "Coming soon"; About app; debug builds only: Reset demo data) | `lib/features/settings/settings_screen.dart` | IP | 05 | P0 |

## Held (do not build until approved — AGENTS.md 9.5)
Units toggle · target weight · PR/volume/muscle charts · workout tags · rest-timer sound and quiz-reminder toggles.
