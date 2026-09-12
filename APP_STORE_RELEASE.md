# App Store release checklist

> `TalkDaily` is the temporary internal project name. The customer-facing brand is **Phravora**. Keep final App Store metadata subject to legal/trademark review.

## Before the first archive

1. In Xcode, select the TalkDaily target and set **Signing & Capabilities → Team** to your Apple Developer team.
2. Verify the approved bundle identifier remains `com.phravora.app`.
3. Confirm final App Store metadata after App Store, domain, and trademark review.
4. Do not market the app as providing live AI feedback until that feature has been implemented and reviewed.
5. Add a public privacy-policy URL in App Store Connect. The app currently uses microphone and Apple Speech Recognition only for user-initiated practice.

## App Store Connect listing draft

- **Subtitle:** Practice English for work and career
- **Promotional text:** Structured speaking missions for interviews, meetings, clients, and presentations.
- **Description:** Complete guided professional speaking missions with clear objectives, role context, and progress evidence. The current build does not claim live AI assessment.
- **Keywords:** english,speaking,career,interview,meeting,presentation,work,professional
- **Category:** Education
- **Age rating:** 4+

## Privacy answers to review

The current build does not create an account, collect analytics, sell data, or send recordings to a server. Apple Speech Recognition may process audio according to the device and Apple settings. Re-check these disclosures whenever an AI backend, analytics, subscriptions, or account system is added.

## Archive and upload

1. Choose **Any iOS Device (arm64)** as the run destination.
2. Select **Product → Archive**.
3. In Organizer, validate and distribute to App Store Connect.
4. Upload 6.7-inch and 6.1-inch screenshots, complete the privacy questionnaire, and submit the build for review.

## Important next product work

For an actual AI conversation coach, add a server endpoint that authenticates the user and calls the chosen AI provider. Never ship an AI-provider API key inside the iOS app. Add StoreKit subscriptions only after the free speaking loop is validated.
