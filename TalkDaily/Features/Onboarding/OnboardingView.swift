import SwiftUI

/// Onboarding used to be one long scrolling list of every question at once.
/// It's now a short series of single-purpose steps with a progress bar, so a
/// learner always knows what's being asked and how much is left — the goal
/// from PRODUCT_UX_PRINCIPLES.md ("Onboarding ... should lead directly to a
/// first mission") without changing any of the underlying data collected.
struct OnboardingView: View {
    @EnvironmentObject private var app: AppViewModel
    @State private var step = 0
    @State private var level: EnglishLevel = .beginner
    @State private var profession: Profession = .softwareDeveloper
    @State private var careerGoal: CareerGoal = .getHired
    @State private var situations = Set<DifficultSituation>()
    @State private var dailyTarget: DailyPracticeTarget = .ten

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OnboardingProgressBar(step: step, totalSteps: totalSteps)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        stepContent
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                footer
            }
            .background(AppTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if step > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation { step -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel("Back")
                    }
                }
            }
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 0: levelStep
        case 1: professionStep
        case 2: goalStep
        case 3: situationsStep
        default: targetStep
        }
    }

    private var footer: some View {
        Button(step < totalSteps - 1 ? "Continue" : "Build my career speaking plan") {
            if step < totalSteps - 1 {
                withAnimation { step += 1 }
            } else {
                Task {
                    await app.completeOnboarding(
                        level: level,
                        profession: profession,
                        careerGoal: careerGoal,
                        difficultSituations: situations,
                        dailyTarget: dailyTarget
                    )
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(24)
    }

    @ViewBuilder private var levelStep: some View {
        Image(systemName: "quote.bubble.fill").font(.system(size: 36)).foregroundStyle(AppTheme.primary).accessibilityHidden(true)
        Text("Speak English\nfor your career.").font(.largeTitle.bold())
        Text("A few quick questions build your speaking plan. You can change any of this later in Settings.")
            .foregroundStyle(.secondary)
        Text("Your level").font(.headline).padding(.top, 8)
        ForEach(EnglishLevel.allCases) { item in
            PickerRow(title: item.title, subtitle: "\(item.cefrHint) · \(item.description)", icon: "text.bubble", isSelected: level == item) { level = item }
        }
    }

    @ViewBuilder private var professionStep: some View {
        stepHeader(icon: "briefcase.fill", title: "Your profession", subtitle: "We use this to pick relevant mission scenarios.")
        ForEach(Profession.allCases) { item in
            PickerRow(title: item.title, icon: "briefcase", isSelected: profession == item) { profession = item }
        }
    }

    @ViewBuilder private var goalStep: some View {
        stepHeader(icon: "flag.checkered", title: "Your career goal", subtitle: "What's the main thing you're working towards?")
        ForEach(CareerGoal.allCases) { item in
            PickerRow(title: item.title, icon: "flag", isSelected: careerGoal == item) { careerGoal = item }
        }
    }

    @ViewBuilder private var situationsStep: some View {
        stepHeader(icon: "exclamationmark.bubble", title: "What feels difficult?", subtitle: "Pick as many as apply. We'll prioritise these in your mission plan.")
        ForEach(DifficultSituation.allCases) { item in
            PickerRow(title: item.title, subtitle: "Prioritise this in your mission plan", icon: "briefcase", isSelected: situations.contains(item)) { situations.formSymmetricDifference([item]) }
        }
    }

    @ViewBuilder private var targetStep: some View {
        stepHeader(icon: "clock.fill", title: "Daily target", subtitle: "A realistic daily habit beats an ambitious one you skip.")
        ForEach(DailyPracticeTarget.allCases) { item in
            PickerRow(title: item.title, icon: "clock", isSelected: dailyTarget == item) { dailyTarget = item }
        }
    }

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 32)).foregroundStyle(AppTheme.primary).accessibilityHidden(true)
            Text(title).font(.title.bold())
            Text(subtitle).foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)
    }
}

private struct OnboardingProgressBar: View {
    let step: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? AppTheme.primary : AppTheme.primary.opacity(0.15))
                    .frame(height: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step + 1) of \(totalSteps)")
    }
}

struct PickerRow: View {
    let title: String
    var subtitle: String = ""
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).frame(width: 28).foregroundStyle(AppTheme.primary)
                VStack(alignment: .leading, spacing: subtitle.isEmpty ? 0 : 2) {
                    Text(title).fontWeight(.semibold)
                    if !subtitle.isEmpty {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle").foregroundStyle(isSelected ? AppTheme.primary : .secondary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
