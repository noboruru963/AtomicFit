# Data layer

Everything the UI knows about persistence lives behind `AtomFitStore`
(`lib/data/store.dart`). Screens never import this folder.

## Today: SQLite (`sqflite`)

The app stores everything in a local SQLite database (`atomfit.db`), opened by
`AppDatabase` (`lib/data/db/app_database.dart`) with a versioned schema
(`lib/data/db/schema.dart`). `SqliteStore` implements the `AtomFitStore`
document contract on top of the relational tables:

| document key       | table                                     |
|--------------------|-------------------------------------------|
| `user`, `accounts` | `accounts`                                |
| `settings`         | `settings`                                |
| `programs`         | `programs`                                |
| `history`          | `sessions` + `set_logs`                   |
| `activeWorkout`    | `app_state` (key/value)                   |
| `catalogue`        | `exercises` (via `ExerciseRepository`)    |

* **Accounts** store a salted SHA-256 hash (`password_hash` + `password_salt`),
  never a plain-text password.
* The **exercise catalogue** is the 650 record RepDB dataset, bundled as
  `assets/data/exercise_catalogue.json` and imported once on first launch
  (`DatabaseBootstrap.ensureCatalogue`). `ExerciseRepository` answers the
  Discover search, body-part filters, result count and pagination with SQL.
* **Legacy data**: the previous build stored everything in one JSON blob
  (`atomfit_app_v23`) in `shared_preferences`. `LegacyMigration` moves that
  blob into the database once, on the first launch of the database build.
  `shared_preferences` is kept for that one-off read only and can be dropped
  once every device has migrated.

### Layout

```
lib/data/
├─ db/
│  ├─ app_database.dart       opens + migrates the database
│  ├─ schema.dart             tables, indexes, migration steps
│  ├─ sqlite_store.dart       AtomFitStore over the relational tables
│  ├─ exercise_repository.dart catalogue queries (search, filters, paging)
│  ├─ catalogue.dart          pure label/format/search rules
│  ├─ catalogue_loader.dart   asset -> Exercise records
│  ├─ password_hasher.dart    salted password hashing
│  ├─ legacy_migration.dart   the previous JSON blob -> the database
│  └─ bootstrap.dart          first-run catalogue import
├─ seed_data.dart             demo programs, history and quiz questions
└─ store.dart                 the AtomFitStore seam
```

```jsonc
{
  "schemaVersion": 1,
  "seedVersion": 1,
  "user":      { /* AppUser      */ },
  "settings":  { /* AppSettings  */ },
  "catalogue": [ /* Exercise[]   */ ],
  "programs":  [ /* Program[]    */ ],
  "history":   [ /* WorkoutSession[] */ ],
  "activeWorkout": { /* ActiveWorkout */ },
  "isDarkMode": false,
  "isProgramAdjusted": false,
  "adjustmentFactor": 0.9
}
```

## Later: Firebase / Firestore

No Firebase package is used yet. When it is added, implement `AtomFitStore`
(or one repository per aggregate) against Firestore and change a single line in
`lib/main.dart`. The mapping is 1:1:

| Local key      | Firestore collection / document             | Notes                                    |
|----------------|--------------------------------------------|------------------------------------------|
| `user`         | `users/{uid}`                              | `userId` field == document id             |
| `settings`     | `users/{uid}/settings/{settingId}`         | one document per settings record          |
| `catalogue`    | `exercises` (query `userId == uid`)        | catalogue is shared per user              |
| `programs`     | `programs` (query `userId == uid`)         | `active` flag == exactly one current      |
| `history`      | `sessions` (query `userId == uid`)         | `setsDetail` == subcollection `setLogs`   |
| `activeWorkout`| `activeWorkouts/{uid}`                     | one draft per user                        |

## Record envelope

Every record carries the fields a document database expects, so the same Dart
objects can be stored locally and remotely without conversion:

```jsonc
{
  "id": "s_1729420000000",
  "userId": "u_alex_01",
  "createdAtUtc": "2026-10-21T08:14:00.000Z",
  "updatedAtUtc": "2026-10-21T08:14:00.000Z",
  "deletedAtUtc": null
}
```

* All values are plain JSON types (no `DateTime`, no nested class instances).
* Relationships are ids only: `sessionId`, `programId`, `exerciseId`.
* Timestamps are ISO-8601 UTC strings. Display formatting happens in the UI.
* `deletedAtUtc` is reserved for soft deletes (a hard delete simply omits it).
