import SwiftUI

enum AppTheme {
    static let primary = Color(red: 0.20, green: 0.28, blue: 0.84)
    static let canvas = Color(uiColor: .systemGroupedBackground)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.frame(maxWidth: .infinity).padding(.vertical, 16).fontWeight(.bold).foregroundStyle(.white).background(AppTheme.primary.opacity(configuration.isPressed ? 0.72 : 1), in: Capsule())
    }
}

struct LoadingView: View { var body: some View { ProgressView("Preparing your speaking plan…").accessibilityLabel("Loading your speaking plan") } }
struct ErrorStateView: View { let error: AppError; let retry: () -> Void
    var body: some View { ContentUnavailableView { Label("Something went wrong", systemImage: "exclamationmark.triangle") } description: { Text(error.localizedDescription) } actions: { Button("Try again", action: retry).buttonStyle(.borderedProminent) } }
}
