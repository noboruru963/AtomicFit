# Security notes

AtomicFit keeps workouts, sets, programs and notes **on the phone** (SQLite).
Firebase is used only for accounts and the profile document.

| Data | Where |
|---|---|
| Email, password | Firebase Authentication (password never reaches the app or the repo) |
| Username, gender, date of birth, weight, height | `users/{uid}` in Firestore |
| Workouts, sets, programs, notes | On-device SQLite only |

## Before shipping a build

### 1. Firestore rules

`firestore.rules` in this repo is the source of truth: a signed-in user may
read and write **only their own** `users/{uid}` document, and every other path
is closed.

```bash
firebase deploy --only firestore:rules
```

Check in the Firebase console → Firestore → Rules that the deployed rules match
this file. The default "test mode" (`allow read, write: if request.auth != null`)
would let **any** registered user read every profile.

### 2. API key restriction

`android/app/google-services.json` is committed so the app can be built from a
clean clone. Its API key is therefore public — that is normal for Firebase, but
the key must not be usable from anywhere.

In Google Cloud console → APIs & Services → Credentials → the Android key:

- **Application restrictions:** Android apps
- Add package name `com.example.atomfit` with the SHA-1 of the signing key
  (`./gradlew signingReport` prints it)
- **API restrictions:** limit to Identity Toolkit, Firestore and Firebase
  Installations

An unrestricted key lets anyone create accounts against the project and burn
the quota.

### 3. App Check (recommended)

Enable App Check for Firestore with the Play Integrity provider. Note that Play
Integrity requires the app to be distributed through Play; for the sideloaded
demo APK it will not attest, so do not turn on *enforcement* until the app is
shipped through a store, or the demo build stops working.

### 4. Account data

There is no "delete my account" action yet. Signing out leaves the Firestore
document in place, so a removal request currently has to be handled by hand in
the console. Add a delete flow before handling real user data.
