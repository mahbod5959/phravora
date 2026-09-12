import SwiftUI

struct MissionListView: View {
    @EnvironmentObject private var app: AppViewModel
    var body: some View { NavigationStack { List { let missions = app.catalog.missions(for: app.data.profile); if missions.isEmpty { ContentUnavailableView("No missions yet", systemImage: "target", description: Text("Your career mission plan is being prepared.")) } else { Section("Professional speaking missions") { ForEach(missions) { MissionRow(mission: $0) } } } }.navigationTitle("Missions") } }
}

struct PracticeSessionView: View {
    @EnvironmentObject private var app: AppViewModel
    @StateObject private var speech: SpeechService
    @StateObject private var session: PracticeSessionViewModel
    let mission: Mission
    init(mission: Mission) { self.mission = mission; let speech = SpeechService(); _speech = StateObject(wrappedValue: speech); _session = StateObject(wrappedValue: PracticeSessionViewModel(mission: mission, startRecording: { try await speech.requestAndStartRecording() }, stopRecording: { speech.stop() })) }
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 24) {
        Text(mission.category.rawValue.uppercased()).font(.caption.weight(.bold)).foregroundStyle(AppTheme.primary)
        Text(mission.title).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
        MissionVisualScene(mission: mission, presentation: .preview)
            .accessibilityHidden(true)
        VStack(alignment: .leading, spacing: 10) { Text(mission.situation).font(.headline).fixedSize(horizontal: false, vertical: true); Text(mission.objective).fixedSize(horizontal: false, vertical: true); Text("Success means:").font(.subheadline.weight(.bold)); ForEach(mission.successCriteria, id: \.self) { Label($0, systemImage: "checkmark.circle").fixedSize(horizontal: false, vertical: true) } }.frame(maxWidth: .infinity, alignment: .leading).padding(20).background(.background, in: RoundedRectangle(cornerRadius: 22))
        VStack(spacing: 12) {
            Button {
                Task {
                    if session.state == .recording {
                        if let metadata = await session.complete() {
                            await app.recordPractice(mission: mission, durationSeconds: metadata.durationSeconds)
                        }
                    } else {
                        await session.start()
                    }
                }
            } label: {
                Image(systemName: session.state == .recording ? "checkmark" : "mic.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(session.state == .recording ? .green : AppTheme.primary, in: Circle())
            }
            .disabled(session.state == .reserving || session.state == .finishing)
            .accessibilityLabel(session.state == .recording ? "Finish mission" : "Start mission")

            Text(session.state == .recording ? "Tap when you are finished" : "Tap to start mission")
                .font(.subheadline.weight(.medium))

            if !speech.transcript.isEmpty {
                Text(speech.transcript)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.canvas, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity)
        if let error = speech.error { PermissionErrorCard(error: error, openSettings: speech.openSettings) }
        if session.state == .completed { ContentUnavailableView("Mission saved", systemImage: "checkmark.circle.fill", description: Text("Your completed mission and speaking time were saved. Feedback will appear only when real coaching is connected.")) }
        if case .failed = session.state { Button("Try again") { Task { await session.start() } }.buttonStyle(.borderedProminent) }
    }
    .padding(20)
    // Same viewport-width safeguard as HomeView: without this, long mission
    // copy in this ScrollView can be measured wider than the screen and get
    // center-clipped on narrower phones (e.g. iPhone 11).
    .frame(maxWidth: .infinity, alignment: .leading)
    }.background(AppTheme.canvas).navigationBarTitleDisplayMode(.inline).onDisappear { Task { await session.cancel() } } }
}

struct PermissionErrorCard: View { let error: AppError; let openSettings: () -> Void
    var body: some View { VStack(alignment: .leading, spacing: 10) { Label("Permission needed", systemImage: "lock.fill").font(.headline); Text(error.localizedDescription).font(.subheadline); Button("Open Settings", action: openSettings).buttonStyle(.bordered) }.padding().background(.orange.opacity(0.13), in: RoundedRectangle(cornerRadius: 16)).accessibilityElement(children: .combine) }
}
