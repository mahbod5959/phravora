import Foundation

enum AppLoadState: Equatable { case loading, onboarding, ready, failed(AppError) }

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var state: AppLoadState = .loading
    @Published private(set) var data = LocalUserData()
    let catalog: any MissionCatalogProviding
    private let repository: any UserRepository

    init(repository: any UserRepository = UserDefaultsUserRepository(), catalog: any MissionCatalogProviding = DefaultMissionCatalog()) { self.repository = repository; self.catalog = catalog }

    func load() async {
        state = .loading
        do { data = try await repository.load(); state = data.hasCompletedOnboarding ? .ready : .onboarding }
        catch let error as AppError { state = .failed(error) }
        catch { state = .failed(.unknown("Phravora could not start. Please try again.")) }
    }

    func completeOnboarding(level: EnglishLevel, profession: Profession, careerGoal: CareerGoal, difficultSituations: Set<DifficultSituation>, dailyTarget: DailyPracticeTarget) async {
        data.hasCompletedOnboarding = true
        data.profile = UserProfile(englishLevel: level, profession: profession, careerGoal: careerGoal, difficultSituations: difficultSituations, dailyPracticeTarget: dailyTarget)
        await persist(nextState: .ready)
    }

    /// Lets a learner revise their speaking plan from Settings instead of only
    /// at onboarding — onboarding already tells them "you can change this
    /// later in Settings", so this fulfils that promise.
    func updateProfile(level: EnglishLevel, profession: Profession, careerGoal: CareerGoal, difficultSituations: Set<DifficultSituation>, dailyTarget: DailyPracticeTarget) async {
        guard data.profile != nil else { return }
        data.profile?.englishLevel = level
        data.profile?.profession = profession
        data.profile?.careerGoal = careerGoal
        data.profile?.difficultSituations = difficultSituations
        data.profile?.dailyPracticeTarget = dailyTarget
        await persist(nextState: .ready)
    }

    func recordPractice(mission: Mission, durationSeconds: Int) async {
        data.progress.record(session: SessionMetadata(missionID: mission.id, durationSeconds: durationSeconds))
        await persist(nextState: .ready)
    }

    func addVocabulary(phrase: String, meaning: String) async {
        guard !phrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        data.progress.vocabulary.insert(VocabularyItem(phrase: phrase, meaning: meaning), at: 0)
        await persist(nextState: .ready)
    }

    /// Lets a learner clear everything stored locally (profile, progress, mistake
    /// memory) and start over from onboarding. Nothing here is stored remotely,
    /// so this is a full, immediate deletion — matching the app's on-device-only
    /// data statement in Settings.
    func resetAllData() async {
        do {
            try await repository.clear()
            data = LocalUserData()
            state = .onboarding
        } catch let error as AppError {
            state = .failed(error)
        } catch {
            state = .failed(.persistence("Your data could not be deleted. Please try again."))
        }
    }

    private func persist(nextState: AppLoadState) async {
        do { try await repository.save(data); state = nextState }
        catch let error as AppError { state = .failed(error) }
        catch { state = .failed(.persistence("Your changes could not be saved.")) }
    }
}
