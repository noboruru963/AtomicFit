# STORAGE_AND_FIREBASE.md — local persistence now, Firebase later

Decided 2026-10-18: the app **stores data locally and keeps it after restart**; a **Firebase database is planned later**. This file defines how to build local storage so Firebase can be added **without rewriting domain logic or UI**. It never overrides AGENTS.md Sections 3 or 12.

**Hard rule for now (F-02, F-33):** no Firebase packages, no `google-services.json`, no `firebase_options.dart`, no network calls. Design for Firebase; do not build it.

## 1. Principles
1. **Domain owns the contracts.** Repository interfaces live in `lib/domain/repositories/`. UI and Blocs depend only on them.
2. **Local implementation is replaceable.** `lib/data/local/` implements the interfaces with sembast. A future `lib/data/firebase/` implements the same interfaces with Cloud Firestore and Firebase Auth. Swapping happens in one place (dependency wiring in `lib/app/`).
3. **Documents, not joins.** Each entity is a self-contained map keyed by a UUID string. Relationships are stored as IDs. Do not rely on SQL-style joins or auto-increment keys.
4. **Every record is user-scoped and sync-friendly:** `id` (UUID v4 string), `userId`, `createdAtUtc`, `updatedAtUtc`, and optional `deletedAtUtc` for soft deletes. Do not add other sync fields now.
5. **Timestamps** are stored as ISO-8601 UTC strings (or epoch milliseconds; pick one and use it everywhere). Local calendar day = UTC time + stored IANA `zoneId`.
6. **Plain JSON types only** in stored maps: `String`, `int`, `double`, `bool`, `List`, `Map`, `null`. No Dart-specific objects, enums as strings, durations as whole seconds, weights as kg `double`.
7. **Atomic operations stay small.** Multi-record operations (micro-save, stitch, unstitch, accept program version) run in **one store transaction** and touch only a handful of records, so they map cleanly to Firestore transactions or batched writes later.

## 2. Local storage design (assumption — confirm)
- **Package:** `sembast` (pure-Dart document store; supports transactions) with `path_provider` for the database file location. *Alternative if the team prefers SQL: `drift`, which needs code generation (currently not allowed).*
- **Stores** (key = record id unless noted): `users`, `profiles` (key = userId), `settings` (key = userId), `exercises`, `programs`, `program_versions`, `sessions`, `set_logs`, `quiz_attempts`, `quiz_answers`, `program_adjustments`, `analytics_events`, `meta` (singleton keys: `schemaVersion`, `seedVersion`, `currentUserId`).
- **Entities** follow the data model in AGENTS.md Section 7. `sessions` holds `type` (`full`/`micro`/`stitched`), `completionStatus`, `parentSessionId` (nullable), `startedAtUtc`, `zoneId`, `durationS`. A stitched parent stores `childSessionIds` (exactly two) and combined metrics; children keep their own `set_logs`.
- **Queries** are done in the data layer; repositories expose `Future` reads and `Stream` watchers (e.g., `watchSessions(userId)`) so Blocs can react to changes.
- **Soft delete:** deleting a session sets `deletedAtUtc` and hides it; hard purge is not needed in the prototype. Aggregates (totals, calendar, counts) must ignore soft-deleted records.

## 3. First launch, seeding, versioning, reset
- On first launch (no `meta.seedVersion`), create the demo user and seed data from `lib/data/seed/` **in one transaction**, then write `meta.seedVersion`. Never re-seed over existing data.
- **Seed dates are relative to the first-launch date** (see `SEED_DATA.md`) so the demo user is inactive for 7+ days at first launch and the quiz prompt appears. After that, time moves normally via the system clock.
- Store `meta.schemaVersion` (int). If the stored version is lower than the app's, run a migration function; for the prototype a documented "wipe and reseed" migration is acceptable when no real user data exists. Do not leave this undefined.
- **Dev tool:** in debug builds only (`kDebugMode`), Settings shows **Reset demo data** (with a confirmation dialog, F-17) that clears all stores and reseeds. It is not part of the product and does not appear in release builds.

