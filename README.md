# Phravora (Xcode project: TalkDaily)

Structured English speaking practice for work and career. **Phravora** is the
customer-facing product name; `TalkDaily` remains the internal Xcode project
name only (see `PRODUCT_POSITIONING.md`).

The product helps non-native English speakers practise the professional
conversations that affect their career — interviews, meetings,
presentations, client calls, and networking — through short, structured
"missions." It is not positioned as a general AI tutor or open-ended chat
product.

## Repository layout

- `TalkDaily/` — the iOS app (SwiftUI). Open `TalkDaily.xcodeproj` in Xcode.
- `TalkDaily.xcodeproj/` — Xcode project. Source files are listed explicitly
  in `project.pbxproj` (not Xcode 16 file-system-synchronized groups), so a
  newly added `.swift` file must also be added to the project for Xcode to
  compile it.
- `backend/` — Firebase Cloud Functions backend (Node 20, TypeScript).
  `npm run build` compiles `src/` to `lib/` (tsc); `npm test` runs the
  Vitest suite in `src/`.
- `hosting/` — Firebase Hosting static assets.
- `firebase.json`, `.firebaserc`, `firestore.rules` — Firebase project
  configuration.
- Planning / product docs: `PRODUCT_POSITIONING.md`,
  `PRODUCT_UX_PRINCIPLES.md`, `PRODUCT_COMPLETION_PLAN.md`,
  `VISUAL_UX_REDESIGN_PROPOSAL.md` (proposal only — no production UI is
  changed by that document), `MISSION_SYSTEM.md`, `LEARNING_LOOP.md`,
  `FUTURE_MILESTONES.md`, `APP_STORE_LISTING_DRAFT.md`,
  `APP_STORE_RELEASE.md`.

## Building the iOS app

- Xcode 16 or later, iOS 18.0+ deployment target.
- Requires `TalkDaily/GoogleService-Info.plist` (already present in this
  repo) to initialize Firebase.
- Auth is anonymous only — there is no email/password sign-in flow.

## Project rules worth knowing before you touch things

- Don't add App Check, StoreKit, or realtime-AI-provider work without
  reviewing `PRODUCT_UX_PRINCIPLES.md` and `VISUAL_UX_REDESIGN_PROPOSAL.md`
  first — several of those are explicitly future-only / non-goals.
- Never claim real-time AI coaching/feedback in UI copy; the current build
  is honest that this isn't connected yet (see the "Coaching" section of
  Settings for the exact wording to preserve).
- `Package.resolved` is committed on purpose (see `.gitignore`) so every
  machine resolves the same Firebase SDK version — this project broke more
  than once from a Firebase package-graph mismatch.
