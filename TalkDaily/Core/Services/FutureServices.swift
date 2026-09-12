import Foundation
import FirebaseAuth
import FirebaseFunctions

enum BackendError: Error, Equatable, Sendable { case unauthenticated, quotaExceeded, sessionConflict, rateLimited, integrityFailed, backendUnavailable, invalidResponse }
struct BackendConfiguration: Sendable { let baseURL: URL; let environment: Environment; enum Environment: Sendable { case development, production } }
protocol AuthenticationService: Sendable { func authenticateAnonymously() async throws -> String }
protocol RealtimeCredentialService: Sendable { func createSession(missionID: String, durationSeconds: Int) async throws -> String; func finish(sessionID: String, secondsUsed: Int) async throws; func cancel(sessionID: String) async throws }
protocol UsageService: Sendable { func remainingSeconds() async throws -> Int }
struct MockAuthenticationService: AuthenticationService { func authenticateAnonymously() async throws -> String { "mock-user" } }
struct MockRealtimeCredentialService: RealtimeCredentialService { func createSession(missionID: String, durationSeconds: Int) async throws -> String { throw BackendError.backendUnavailable }; func finish(sessionID: String, secondsUsed: Int) async throws {}; func cancel(sessionID: String) async throws {} }
struct MockUsageService: UsageService { func remainingSeconds() async throws -> Int { 0 } }

/// Small boundary around FirebaseAuth so authentication behavior can be tested without a Firebase network call.
protocol AnonymousAuthenticationClient: Sendable {
    func restoredUserID() -> String?
    func signInAnonymously() async throws -> String
}

struct FirebaseAnonymousAuthenticationClient: AnonymousAuthenticationClient {
    func restoredUserID() -> String? { Auth.auth().currentUser?.uid }
    func signInAnonymously() async throws -> String { try await Auth.auth().signInAnonymously().user.uid }
}

struct FirebaseAuthenticationService: AuthenticationService {
    private let client: any AnonymousAuthenticationClient

    init(client: any AnonymousAuthenticationClient = FirebaseAnonymousAuthenticationClient()) {
        self.client = client
    }

    func authenticateAnonymously() async throws -> String {
        if let userID = client.restoredUserID() { return userID }
        return try await client.signInAnonymously()
    }
}

enum FirebaseFunctionsErrorMapper {
    static func map(_ error: Error) -> BackendError {
        let ns = error as NSError
        switch ns.code {
        case 16: return .unauthenticated
        case 8: return .quotaExceeded
        case 6: return .sessionConflict
        case 4: return .rateLimited
        case 7: return .integrityFailed
        case 14: return .backendUnavailable
        default: return .invalidResponse
        }
    }
}

struct FirebaseRealtimeCredentialService: RealtimeCredentialService {
    private let functions = Functions.functions(region: "europe-west3")
    func createSession(missionID: String, durationSeconds: Int) async throws -> String {
        do {
            let result = try await functions.httpsCallable("reservePracticeSession").call(["missionID": missionID, "durationSeconds": durationSeconds])
            guard let data = result.data as? [String: Any], let sessionID = data["sessionID"] as? String else { throw BackendError.invalidResponse }
            return sessionID
        } catch { throw map(error) }
    }
    func finish(sessionID: String, secondsUsed: Int) async throws { _ = try await functions.httpsCallable("finishRealtimeSession").call(["sessionID": sessionID, "secondsUsed": secondsUsed]) }
    func cancel(sessionID: String) async throws { _ = try await functions.httpsCallable("cancelRealtimeSession").call(["sessionID": sessionID]) }
    private func map(_ error: Error) -> BackendError { FirebaseFunctionsErrorMapper.map(error) }
}

enum ConversationState: Equatable, Sendable { case idle, preparing, connecting, listening, responding, finishing, finished, unavailable, failed(AppError) }
struct ConversationConfiguration: Sendable { let mission: Mission; let level: EnglishLevel }
struct SessionFeedback: Sendable, Equatable { let summary: String; let vocabulary: [VocabularyItem] }
enum EntitlementState: Sendable, Equatable { case free(remainingMinutes: Int), premium, unavailable }

protocol RealtimeConversationService: Sendable {
    func start(configuration: ConversationConfiguration) async throws
    func stop() async
}
protocol SessionFeedbackService: Sendable { func feedback(for session: SessionMetadata) async throws -> StructuredSessionFeedback }
protocol EntitlementService: Sendable { func currentEntitlement() async -> EntitlementState; func restorePurchases() async throws }

struct MockRealtimeConversationService: RealtimeConversationService {
    func start(configuration: ConversationConfiguration) async throws { throw AppError.serviceUnavailable }
    func stop() async {}
}
struct MockSessionFeedbackService: SessionFeedbackService {
    func feedback(for session: SessionMetadata) async throws -> StructuredSessionFeedback { throw AppError.serviceUnavailable }
}
struct MockEntitlementService: EntitlementService {
    func currentEntitlement() async -> EntitlementState { .free(remainingMinutes: 0) }
    func restorePurchases() async throws { throw AppError.serviceUnavailable }
}
