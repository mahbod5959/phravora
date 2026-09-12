# Phravora completion plan

## Product standard

The product loop remains: professional goal → mission → in-app voice practice → outcome → feedback → Mistake Memory → repair mission → evidence of improvement. No feature may add friction without clear learning value.

## Milestone 4 exit

- TestFlight build launches on a physical iPhone and sends an App Attest-backed callable request.
- Firebase logs show `auth: VALID` and `app: VALID` for that request.
- Remove the temporary TestFlight validation compilation condition and archive a clean successor build.
- Only then enable App Check enforcement for the three callable Functions and repeat Auth/quota regression checks.

## Milestone 5 — mission runtime, without provider credentials

1. Introduce `PracticeSessionViewModel` with explicit states: preparing, requesting permissions, reserving, recording, transcribing, completing, cancelling, retryable failure, and finished.
2. Reserve server quota immediately before a real mission starts; cancel on permission denial/backgrounding; finish with measured elapsed speaking time.
3. Replace transcript-only completion with clear mission outcome states. Never imply AI assessment before it exists.
4. Add typed UX for unauthenticated, integrity failure, quota reached, conflict, rate limit, offline, microphone, and speech-recognition failure.
5. Persist only session metadata locally until the approved privacy/retention policy permits more.

**Acceptance:** a learner can retry a failed reservation, deny permissions without losing quota, resume a safe local state, and complete a bounded mission without leaving Phravora.

## Milestone 6 — realtime conversation and feedback, credential-gated

1. Finalize server-only provider credential issuance, expiry, rate limiting, cancellation, reconciliation, and logging redaction before adding any provider secret.
2. Implement `RealtimeConversationService` behind the existing protocol; audio stays in-app and reconnects conservatively.
3. Make `SessionFeedbackService` return structured, evidence-backed feedback: mission outcome, strengths, one or two high-value repairs, vocabulary reuse, and uncertainty. Never show fabricated scores.
4. Store compact Mistake Memory patterns, not raw transcripts; generate one specific Repair Mission only after a recurring pattern is confirmed.

**Acceptance:** feedback is tied to a mission success criterion and every repair mission naturally elicits its target pattern.

## Milestone 7 — polish, trust, and account continuity

- Native Sign in with Apple links the anonymous Firebase account without losing local/server progress.
- Add account deletion, privacy policy, terms, retention controls, support/contact, and production privacy nutrition labels.
- Complete VoiceOver labels/order, Dynamic Type stress testing, dark-mode screenshots, localization extraction, offline/loading/empty/error states, and App Review demonstration script.
- Remove all development-only/TestFlight validation code and generic placeholder copy.

## Milestone 8 — monetization, separately approved

Use StoreKit 2 only after the free loop is useful. Build a single value-moment paywall, verified transactions, server-reflected entitlement, restore purchases, billing/cancellation copy, and a Free/Premium capability matrix. Never use a client-authoritative premium flag or external checkout.

## Current reviewer risks to resolve before App Review

1. The current TestFlight build contains temporary App Attest validation code; remove it after the validation request succeeds.
2. `Settings` and `Progress` correctly disclose that AI coaching is not connected, but production launch needs the real feedback loop or a narrower non-AI App Store claim.
3. Privacy disclosures must change before recordings, analytics, account linking, remote feedback, or subscriptions ship.
4. Replace internal naming (`TalkDaily`) in all user-visible artifact metadata before public release.
5. Node 20 is deployed but has an announced lifecycle deadline; plan a tested Node 22/24 migration before future deploys.
