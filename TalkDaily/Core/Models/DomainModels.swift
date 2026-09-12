import Foundation

enum EnglishLevel: String, CaseIterable, Codable, Identifiable, Sendable {
    case beginner, intermediate, advanced
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var cefrHint: String { switch self { case .beginner: "A1–A2"; case .intermediate: "B1–B2"; case .advanced: "C1–C2" } }
    var description: String { switch self { case .beginner: "Simple, patient conversation"; case .intermediate: "Everyday topics with useful challenge"; case .advanced: "Nuanced, natural discussion" } }
}

enum Profession: String, CaseIterable, Codable, Identifiable, Sendable { case softwareDeveloper, designer, sales, customerSupport, healthcare, studentGraduate, manager, other
    var id: String { rawValue }; var title: String { switch self { case .softwareDeveloper: "Software Developer"; case .designer: "Designer"; case .sales: "Sales"; case .customerSupport: "Customer Support"; case .healthcare: "Healthcare"; case .studentGraduate: "Student / Graduate"; case .manager: "Manager"; case .other: "Other" } }
}
enum CareerGoal: String, CaseIterable, Codable, Identifiable, Sendable { case getHired, leadMeetings, workWithClients, presentIdeas, growConfidence
    var id: String { rawValue }; var title: String { switch self { case .getHired: "Get hired"; case .leadMeetings: "Lead meetings"; case .workWithClients: "Work with clients"; case .presentIdeas: "Present ideas"; case .growConfidence: "Speak with confidence" } }
}
enum DifficultSituation: String, CaseIterable, Codable, Identifiable, Sendable { case interviews, meetings, presentations, clientCalls, networking
    var id: String { rawValue }; var title: String { rawValue == "clientCalls" ? "Client calls" : rawValue.capitalized }
}
enum DailyPracticeTarget: Int, CaseIterable, Codable, Identifiable, Sendable { case five = 5, ten = 10, fifteen = 15
    var id: Int { rawValue }; var title: String { "\(rawValue) minutes a day" }
}
enum MissionCategory: String, Codable, CaseIterable, Sendable { case interview, meeting, presentation, client, networking
    var title: String { rawValue.capitalized }
}
enum MissionDifficulty: String, Codable, CaseIterable, Sendable { case foundation, developing, advanced
    var title: String { rawValue.capitalized }
}
struct Mission: Identifiable, Hashable, Codable, Sendable {
    let id: String; let title: String; let category: MissionCategory; let difficulty: MissionDifficulty; let aiRole: String; let userRole: String; let situation: String; let objective: String; let successCriteria: [String]; let constraints: [String]; let suggestedVocabulary: [String]; let estimatedMinutes: Int; let supportsRepair: Bool
}

struct UserProfile: Codable, Sendable, Equatable {
    var englishLevel: EnglishLevel
    var profession: Profession
    var careerGoal: CareerGoal
    var difficultSituations: Set<DifficultSituation>
    var dailyPracticeTarget: DailyPracticeTarget
    var historyEnabled: Bool = true
}

struct SessionMetadata: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let missionID: String
    let startedAt: Date
    let durationSeconds: Int
    init(id: UUID = UUID(), missionID: String, startedAt: Date = .now, durationSeconds: Int) { self.id = id; self.missionID = missionID; self.startedAt = startedAt; self.durationSeconds = durationSeconds }
}

enum MistakeCategory: String, Codable, CaseIterable, Sendable { case grammarPattern, unnaturalExpression, missingVocabulary, simplePhrasing, professionalCommunication }
struct MistakePattern: Codable, Identifiable, Sendable, Equatable { let id: UUID; var category: MistakeCategory; var patternKey: String; var learnerFacingSummary: String; var recommendedForm: String; var occurrenceCount: Int; var lastSeenAt: Date; var repairedCount: Int
    init(id: UUID = UUID(), category: MistakeCategory, patternKey: String, learnerFacingSummary: String, recommendedForm: String, occurrenceCount: Int = 1, lastSeenAt: Date = .now, repairedCount: Int = 0) { self.id = id; self.category = category; self.patternKey = patternKey; self.learnerFacingSummary = learnerFacingSummary; self.recommendedForm = recommendedForm; self.occurrenceCount = occurrenceCount; self.lastSeenAt = lastSeenAt; self.repairedCount = repairedCount }
}
struct RepairMission: Codable, Identifiable, Sendable, Equatable { let id: UUID; let sourceMistakeID: UUID; let title: String; let prompt: String; let targetPattern: String; let createdAt: Date; var completedAt: Date? }

struct VocabularyItem: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    var phrase: String
    var meaning: String
    var createdAt: Date
    init(id: UUID = UUID(), phrase: String, meaning: String, createdAt: Date = .now) { self.id = id; self.phrase = phrase; self.meaning = meaning; self.createdAt = createdAt }
}

