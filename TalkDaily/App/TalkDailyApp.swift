import SwiftUI
import FirebaseAppCheck
import FirebaseCore

@main
struct TalkDailyApp: App {
    @StateObject private var app = AppViewModel()
    init() { FirebaseBootstrap.configure() }
    var body: some Scene { WindowGroup { RootView().environmentObject(app).tint(AppTheme.primary) } }
}

enum FirebaseBootstrap {
    private static var configured = false
    static var isConfigured: Bool { configured }
    static func configure() {
        guard !configured else { return }
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
        #endif
        FirebaseApp.configure()
        configured = true
    }
}

struct RootView: View {
    @EnvironmentObject private var app: AppViewModel
    var body: some View {
        Group {
            switch app.state {
            case .loading: LoadingView()
            case .onboarding: OnboardingView()
            case .ready: MainTabView()
            case .failed(let error): ErrorStateView(error: error) { Task { await app.load() } }
            }
        }
        .task { await app.load() }
    }
}
