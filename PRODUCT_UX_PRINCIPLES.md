# Phravora product UX principles

## North star

For normal use, a learner completes their full learning journey inside Phravora:

`Open → choose goal → start mission → speak → receive feedback → see improvement → next mission`

The app is guest-first. Do not force account creation before the learner receives value. Anonymous identity must remain linkable later, so progress is retained when Sign in with Apple is added.

## Friction budget

- Onboarding collects only level, role, goal, difficult situations, and a daily target; it should lead directly to a first mission.
- The home screen prioritizes Today’s Mission, a useful repair prompt, and progress evidence—not generic chat or a large catalogue.
- Voice, feedback, Mistake Memory, repair missions, history, settings, and support are native in-app flows.
- Each new surface must answer: does it shorten the learner’s path or add measurable learning value? If neither, do not add it.

## Permissions and resilience

Ask for microphone and speech-recognition access in context, immediately before their value is needed. Explain why, show a useful unavailable state, and provide retry/settings guidance without blocking exploration. Every remote flow needs loading, offline, retry, and typed error states.

## Accessibility and trust

Support Dynamic Type, VoiceOver, dark mode, localization readiness, clear privacy/legal screens, account deletion, and minimal retention of sensitive speech content. Never display authentication or App Check tokens. Keep quota, sessions, and entitlement decisions server-authoritative.

## Mission conversation visual language — next milestone

Keep the professional mission loop visual and conversation-like rather than text-heavy. During a mission, clearly distinguish partner speaking/listening from the learner’s turn with avatars or illustrations, microphone and speaker states, and subtle recording/audio animation. A learner should be able to understand the conversation state without reading lengthy instructions. This requirement is intentionally documented only; it is not part of the current App Check validation work.

## Native subscriptions — future only

Use StoreKit 2 and App Store subscriptions only: no browser checkout. Present Free versus Premium at value moments, not on every entry. A paywall must clearly state price, billing period, auto-renewal/cancellation terms, and Restore Purchases. Verified entitlement is reflected by the backend; the client never invents premium access.
