# Phravora visual-first UX redesign proposal

**Status:** proposal only. No production UI, assets, navigation, Firebase, or mission behaviour is changed by this document.

## Goal

Phravora should help a learner understand a professional situation and their next action before they can comfortably read every English sentence.

`visual situation → short plain-English instruction → one clear action`

Text remains important because Phravora teaches English. The redesign reduces dependence on long explanatory text; it does not remove meaningful English from the learning experience.

## Visual language

Use one coherent, inclusive illustration system—not decorative stock images and not repeated generic icons. Each mission scene should include a recognisable professional context, visible learner and partner roles, an action cue, and one compact label.

| State | Visual cue | Short label |
| --- | --- | --- |
| Read | Person reading a document/book | `Read` |
| Listen | Person with headphones and speaker waves | `Listen` |
| Speak | Learner facing a partner with speech waves | `Your turn` |
| Record | Microphone, red pulse and waveform | `Recording` |
| Wait | Gentle animated dots between roles | `Preparing` |
| Complete | Calm checkmark and mission scene | `Mission saved` |

Animations must respect Reduce Motion and never be the only way a state is communicated. Labels and VoiceOver descriptions remain equivalent.

## Screen-by-screen proposal

### 1. Onboarding

**Current:** one long selection screen for level, profession, goal, difficult situations and daily target.

**Change:** use short visual steps with progress:

1. `What do you want to practise?` — interview, meeting, presentation, client call and networking illustrated as five scenes.
2. `Your role` — profession cards with a simple person-at-work illustration.
3. `Choose your level` — visual confidence scale plus A1–C2 text.
4. `Your daily goal` — five-, ten- and fifteen-minute visual choices.
5. `Your first mission` — recommended scene and one large `Start` action.

All choices remain editable later. No account creation belongs here.

### 2. Home / Today

**Current:** text-led daily card and mission rows with repeated briefcase icons.

**Change:** Today’s Mission becomes a large scene card. An interview shows interviewer and candidate; a presentation shows a presenter and audience. Add one short action line such as `Tell them about you.` and retain one large Start action. Keep streak and evidence secondary. A repair prompt gets a calm repeat-arrow visual, not warning-like text.

### 3. Mission list

**Current:** data-driven missions but visually similar rows.

**Change:** each mission receives a scenario thumbnail, short title, duration and action cue:

- Interview: interviewer and candidate.
- Meeting: colleagues around a table.
- Client call: professional with phone/headset.
- Presentation: presenter beside a screen.
- Networking: two professionals greeting each other.

### 4. Mission preview / start

**Current:** long situation, objective and success-criteria card.

**Change:** lead with a mission scene, then only two visual role rows:

- `You:` candidate, presenter or team member.
- `Partner:` interviewer, manager or client.

Show one short action sentence, for example `Speak about your experience.` Put detailed success criteria and vocabulary behind a `Tips` disclosure. Keep `Start speaking` and its microphone visual fixed and unambiguous.

### 5. Active speaking mission

**Current:** microphone, transcript and completion button.

**Change:** conversation state becomes the primary visual:

- **Partner speaking:** partner avatar highlighted, speaker waves, learner muted, `Listen`.
- **Learner turn:** learner avatar highlighted, microphone ready, `Your turn — speak`.
- **Recording:** learner avatar, live waveform and red recording pulse, large `Stop` action.
- **Preparing:** neutral transition, `Preparing your next step`.
- **Unavailable:** honest card: `Live coaching is not connected in this build.`

The Apple Speech transcript remains secondary and clearly labelled as the learner’s words, never AI evaluation.

### 6. Permissions and failures

Pair each typed error with a visual reason and one recovery action:

- microphone-off scene + `Turn on Microphone`;
- speech bubble with lock + `Allow Speech Recognition`;
- paused cloud/network scene + `Try again`.

Keep the existing typed-error and reservation-release architecture.

### 7. Completion and feedback

Until a real feedback provider is approved, keep the existing honest outcome: a completion scene, duration and saved-mission evidence only. Do not show an invented score, pronunciation rating or personalised feedback.

After real feedback exists, use at most one outcome illustration, two strengths, one or two repair points and a single `Practise again` action.

### 8. Progress

Turn the evidence into a simple career-practice timeline. Each entry has a mission scene thumbnail and a small state marker: practised, repeated or repaired. Retain speaking minutes, completed missions, vocabulary reuse and weaknesses improved; avoid XP.

### 9. Settings and privacy

Keep administrative pages mostly text-led but plain and supported by small symbols. Preserve the truthful current statement that live AI coaching is not connected.

## Asset and accessibility requirements

- Create original Phravora assets or use a licensed, consistent illustration set; never copy third-party app artwork.
- Provide accessibility labels for every scene and state.
- Support Dynamic Type, dark mode and sufficient contrast.
- Respect Reduce Motion.
- Prepare text for localisation; do not bake English text into illustrations.

## Implementation order after Milestone 4

1. Define reusable mission scene and visual-state components.
2. Create a small original professional-illustration set.
3. Redesign Home, Mission List and Mission Preview around scenario cards.
4. Redesign active mission states around partner/learner turns.
5. Validate VoiceOver, Dynamic Type, dark mode and Reduce Motion.
6. Capture final App Store screenshots from the real final UI.

## Explicit non-goals

- No fake partner, feedback, score or waveform.
- No realtime provider, credential, StoreKit work or App Check enforcement change.
- No change to quota authority, Firebase security or the Phravora/Nexa boundary.
