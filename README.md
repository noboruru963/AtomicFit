# AtomFit

Local-first, mobile-first workout tracker for Android. Purpose: **consistency, not
perfection**. Tagline: *"Log it. Keep going."*

The UI is a native Flutter port of the team's `index.html` prototype (the
`Argon-2.0` branch design), and the data lives in a real on-device SQLite
database.

## Architecture

```
lib/
├─ app/            router, app chrome (top bar, bottom nav), screen ids
├─ data/
│  ├─ db/          the database layer
│  │  ├─ app_database.dart        opens + migrates the SQLite database
│  │  ├─ schema.dart              tables, indexes, migration steps
│  │  ├─ sqlite_store.dart        AtomFitStore over the relational tables
│  │  ├─ exercise_repository.dart catalogue queries (search, filters, paging)
│  │  ├─ catalogue.dart           pure label/format/search rules
│  │  ├─ catalogue_loader.dart    asset -> Exercise records
│  │  ├─ password_hasher.dart     salted password hashing
│  │  ├─ legacy_migration.dart    the previous JSON blob -> the database
│  │  └─ bootstrap.dart           first-run catalogue import
│  ├─ seed_data.dart demo programs, history and quiz questions
│  └─ store.dart                  the AtomFitStore seam
├─ models/         plain immutable records with a JSON envelope
├─ screens/        one file per screen
├─ services/       pure rules (personal-details validation)
├─ state/          the app state (the prototype's global `appState`)
├─ strings.dart    every user-facing string
├─ theme/          colours, typography, shapes
└─ widgets/        the shared widget set
```

Dependency direction: `screens → state → data → models`. The UI never talks to
the database directly, and the persistence seam (`AtomFitStore` +
`ExerciseRepository`) is what a later Firebase backend would implement.

## The database

| table         | holds                                                        |
|---------------|--------------------------------------------------------------|
| `accounts`    | e-mail, username, **salted password hash**, personal details  |
| `exercises`   | the 650 record RepDB catalogue + the user's own exercises     |
| `programs`    | training programs and their exercises                         |
| `sessions`    | finished workouts (full / micro / stitched)                   |
| `set_logs`    | the logged sets of every session                              |
| `settings`    | preferences, theme, session flag                              |
| `app_state`   | key/value: the active workout draft, quiz answers             |

* Passwords are **never** stored in clear text — every account holds a random
  salt plus the SHA-256 digest of `salt::password`.
* The exercise catalogue is the [RepDB](https://repdb.co) free tier, bundled as
  `assets/data/exercise_catalogue.json` and imported once on first launch.
  Exercise pictures are loaded from `exercise-dataset.com`; offline they fall
  back to a placeholder.
* Data of the previous (JSON blob) build is moved into the database once by
  `LegacyMigration`.

## Running it

```bash
flutter pub get
flutter run                 # on a connected device or emulator
```

## Quality gates

```bash
dart format .
flutter analyze             # must report zero issues
flutter test                # 87 tests
flutter build apk --release
```

## Demo accounts

| user     | e-mail             | password      |
|----------|--------------------|---------------|
| `Joe123` | `joe@example.com`  | `password123` |
| `Alex`   | `alex@example.com` | `password123` |

Either the user name or the e-mail works as the sign-in identifier.

## Demo script (about 3 minutes)

1. **Log in** — `joe@example.com` / `password123`.
2. **Personal details** — the first launch of an account asks for a user name,
   date of birth, gender, weight and height; the form rejects bad values and
   names the field.
3. **Home** — the calendar marks the days you trained, the monthly count is
   there, the quiz banner offers a program adjustment.
4. **Discover** — search `squat` (or any muscle, body part or equipment),
   pick a body-part pill, open a result for the instructions, illustrations
   and form tips, and add it to the workout.
5. **Workout** — log a set, watch the rest timer run, and finish the workout
   to see the summary.
6. **History** — the new session is at the top; the micro sessions can be
   stitched into one and unstitched again.
7. **Profile / Settings** — the personal details, the theme switch and the
   RepDB credits.
8. **Restart the app** — everything is still there: it lives in the database.

## Branches

| branch           | what it holds                                              |
|------------------|------------------------------------------------------------|
| `argon-2-native` | **the current work**: the SQLite backend and the native port of the `Argon-2.0` design |
| `main`           | the previous native port plus the two HTML prototypes       |
| `Argon-2.0`      | the team's branch (untouched by this work)                  |

`argon-2-native` is not merged yet.

## Known gaps

- The new screens have not been reviewed on a physical device yet.
- Exercise images need a network connection.
- Real sensors, speech recognition and the lock-screen widget are not
  implemented (the prototype simulates them).
