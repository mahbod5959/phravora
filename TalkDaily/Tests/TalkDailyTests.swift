import XCTest
@testable import TalkDaily

final class TalkDailyTests: XCTestCase {
    private var suiteName: String!
    private var repository: UserDefaultsUserRepository!

    override func setUp() { super.setUp(); suiteName = "TalkDailyTests.\(UUID().uuidString)"; repository = UserDefaultsUserRepository(suiteName: suiteName) }
    override func tearDown() async throws { try await repository.clear(); repository = nil; suiteName = nil; try await super.tearDown() }

    func testOnboardingPersistence() async throws {
        let viewModel = await MainActor.run { AppViewModel(repository: repository) }
        await viewModel.completeOnboarding(level: .intermediate, profession: .softwareDeveloper, careerGoal: .getHired, difficultSituations: [.interviews, .meetings], dailyTarget: .ten)
        let stored = try await repository.load()
        XCTAssertTrue(stored.hasCompletedOnboarding)
        XCTAssertEqual(stored.profile?.englishLevel, .intermediate)
        XCTAssertEqual(stored.profile?.profession, .softwareDeveloper)
        XCTAssertEqual(stored.profile?.careerGoal, .getHired)
        XCTAssertEqual(stored.profile?.difficultSituations, [.interviews, .meetings])
    }

    func testStreakCalculationDoesNotDoubleCountSameDay() {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let dayOne = Date(timeIntervalSince1970: 1_700_000_000)
        let dayTwo = calendar.date(byAdding: .day, value: 1, to: dayOne)!
        var progress = UserProgress()
        progress.record(session: SessionMetadata(missionID: "status-update", startedAt: dayOne, durationSeconds: 60), calendar: calendar)
        progress.record(session: SessionMetadata(missionID: "status-update", startedAt: dayOne, durationSeconds: 60), calendar: calendar)
        progress.record(session: SessionMetadata(missionID: "present-idea", startedAt: dayTwo, durationSeconds: 60), calendar: calendar)
        XCTAssertEqual(progress.sessionCount, 3)
        XCTAssertEqual(progress.currentStreak, 2)
        XCTAssertEqual(progress.longestStreak, 2)
        XCTAssertEqual(progress.totalSpeakingMinutes, 3)
    }

    func testSessionProgressIsPersisted() async throws {
        let session = SessionMetadata(missionID: "present-idea", durationSeconds: 300)
        var data = LocalUserData(); data.progress.record(session: session)
        try await repository.save(data)
        let stored = try await repository.load()
        XCTAssertEqual(stored.progress.sessionCount, 1)
        XCTAssertEqual(stored.progress.totalSpeakingMinutes, 5)
        XCTAssertEqual(stored.progress.sessionHistory.first?.missionID, "present-idea")
    }

    func testMissionLoadingIsDataDrivenAndProfileAware() {
        let catalog = DefaultMissionCatalog()
        let profile = UserProfile(englishLevel: .intermediate, profession: .manager, careerGoal: .leadMeetings, difficultSituations: [.meetings], dailyPracticeTarget: .ten)
        XCTAssertEqual(catalog.missions(for: nil).count, 12)
        XCTAssertEqual(catalog.missions(for: profile).first?.category, .meeting)
    }

    func testVocabularyPersistsLocally() async throws {
        var data = LocalUserData(); data.progress.vocabulary = [VocabularyItem(phrase: "check in", meaning: "ثبت ورود")]
        try await repository.save(data)
        let stored = try await repository.load()
        XCTAssertEqual(stored.progress.vocabulary.first?.phrase, "check in")
    }

    func testRecurringPatternCreatesOneRepairMission() {
        var progress = UserProgress()
        let pattern = MistakePattern(category: .grammarPattern, patternKey: "present-perfect-continuous", learnerFacingSummary: "Talking about ongoing experience", recommendedForm: "I have been working for three years.")
        progress.remember(pattern)
        progress.remember(pattern)
        progress.scheduleRepairIfNeeded(for: "present-perfect-continuous", now: Date(timeIntervalSince1970: 1_700_000_000))
        progress.scheduleRepairIfNeeded(for: "present-perfect-continuous")
        XCTAssertEqual(progress.repairMissions.count, 1)
        XCTAssertEqual(progress.repairMissions.first?.targetPattern, "present-perfect-continuous")
    }

    func testRestoredAnonymousAuthDoesNotCreateAnotherUser() async throws {
        let client = StubAnonymousAuthenticationClient(restoredID: "existing-guest")
        let service = FirebaseAuthenticationService(client: client)
        let userID = try await service.authenticateAnonymously()
        XCTAssertEqual(userID, "existing-guest")
        XCTAssertEqual(client.signInCalls(), 0)
    }

