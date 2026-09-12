# Learning loop and mistake memory

## Loop

1. The learner chooses a career goal.
2. The app recommends a bounded speaking mission.
3. A future real-voice service runs that mission within its success criteria.
4. A feedback service identifies useful, recurring patterns.
5. The app stores compact pattern metadata in Mistake Memory.
6. After a pattern recurs, it schedules a repair mission that naturally requires the improved language.
7. Progress shows completed missions, speaking minutes, repair completions, reused vocabulary, and patterns improving over time.

## Privacy boundary

Mistake Memory stores only what is useful for learning: category, stable pattern key, learner-facing summary, recommended form, occurrence count, repair count, and timestamps. It does not need to retain full conversation transcripts or sensitive professional content.

## Repair missions

When a pattern occurs at least twice, the local model may create one open repair mission. Example: a recurring `present-perfect-continuous` pattern produces a later professional update that requires the learner to say “I have been working for three years.” A repair is completed only after the future feedback service verifies it; the current build does not fabricate that verification.

## Current boundary

The architecture and deterministic local scheduling are present now. Real transcription, AI assessment, audio retention policy, and personalised feedback will be implemented only after explicit product and privacy review.
