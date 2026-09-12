import Foundation

protocol UserRepository: Sendable {
    func load() async throws -> LocalUserData
    func save(_ data: LocalUserData) async throws
    func clear() async throws
}

actor UserDefaultsUserRepository: UserRepository {
    private let defaults: UserDefaults
    private let key = "talkdaily.local-user-data.v1"

    init(suiteName: String? = nil) {
        defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    func load() throws -> LocalUserData {
        guard let stored = defaults.data(forKey: key) else { return LocalUserData() }
        do { return try JSONDecoder().decode(LocalUserData.self, from: stored) }
        catch { throw AppError.persistence("Saved learning data could not be read.") }
    }

    func save(_ data: LocalUserData) throws {
        do { defaults.set(try JSONEncoder().encode(data), forKey: key) }
        catch { throw AppError.persistence("Saved learning data could not be written.") }
    }

    func clear() throws { defaults.removeObject(forKey: key) }
}
