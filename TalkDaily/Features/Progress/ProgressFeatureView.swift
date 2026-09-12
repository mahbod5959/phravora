import SwiftUI

struct ProgressFeatureView: View {
    @EnvironmentObject private var app: AppViewModel
    private var progress: UserProgress { app.data.progress }
    private var missionTitles: [String: String] {
        Dictionary(uniqueKeysWithValues: app.catalog.missions(for: app.data.profile).map { ($0.id, $0.title) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Career speaking progress").font(.largeTitle.bold())
                    HStack(spacing: 12) {
                        StatCard(value: "\(progress.sessionCount)", label: "missions completed", icon: "checkmark.seal.fill", color: .green)
                        StatCard(value: "\(progress.totalSpeakingMinutes)", label: "speaking minutes", icon: "mic.fill", color: AppTheme.primary)
                    }

                    evidenceSection
                    recentMissionsSection
                    vocabularySection
                }
                .padding(20)
            }
            .background(AppTheme.canvas)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private var evidenceSection: some View {
        Text("Evidence of improvement").font(.headline)
        if progress.mistakeMemory.isEmpty {
            ContentUnavailableView("Patterns will appear here", systemImage: "arrow.triangle.2.circlepath", description: Text("After real coaching is connected, recurring language patterns and repair missions will be tracked here."))
        } else {
            ForEach(progress.mistakeMemory.prefix(3)) { pattern in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath").foregroundStyle(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pattern.learnerFacingSummary).fontWeight(.semibold)
                        Text("Seen \(pattern.occurrenceCount) times · repaired \(pattern.repairedCount) times").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding().background(.background, in: RoundedRectangle(cornerRadius: 16))
            }
            Text("\(progress.repairMissions.filter { $0.completedAt != nil }.count) repair missions completed")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var recentMissionsSection: some View {
        Text("Professional situations practiced").font(.headline)
        if progress.sessionHistory.isEmpty {
            Text("Complete a mission to begin building useful evidence.").foregroundStyle(.secondary)
        } else {
            ForEach(progress.sessionHistory.prefix(10)) { session in
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text(missionTitles[session.missionID] ?? "Professional speaking mission")
                    Spacer()
                    Text("\(max(1, session.durationSeconds / 60)) min").font(.caption).foregroundStyle(.secondary)
                }
                .padding().background(.background, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    @ViewBuilder private var vocabularySection: some View {
        if !progress.vocabulary.isEmpty {
            Text("Vocabulary successfully saved").font(.headline)
            ForEach(progress.vocabulary) { item in
                VStack(alignment: .leading) {
                    Text(item.phrase).fontWeight(.semibold)
                    Text(item.meaning).font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding().background(.background, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct StatCard: View { let value, label, icon: String; let color: Color; var body: some View { VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).foregroundStyle(color); Text(value).font(.system(size: 28, weight: .bold, design: .rounded)); Text(label).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(.background, in: RoundedRectangle(cornerRadius: 20)) } }
