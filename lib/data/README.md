# Data layer

Everything the UI knows about persistence lives behind `AtomFitStore`
(`lib/data/store.dart`). Screens never import this folder.

## Today: `LocalBlobStore`

One JSON document in `shared_preferences` under the key `atomfit_app_v23` — the
same key the web prototype uses, so the two can be reasoned about together.

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
