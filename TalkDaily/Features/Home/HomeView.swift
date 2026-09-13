import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Today", systemImage: "house.fill") }
            MissionListView().tabItem { Label("Missions", systemImage: "mic.fill") }
            ProgressFeatureView().tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        NavigationStack {
            // A vertical ScrollView offers its child an unconstrained width.
            // Give the content the actual viewport width explicitly: otherwise
            // a card can adopt its image/text intrinsic width and its leading
            // copy is clipped on compact iPhones.
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        let missions = app.catalog.missions(for: app.data.profile)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Career speaking")
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                Text("Practise before the moment matters.")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Label("\(app.data.progress.currentStreak)", systemImage: "flame.fill")
                                .foregroundStyle(.orange)
                                .accessibilityLabel("\(app.data.progress.currentStreak) day streak")
                        }

                        Text("TODAY’S MISSION")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.primary)

                        if let mission = missions.first { DailyMissionCard(mission: mission) }

                        Text("Continue improving").font(.title2.bold())
                        if let mistake = app.data.progress.mistakeMemory.first {
                            Text("Yesterday you struggled with \(mistake.learnerFacingSummary.lowercased()). Practice it again in a future repair mission.")
                                .font(.subheadline)
                                .padding()
                                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                        } else {
                            Text("Your first completed mission will build career-specific evidence here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let profile = app.data.profile {
                            Label("Career goal: \(profile.careerGoal.title)", systemImage: "flag.checkered")
                                .font(.subheadline.weight(.semibold))
                                .padding(.vertical, 10)
                        }

                        Text("Recommended missions").font(.title2.bold())
                        ForEach(Array(missions.dropFirst().prefix(3))) { MissionRow(mission: $0) }
                    }
                    .padding(20)
                    .frame(width: proxy.size.width, alignment: .leading)
                }
            }
            .background(AppTheme.canvas)
            // Home has its own header, so leaving an untitled navigation bar
            // above it only wastes space (and can appear as a black strip in
            // dark system appearance).
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct DailyMissionCard: View {
    let mission: Mission

    var body: some View {
        NavigationLink {
            PracticeSessionView(mission: mission)
        } label: {
            GeometryReader { proxy in
                ZStack(alignment: .bottomLeading) {
                    MissionVisualScene(mission: mission, presentation: .hero)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(mission.difficulty.title.uppercased())
                                .font(.caption.weight(.bold))
                                .lineLimit(1)
                            Spacer(minLength: 8)
                            Label("\(mission.estimatedMinutes) min", systemImage: "clock")
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .fixedSize()
                        }
                        Text(mission.title)
                            .font(.title2.bold())
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(mission.objective)
                            .font(.subheadline)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Start mission").fontWeight(.bold)
                            Spacer(minLength: 8)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                    .padding(20)
                    .frame(width: proxy.size.width, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 260)
            .clipped()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mission.title). \(mission.situation). Start mission.")
    }
}

struct MissionRow: View {
    let mission: Mission

    var body: some View {
        NavigationLink {
            PracticeSessionView(mission: mission)
        } label: {
            GeometryReader { proxy in
                ZStack(alignment: .bottomLeading) {
                    MissionVisualScene(mission: mission, presentation: .card)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mission.title)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                        Text(mission.situation)
                            .font(.caption)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                    .padding(16)
                    .frame(width: proxy.size.width, alignment: .leading)

                    VStack {
                        HStack {
                            Spacer()
                            Label("\(mission.estimatedMinutes)m", systemImage: "clock")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.32), in: Capsule())
                                .fixedSize()
                        }
                        Spacer()
                    }
                    .padding(12)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 146)
            .clipped()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mission.title). \(mission.situation).")
    }
}

/// A real professional scene lets a learner identify the activity before
/// needing to understand the English copy.
struct MissionVisualScene: View {
    enum Presentation { case hero, card, preview }

    let mission: Mission
    let presentation: Presentation

    private var imageName: String {
        return switch mission.id {
        case "tell-yourself": "MissionTellYourself"
        case "experience": "MissionProfessionalExperience"
        case "difficult-question": "MissionDifficultQuestion"
        case "technical-clarity": "MissionTechnicalClarity"
        case "polite-disagreement": "MissionPoliteDisagreement"
        case "status-update": "MissionStatusUpdate"
        case "clarification": "MissionClarification"
        case "dissatisfied-client": "MissionDissatisfiedClient"
        case "defend-decision": "MissionDefendDecision"
        case "deadline": "MissionDeadline"
        case "small-talk": "MissionSmallTalk"
        case "present-idea": "MissionPresentIdea"
        default: "MissionTellYourself"
        }
    }

    private var cornerRadius: CGFloat {
        switch presentation {
        case .hero: 22
        case .card: 16
        case .preview: 20
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            // Keep the top of the frame visible. In people-focused photos this
            // preserves faces instead of centering the crop on the torso.
            .frame(
                height: presentation == .hero ? 260 : presentation == .preview ? 132 : 146,
                alignment: .top
            )
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.03), .black.opacity(presentation == .card ? 0.64 : 0.68)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
