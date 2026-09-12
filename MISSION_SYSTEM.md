# Mission system

## Mission contract

Each `Mission` is data-driven and contains:

- title and professional category
- difficulty
- AI role and learner role
- real workplace situation and objective
- observable success criteria
- conversation constraints
- suggested vocabulary
- estimated duration
- repair support flag

This makes a mission an outcome-oriented speaking exercise, not a static lesson card. The future conversation service will receive a mission configuration and must keep the interaction within its roles, objective, and constraints.

## MVP mission set

| ID | Mission | Completion evidence |
| --- | --- | --- |
| tell-yourself | Tell me about yourself | concise role, experience, direction |
| experience | Explain your professional experience | example, contribution, result |
| difficult-question | Answer a difficult interview question | structured response and learning |
| technical-clarity | Explain a technical problem clearly | impact and recommendation without jargon |
| polite-disagreement | Disagree politely in a meeting | respectful alternative and reason |
| status-update | Give a project status update | progress, risk, next step |
| clarification | Ask for clarification | accurate paraphrase and question |
| dissatisfied-client | Handle a dissatisfied client | acknowledge, clarify, propose next step |
| defend-decision | Defend a decision | evidence, trade-off, action |
| deadline | Negotiate a deadline | realistic scope or timeline and agreement |
| small-talk | Make professional small talk | natural opener and follow-up |
| present-idea | Present an idea | problem, value, direct ask |

## Personalisation

Onboarding ranks relevant mission categories using the learner’s difficult speaking situations. The catalogue remains intentionally small and deep for the MVP; it is not a shallow library of generic prompts.