enum MissionOutcome: String, Codable, Sendable, Equatable { case achieved, partiallyAchieved, notAssessed }
struct RepairPoint: Codable, Identifiable, Sendable, Equatable {
    let id: UUID; let category: MistakeCategory; let patternKey: String; let learnerFacingSummary: String; let recommendedForm: String
    init(id: UUID = UUID(), category: MistakeCategory, patternKey: String, learnerFacingSummary: String, recommendedForm: String) { self.id=id; self.category=category; self.patternKey=patternKey; self.learnerFacingSummary=learnerFacingSummary; self.recommendedForm=recommendedForm }
}
struct StructuredSessionFeedback: Codable, Sendable, Equatable {
    let outcome: MissionOutcome; let strengths: [String]; let repairPoints: [RepairPoint]; let reusedVocabulary: [String]
    init(outcome: MissionOutcome, strengths: [String], repairPoints: [RepairPoint], reusedVocabulary: [String]) { self.outcome=outcome; self.strengths=Array(strengths.prefix(2)); self.repairPoints=Array(repairPoints.prefix(2)); self.reusedVocabulary=reusedVocabulary }
}

struct UserProgress: Codable, Sendable, Equatable {
    var totalSpeakingSeconds = 0
    var sessionCount = 0
    var currentStreak = 0
    var longestStreak = 0
    var lastPracticeDay: Date?
    var sessionHistory: [SessionMetadata] = []
    var vocabulary: [VocabularyItem] = []
    var mistakeMemory: [MistakePattern] = []
    var repairMissions: [RepairMission] = []

    var totalSpeakingMinutes: Int { totalSpeakingSeconds / 60 }

    mutating func record(session: SessionMetadata, calendar: Calendar = .current) {
        totalSpeakingSeconds += max(0, session.durationSeconds)
        sessionCount += 1
        let day = calendar.startOfDay(for: session.startedAt)
        if let lastPracticeDay {
            let lastDay = calendar.startOfDay(for: lastPracticeDay)
            if calendar.isDate(day, inSameDayAs: lastDay) {
                // A second session today increases totals but not the streak.
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: day), calendar.isDate(lastDay, inSameDayAs: yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else { currentStreak = 1 }
        longestStreak = max(longestStreak, currentStreak)
        lastPracticeDay = day
        sessionHistory.insert(session, at: 0)
    }

    /// Stores a compact learning pattern only. Raw conversation text is intentionally not retained.
    mutating func remember(_ pattern: MistakePattern) {
        if let index = mistakeMemory.firstIndex(where: { $0.patternKey == pattern.patternKey }) {
            mistakeMemory[index].occurrenceCount += max(1, pattern.occurrenceCount)
            mistakeMemory[index].lastSeenAt = pattern.lastSeenAt
        } else {
            mistakeMemory.insert(pattern, at: 0)
        }
    }

    /// A repair is eligible after a pattern recurs twice, but is not presented as AI feedback.
    mutating func scheduleRepairIfNeeded(for patternKey: String, now: Date = .now) {
        guard let pattern = mistakeMemory.first(where: { $0.patternKey == patternKey }),
              pattern.occurrenceCount >= 2,
              !repairMissions.contains(where: { $0.sourceMistakeID == pattern.id && $0.completedAt == nil })
        else { return }

        repairMissions.insert(
            RepairMission(
                id: UUID(),
                sourceMistakeID: pattern.id,
                title: "Repair: \(pattern.learnerFacingSummary)",
                prompt: "In your next professional update, naturally use: \(pattern.recommendedForm)",
                targetPattern: pattern.patternKey,
                createdAt: now,
                completedAt: nil
            ),
            at: 0
        )
    }

    mutating func completeRepair(id: UUID, at date: Date = .now) {
        guard let repairIndex = repairMissions.firstIndex(where: { $0.id == id && $0.completedAt == nil }) else { return }
        repairMissions[repairIndex].completedAt = date
        guard let patternIndex = mistakeMemory.firstIndex(where: { $0.id == repairMissions[repairIndex].sourceMistakeID }) else { return }
        mistakeMemory[patternIndex].repairedCount += 1
    }

    mutating func apply(_ feedback: StructuredSessionFeedback, at date: Date = .now) {
        // A response can mention one weakness in more than one field. Treat it as
        // one observed pattern per session, so repair work reflects recurrence.
        var handledPatterns = Set<String>()
        for point in feedback.repairPoints where handledPatterns.insert(point.patternKey).inserted {
            remember(MistakePattern(category: point.category, patternKey: point.patternKey, learnerFacingSummary: point.learnerFacingSummary, recommendedForm: point.recommendedForm, lastSeenAt: date))
            scheduleRepairIfNeeded(for: point.patternKey, now: date)
        }
    }
}

struct LocalUserData: Codable, Sendable, Equatable {
    var hasCompletedOnboarding = false
    var profile: UserProfile?
    var progress = UserProgress()
}

enum AppError: LocalizedError, Equatable, Sendable {
    case persistence(String)
    case microphoneDenied
    case speechRecognitionDenied
    case audioUnavailable
    case serviceUnavailable
    case unknown(String)
    var errorDescription: String? { switch self {
    case .persistence: "Your learning data could not be saved locally."
    case .microphoneDenied: "Microphone access is needed to practise speaking."
    case .speechRecognitionDenied: "Speech Recognition access is needed to show what you said."
    case .audioUnavailable: "Audio is unavailable right now. Please try again."
    case .serviceUnavailable: "This service is not available in this build."
    case .unknown(let message): message
    } }
}