    func testFirstAnonymousSignInUsesClient() async throws {
        let client = StubAnonymousAuthenticationClient(restoredID: nil, signInID: "new-guest")
        let service = FirebaseAuthenticationService(client: client)
        let userID = try await service.authenticateAnonymously()
        XCTAssertEqual(userID, "new-guest")
        XCTAssertEqual(client.signInCalls(), 1)
    }

    func testBackendErrorMapping() {
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 16)), .unauthenticated)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 8)), .quotaExceeded)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 6)), .sessionConflict)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 4)), .rateLimited)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 7)), .integrityFailed)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 14)), .backendUnavailable)
        XCTAssertEqual(FirebaseFunctionsErrorMapper.map(NSError(domain: "functions", code: 13)), .invalidResponse)
    }

    func testStructuredFeedbackCapsRepairsAndCreatesRepairOnlyAfterRecurrence() {
        let point = RepairPoint(category: .grammarPattern, patternKey: "present-perfect", learnerFacingSummary: "Past experience", recommendedForm: "I have worked here for three years.")
        let feedback = StructuredSessionFeedback(outcome: .partiallyAchieved, strengths: ["clear", "relevant", "extra"], repairPoints: [point, point, point], reusedVocabulary: ["scope"])
        XCTAssertEqual(feedback.strengths.count, 2); XCTAssertEqual(feedback.repairPoints.count, 2)
        var progress = UserProgress(); progress.apply(feedback); XCTAssertTrue(progress.repairMissions.isEmpty)
        progress.apply(feedback); XCTAssertEqual(progress.mistakeMemory.first?.occurrenceCount, 2); XCTAssertEqual(progress.repairMissions.count, 1)
    }

    func testPracticeSessionReleasesReservationWhenRecordingPermissionFails() async {
        let credentials = RecordingCredentialStub()
        let mission = DefaultMissionCatalog().missions(for: nil)[0]
        let viewModel = await MainActor.run {
            PracticeSessionViewModel(
                mission: mission,
                authentication: MockAuthenticationService(),
                credentials: credentials,
                startRecording: { throw AppError.microphoneDenied },
                stopRecording: {}
            )
        }

        await viewModel.start()

        let state = await MainActor.run { viewModel.state }
        XCTAssertEqual(state, .failed(.permission(.microphoneDenied)))
        let cancellations = await credentials.cancelCount()
        XCTAssertEqual(cancellations, 1)
    }

    func testPracticeSessionFinishesReservationAndReturnsMetadata() async {
        let credentials = RecordingCredentialStub()
        let mission = DefaultMissionCatalog().missions(for: nil)[0]
        let didStopRecording = LockedFlag()
        let viewModel = await MainActor.run {
            PracticeSessionViewModel(
                mission: mission,
                authentication: MockAuthenticationService(),
                credentials: credentials,
                startRecording: {},
                stopRecording: { didStopRecording.set() }
            )
        }

        await viewModel.start()
        let metadata = await viewModel.complete()

        XCTAssertEqual(metadata?.missionID, mission.id)
        XCTAssertGreaterThanOrEqual(metadata?.durationSeconds ?? 0, 1)
        XCTAssertTrue(didStopRecording.value())
        let finishes = await credentials.finishCount()
        XCTAssertEqual(finishes, 1)
        let state = await MainActor.run { viewModel.state }
        XCTAssertEqual(state, .completed)
    }
}

private final class StubAnonymousAuthenticationClient: AnonymousAuthenticationClient, @unchecked Sendable {
    private let restoredID: String?
    private let signInID: String
    private var calls = 0

    init(restoredID: String?, signInID: String = "unused") {
        self.restoredID = restoredID
        self.signInID = signInID
    }

    func restoredUserID() -> String? { restoredID }
    func signInAnonymously() async throws -> String { calls += 1; return signInID }
    func signInCalls() -> Int { calls }
}

private actor RecordingCredentialStub: RealtimeCredentialService {
    private var cancellations = 0
    private var finishes = 0

    func createSession(missionID: String, durationSeconds: Int) async throws -> String { "reserved-session" }

    func finish(sessionID: String, secondsUsed: Int) async throws { finishes += 1 }

    func cancel(sessionID: String) async throws { cancellations += 1 }
    func cancelCount() -> Int { cancellations }
    func finishCount() -> Int { finishes }
}

private final class LockedFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var flag = false

    func set() { lock.lock(); defer { lock.unlock() }; flag = true }
    func value() -> Bool { lock.lock(); defer { lock.unlock() }; return flag }
}
