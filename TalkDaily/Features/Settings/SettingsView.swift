import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var app: AppViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showingEditPlan = false
    @State private var showingAddVocabulary = false
    @State private var reminderEnabled = PracticeReminderScheduler.isEnabled
    @State private var reminderPermissionDenied = false

    var body: some View {
        NavigationStack {
            List {
                Section("Career speaking plan") {
                    if let profile = app.data.profile {
                        LabeledContent("Level", value: "\(profile.englishLevel.title) · \(profile.englishLevel.cefrHint)")
                        LabeledContent("Role", value: profile.profession.title)
                        LabeledContent("Career goal", value: profile.careerGoal.title)
                        LabeledContent("Daily target", value: profile.dailyPracticeTarget.title)
                        Button("Edit my plan") { showingEditPlan = true }
                    }
                }

                Section("Coaching") {
                    Label("AI voice coaching is not connected in this build.", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                }

                Section {
                    ForEach(app.data.progress.vocabulary) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.phrase).fontWeight(.semibold)
                            Text(item.meaning).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Button {
                        showingAddVocabulary = true
                    } label: {
                        Label("Add a word or phrase", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Saved vocabulary")
                } footer: {
                    Text("Save a word or phrase you want to remember from a mission or elsewhere. It will also appear in Progress.")
                }

                Section {
                    Toggle("Daily practice reminder", isOn: reminderBinding)
                    if reminderPermissionDenied {
                        Label("Notifications are turned off for Phravora. Enable them in Settings to get a daily reminder.", systemImage: "bell.slash")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("A once-a-day reminder to practise. Off by default; nothing is scheduled until you turn this on.")
                }

                Section {
                    Text("Practice history, your speaking plan, and saved vocabulary are stored only on this device in the current build. Your spoken audio itself is never recorded to a file or uploaded — it is transcribed live on-device and discarded once a mission ends.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Privacy")
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete my data", systemImage: "trash")
                    }
                } header: {
                    Text("Your data")
                } footer: {
                    Text("Permanently erases your speaking plan, progress, and vocabulary from this device and returns you to onboarding.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete all your data?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete my data", role: .destructive) {
                    Task { await app.resetAllData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes your speaking plan, progress, and vocabulary from this device. This cannot be undone.")
            }
            .sheet(isPresented: $showingEditPlan) {
                if let profile = app.data.profile {
                    EditProfileView(profile: profile) { level, profession, careerGoal, situations, dailyTarget in
                        Task { await app.updateProfile(level: level, profession: profession, careerGoal: careerGoal, difficultSituations: situations, dailyTarget: dailyTarget) }
                    }
                }
            }
            .sheet(isPresented: $showingAddVocabulary) {
                AddVocabularyView { phrase, meaning in
                    Task { await app.addVocabulary(phrase: phrase, meaning: meaning) }
                }
            }
        }
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { reminderEnabled },
            set: { newValue in
                Task {
                    if newValue {
                        let granted = await PracticeReminderScheduler.enable()
                        reminderEnabled = granted
                        reminderPermissionDenied = !granted
                    } else {
                        PracticeReminderScheduler.disable()
                        reminderEnabled = false
                        reminderPermissionDenied = false
                    }
                }
            }
        )
    }
}

/// Lets a learner revise onboarding answers later, exactly as onboarding
/// promises ("you can change any of this later in Settings").
private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var level: EnglishLevel
    @State private var profession: Profession
    @State private var careerGoal: CareerGoal
    @State private var situations: Set<DifficultSituation>
    @State private var dailyTarget: DailyPracticeTarget
    let onSave: (EnglishLevel, Profession, CareerGoal, Set<DifficultSituation>, DailyPracticeTarget) -> Void

    init(profile: UserProfile, onSave: @escaping (EnglishLevel, Profession, CareerGoal, Set<DifficultSituation>, DailyPracticeTarget) -> Void) {
        _level = State(initialValue: profile.englishLevel)
        _profession = State(initialValue: profile.profession)
        _careerGoal = State(initialValue: profile.careerGoal)
        _situations = State(initialValue: profile.difficultSituations)
        _dailyTarget = State(initialValue: profile.dailyPracticeTarget)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your level").font(.headline)
                    ForEach(EnglishLevel.allCases) { item in
                        PickerRow(title: item.title, subtitle: "\(item.cefrHint) · \(item.description)", icon: "text.bubble", isSelected: level == item) { level = item }
                    }
                    Text("Your profession").font(.headline).padding(.top, 8)
                    ForEach(Profession.allCases) { item in
                        PickerRow(title: item.title, icon: "briefcase", isSelected: profession == item) { profession = item }
                    }
                    Text("Your career goal").font(.headline).padding(.top, 8)
                    ForEach(CareerGoal.allCases) { item in
                        PickerRow(title: item.title, icon: "flag", isSelected: careerGoal == item) { careerGoal = item }
                    }
                    Text("What feels difficult?").font(.headline).padding(.top, 8)
                    ForEach(DifficultSituation.allCases) { item in
                        PickerRow(title: item.title, icon: "briefcase", isSelected: situations.contains(item)) { situations.formSymmetricDifference([item]) }
                    }
                    Text("Daily target").font(.headline).padding(.top, 8)
                    ForEach(DailyPracticeTarget.allCases) { item in
                        PickerRow(title: item.title, icon: "clock", isSelected: dailyTarget == item) { dailyTarget = item }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(AppTheme.canvas)
            .navigationTitle("Edit plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(level, profession, careerGoal, situations, dailyTarget)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

private struct AddVocabularyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phrase = ""
    @State private var meaning = ""
    let onSave: (String, String) -> Void

    private var canSave: Bool { !phrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Word or phrase") {
                    TextField("e.g. \"follow up\"", text: $phrase)
                }
                Section("Meaning or note") {
                    TextField("What it means, or how to use it", text: $meaning, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(phrase.trimmingCharacters(in: .whitespacesAndNewlines), meaning.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
        }
    }
}

/// A small, self-contained daily-reminder feature. It intentionally does not
/// touch `LocalUserData`/`UserProfile` (so it can never break decoding of
/// data already saved on a learner's device) and it never schedules anything
/// until the learner explicitly turns it on and grants permission — in line
/// with "ask for access in context" from PRODUCT_UX_PRINCIPLES.md.
///
/// This lives here (rather than its own file) because TalkDaily.xcodeproj
/// lists source files explicitly in project.pbxproj, which this change
/// intentionally does not touch — adding a new file would need a matching
/// project.pbxproj entry to actually be compiled.
private enum PracticeReminderScheduler {
    private static let enabledKey = "talkdaily.daily-reminder-enabled.v1"
    private static let notificationID = "talkdaily.daily-reminder"

    /// Whether the learner has turned the reminder on. This reflects local
    /// intent only; `enable()` is what actually confirms permission is
    /// granted before this becomes true.
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    /// Requests notification permission (if needed) and schedules a daily
    /// reminder at the given hour. Returns false without changing anything
    /// persisted if the learner declines the system permission prompt.
    @discardableResult
    static func enable(hour: Int = 18) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        let alreadyAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        let granted: Bool
        if alreadyAuthorized {
            granted = true
        } else if settings.authorizationStatus == .notDetermined {
            granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        } else {
            granted = false
        }

        guard granted else {
            UserDefaults.standard.set(false, forKey: enabledKey)
            return false
        }

        UserDefaults.standard.set(true, forKey: enabledKey)
        schedule(hour: hour)
        return true
    }

    static func disable() {
        UserDefaults.standard.set(false, forKey: enabledKey)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    private static func schedule(hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to practise"
        content.body = "A few minutes of speaking practice keeps your streak going."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])
        center.add(request)
    }
}
