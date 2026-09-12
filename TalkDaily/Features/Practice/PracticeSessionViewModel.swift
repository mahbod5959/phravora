import Foundation

enum PracticeSessionState: Equatable {
    case idle, reserving, recording, finishing, completed, failed(PracticeSessionFailure)
}

enum PracticeSessionFailure: Equatable {
    case permission(AppError), backend(BackendError)
}

@MainActor
final class PracticeSessionViewModel: ObservableObject {
    @Published private(set) var state: PracticeSessionState = .idle
    private let mission: Mission
    private let authentication: any AuthenticationService
    private let credentials: any RealtimeCredentialService
    private let startRecording: () async throws -> Void
    private let stopRecording: () -> Void
    private var sessionID: String?
    private var startedAt: Date?

    init(mission: Mission, authentication: any AuthenticationService = FirebaseAuthenticationService(), credentials: any RealtimeCredentialService = FirebaseRealtimeCredentialService(), startRecording: @escaping () async throws -> Void, stopRecording: @escaping () -> Void) {
        self.mission = mission; self.authentication = authentication; self.credentials = credentials; self.startRecording = startRecording; self.stopRecording = stopRecording
    }

    func start() async {
        guard state == .idle || isRetryable else { return }
        state = .reserving
        do {
            _ = try await authentication.authenticateAnonymously()
            let id = try await credentials.createSession(missionID: mission.id, durationSeconds: mission.estimatedMinutes * 60)
            sessionID = id
            do { try await startRecording(); startedAt = .now; state = .recording }
            catch let error as AppError { await releaseReservation(); state = .failed(.permission(error)) }
            catch { await releaseReservation(); state = .failed(.permission(.audioUnavailable)) }
        } catch let error as BackendError { state = .failed(.backend(error)) }
        catch { state = .failed(.backend(.backendUnavailable)) }
    }

    func complete() async -> SessionMetadata? {
        guard state == .recording, let id = sessionID, let startedAt else { return nil }
        state = .finishing; stopRecording()
        let seconds = max(1, Int(Date.now.timeIntervalSince(startedAt)))
        do { try await credentials.finish(sessionID: id, secondsUsed: seconds); sessionID = nil; state = .completed; return SessionMetadata(missionID: mission.id, startedAt: startedAt, durationSeconds: seconds) }
        catch let error as BackendError { state = .failed(.backend(error)); return nil }
        catch { state = .failed(.backend(.backendUnavailable)); return nil }
    }

    func cancel() async { stopRecording(); await releaseReservation(); if state != .completed { state = .idle } }
    private var isRetryable: Bool { if case .failed = state { return true }; return false }
    private func releaseReservation() async { guard let id = sessionID else { return }; sessionID = nil; try? await credentials.cancel(sessionID: id) }
}