## 4. Auth (local now, Firebase Auth later)
- Define `AuthRepository` in domain: `signUp`, `signIn`, `signOut`, `currentUser` (stream), no UI types.
- **Now:** `LocalAuthRepository` stores accounts in `users` (username, email, `passwordHash`, `salt`, DOB, gender). Hash with a per-user random salt using the `crypto` package. *This is prototype-grade and does not meet NFR-036 (slow key-derivation function); it is replaced entirely by Firebase Auth later.* Never store a plain-text password; never log passwords.
- Keep the seeded demo user **Joe123** (any non-empty password accepted only for that seeded account, flagged `// SEED PLACEHOLDER`).
- **Later:** `FirebaseAuthRepository` replaces it; `userId` becomes the Firebase UID. Because all data is already user-scoped, no data-model change is needed.

## 5. Repository interfaces (sketch; names may change but keep the shape)
```dart
// lib/domain/repositories/session_repository.dart
abstract interface class SessionRepository {
  Future<void> save(Session session);                    // idempotent by id
  Future<Session?> getById(String id);
  Stream<List<Session>> watchAll(String userId);         // excludes soft-deleted
  Future<void> softDelete(String id, DateTime nowUtc);
  Future<void> applyStitch(StitchResult result);         // one transaction
  Future<void> applyUnstitch(UnstitchResult result);     // one transaction
}
```
Similar interfaces: `SetLogRepository` (only `SaveSetService` may call its write methods, F-04), `ProgramRepository` (versions, accept, revert), `QuizRepository`, `UserRepository`/`ProfileRepository`, `SettingsRepository`, `ExerciseRepository`, `AnalyticsRepository`, plus `AuthRepository` and `Clock`.
Domain services take repositories through constructors and return results as values; the repository applies them atomically.

## 6. Mapping to Firebase later (for planning only)
| Local store | Likely Firestore path | Notes |
|---|---|---|
| `users`, `profiles`, `settings` | `users/{uid}` (profile and settings as fields or subdocuments) | Auth handled by Firebase Auth, no password fields |
| `programs`, `program_versions` | `users/{uid}/programs/{id}`, `.../versions/{id}` | Built-in programs can live in a shared read-only collection |
| `sessions` | `users/{uid}/sessions/{id}` | Stitched parent references child ids |
| `set_logs` | `users/{uid}/sessions/{sid}/sets/{id}` or embedded in the session | Decide by document-size and query needs |
| `quiz_attempts` / `quiz_answers` / `program_adjustments` | `users/{uid}/quizAttempts/{id}` (answers embedded) | |
| `analytics_events` | likely **not** synced, or a separate collection | Privacy decision (TBD-23, TBD-25) |
| `exercises` | shared read-only `exercises/{id}` | |

Open decisions for the Firebase phase (do **not** decide now): offline strategy (Firestore's own cache vs keeping sembast as a local cache), merge/conflict policy (last-write-wins on `updatedAtUtc` is the likely default), security rules, data-retention and privacy (TBD-25), migration of existing local data to a signed-in account.

## 7. Do and don't now
**Do:** program to interfaces · UUID ids · user-scoped records with `createdAtUtc`/`updatedAtUtc`/`deletedAtUtc` · plain JSON maps with handwritten `toMap`/`fromMap` · one transaction per multi-record operation · contract tests that run the same suite against any repository implementation (so the future Firebase version can be verified against it).
**Don't:** import sembast outside `lib/data/local/` · let Blocs or widgets touch stores · add Firebase packages or config · use auto-increment ids · store Dart objects or enums as raw values · persist raw sensor samples or audio (F-22).

## 8. Tests that must exist
- Repository contract tests (run against the sembast implementation using a temporary/in-memory database): save is idempotent; soft-deleted records are excluded; stitch/unstitch leave no partial state when forced to fail; reopening the database returns previously saved data (**survives restart**).
- First-launch seeding runs once; re-opening does not duplicate seed data.
- Migration test: an older `schemaVersion` triggers the documented migration.
- Local auth: wrong password is rejected; stored record contains a salt and hash and no plain-text password.
