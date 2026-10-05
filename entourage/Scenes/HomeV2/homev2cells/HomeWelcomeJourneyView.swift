import Foundation
import SwiftUI
import Combine

enum WelcomeJourneyStepType: Equatable, CaseIterable {
    case video
    case nationalGroups
    case webinar
    case papotages

    /// Event renvoyé par `home/summary` quand l'étape est réellement faite.
    var completedEvent: String {
        switch self {
        case .video: return "onboarding.resource.welcome_watched"
        case .nationalGroups: return "onboarding.neighborhood.national"
        case .webinar: return "onboarding.outing.webinar_or_first_steps"
        case .papotages: return "onboarding.outing.papotages"
        }
    }

    /// Event renvoyé par `home/summary` quand l'étape a été passée (`..._skipped`).
    var skippedEvent: String { completedEvent + "_skipped" }

    /// Valeur du paramètre `step` de `POST users/onboarding_step_skipped`.
    var skipApiStep: String {
        switch self {
        case .video: return "welcome_watched"
        case .nationalGroups: return "neighborhood_national"
        case .webinar: return "webinar_or_first_steps"
        case .papotages: return "papotages"
        }
    }

    /// Suffixe des accessibilityIdentifier (tests UI) : welcome_step_<id>, welcome_step_<id>_skip…
    var identifier: String {
        switch self {
        case .video: return "video"
        case .nationalGroups: return "national"
        case .webinar: return "webinar"
        case .papotages: return "papotages"
        }
    }
}

enum WelcomeJourneyStepState {
    case completed
    case skipped
    case active
}

struct WelcomeJourneyStep {
    let type: WelcomeJourneyStepType
    let title: String
    let subtitle: String
    let buttonTitle: String
    let iconName: String
    var state: WelcomeJourneyStepState = .active
}

class WelcomeJourneyViewModel: ObservableObject {
    @Published var steps: [WelcomeJourneyStep] = []
    @Published var isFullyCompleted: Bool = false
    @Published var hideEntirely: Bool = false

    var onStepTapped: ((WelcomeJourneyStepType) -> Void)?
    var onSkipTapped: ((WelcomeJourneyStepType) -> Void)?

    /// Les étapes ne sont plus verrouillées : chacune est "terminée", "passée" ou "à faire"
    /// indépendamment des autres.
    static func state(of type: WelcomeJourneyStepType, events: [String]) -> WelcomeJourneyStepState {
        if events.contains(type.completedEvent) { return .completed }
        if events.contains(type.skippedEvent) { return .skipped }
        return .active
    }

    func update(with userEvents: [String]?, groupCount: Int, hasInitiallyCompletedAll: inout Bool?) {
        let events = userEvents ?? []

        // On se fie uniquement au backend pour l'état d'avancement
        let states = WelcomeJourneyStepType.allCases.map { Self.state(of: $0, events: events) }
        // Une étape passée est considérée comme résolue, comme une étape terminée.
        let allResolved = states.allSatisfy { $0 != .active }

        if hasInitiallyCompletedAll == nil {
            hasInitiallyCompletedAll = allResolved
        }

        // Si l'utilisateur avait déjà tout résolu initialement, on cache entièrement
        if hasInitiallyCompletedAll == true {
            self.hideEntirely = true
            return
        }

        // Tout est résolu mais au moins une étape a été passée : pas d'encart de réussite,
        // on retire simplement tout le parcours. L'encart vert n'est affiché que si tout a été réellement fait.
        if allResolved && states.contains(.skipped) {
            self.hideEntirely = true
            self.isFullyCompleted = false
            return
        }

        self.hideEntirely = false
        self.isFullyCompleted = allResolved

        steps = [
            WelcomeJourneyStep(
                type: .video,
                title: "home_v2_welcome_video_title".localized,
                subtitle: "home_v2_welcome_video_subtitle".localized,
                buttonTitle: "home_v2_welcome_video_btn".localized,
                iconName: "video.fill",
                state: states[0]
            ),
            WelcomeJourneyStep(
                type: .nationalGroups,
                title: "home_v2_welcome_national_title".localized,
                subtitle: "home_v2_welcome_national_subtitle".localized,
                buttonTitle: "home_v2_welcome_national_btn".localized,
                iconName: "person.3.fill",
                state: states[1]
            ),
            WelcomeJourneyStep(
                type: .webinar,
                title: "home_v2_welcome_webinar_title".localized,
                subtitle: "home_v2_welcome_webinar_subtitle".localized,
                buttonTitle: "home_v2_welcome_webinar_btn".localized,
                iconName: "person.2.fill",
                state: states[2]
            ),
            WelcomeJourneyStep(
                type: .papotages,
                title: "home_v2_welcome_papotages_title".localized,
                subtitle: "home_v2_welcome_papotages_subtitle".localized,
                buttonTitle: "home_v2_welcome_papotages_btn".localized,
                iconName: "message.fill",
                state: states[3]
            )
        ]
    }
    var completedCount: Int {
        steps.filter { $0.state == .completed }.count
    }

    var skippedCount: Int {
        steps.filter { $0.state == .skipped }.count
    }

    var progressText: String {
        return String(format: "home_v2_welcome_progress".localized, completedCount, steps.count)
    }

    var microcopy: String {
        switch completedCount {
        case 0: return "home_v2_welcome_microcopy_0".localized
        case 1: return "home_v2_welcome_microcopy_1".localized
        case 2: return "home_v2_welcome_microcopy_2".localized
        case 3: return "home_v2_welcome_microcopy_3".localized
        default: return "home_v2_welcome_microcopy_4".localized
        }
    }
}

struct HomeWelcomeJourneyView: View {
    @ObservedObject var viewModel: WelcomeJourneyViewModel

    var body: some View {
        if viewModel.hideEntirely {
            EmptyView()
        } else {
            // Espacements réduits pour compacter la vue
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .bottom) {
                    Text("home_v2_welcome_title".localized)
                        .font(.custom("Quicksand-Bold", size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    // Affichage du texte uniquement pour le compteur
                    Text("\(viewModel.completedCount)/\(max(viewModel.steps.count, 3))")
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(Color("orange_app"))
                        .accessibilityIdentifier("welcome_journey_counter")
                }
                .padding(.horizontal, 16)

                ProgressView(value: Double(viewModel.completedCount), total: Double(max(viewModel.steps.count, 3)))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("orange_app")))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                if viewModel.isFullyCompleted {
                    // Success Layout
                    VStack(spacing: 0) {
                        Text("home_v2_welcome_microcopy_4".localized)
                            .font(.custom("Quicksand-Bold", size: 15))
                            .foregroundColor(Color("green_middle"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color("green_light").opacity(0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("green_middle"), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .accessibilityIdentifier("welcome_journey_success")
                } else {
                    // Microcopy
                    Text(viewModel.microcopy)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 16)

                    // Steps List : toutes les étapes sont accessibles, dans l'ordre souhaité
                    VStack(spacing: 10) {
                        ForEach(viewModel.steps.indices, id: \.self) { index in
                            let step = viewModel.steps[index]
                            WelcomeJourneyStepView(
                                step: step,
                                onTap: { viewModel.onStepTapped?(step.type) },
                                onSkip: { viewModel.onSkipTapped?(step.type) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .padding(.top, 32)
            .background(Color("white_orange_home")) // matches the table view background
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WelcomeJourneyStepView: View {
    let step: WelcomeJourneyStep
    let onTap: () -> Void
    let onSkip: () -> Void

    private var id: String { "welcome_step_\(step.type.identifier)" }
    private var isSkipped: Bool { step.state == .skipped }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 36, height: 36)

                    Image(systemName: step.state == .completed ? "checkmark" : step.iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconForeground)
                }

                // Texts
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(step.title)
                            .font(.custom("Quicksand-Bold", size: 14))
                            .foregroundColor(titleColor)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 8)
                        chip
                    }

                    Text(step.subtitle)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(step.state == .completed ? Color("green_middle") : Color.gray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)

                    if isSkipped {
                        Button(action: onTap) {
                            Text("home_v2_welcome_redo".localized)
                                .font(.custom("Quicksand-Bold", size: 13))
                                .foregroundColor(Color("orange_app"))
                                .underline()
                                .frame(minHeight: 40, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityIdentifier("\(id)_redo")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if step.state == .active { onTap() }
            }

            // CTA + "Passer" (uniquement si l'étape est à faire)
            if step.state == .active {
                Button(action: onTap) {
                    Text(step.buttonTitle)
                        .font(.custom("Quicksand-Bold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("orange_app"))
                        .cornerRadius(32)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
                .accessibilityIdentifier("\(id)_cta")

                Button(action: onSkip) {
                    Text("home_v2_welcome_skip".localized)
                        .font(.custom("Quicksand-Bold", size: 13))
                        .foregroundColor(Color.gray)
                        .underline()
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("\(id)_skip")
            }
        }
        .padding(14)
        .background(cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, style: StrokeStyle(lineWidth: step.state == .active ? 2 : 1, dash: isSkipped ? [5, 4] : []))
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(id)
        .accessibilityValue(stateValue)
    }

    // MARK: - Style

    /// Valeur exposée à VoiceOver et aux tests UI : done / skipped / todo.
    private var stateValue: String {
        switch step.state {
        case .completed: return "done"
        case .skipped: return "skipped"
        case .active: return "todo"
        }
    }

    private var iconBackground: Color {
        switch step.state {
        case .completed: return Color("green_middle")
        case .skipped: return Color(red: 0.925, green: 0.906, blue: 0.894)
        case .active: return Color("orange_light_a50").opacity(0.3)
        }
    }

    private var iconForeground: Color {
        switch step.state {
        case .completed: return .white
        case .skipped: return Color.gray
        case .active: return Color("orange_app")
        }
    }

    private var titleColor: Color {
        switch step.state {
        case .completed: return Color("green_middle")
        case .skipped: return Color.gray
        case .active: return Color.black
        }
    }

    private var cardBackground: Color {
        isSkipped ? Color(red: 0.969, green: 0.957, blue: 0.949) : Color.white
    }

    private var borderColor: Color {
        switch step.state {
        case .active: return Color("orange_app")
        case .completed: return Color("green_middle")
        case .skipped: return Color(red: 0.812, green: 0.792, blue: 0.792)
        }
    }

    @ViewBuilder
    private var chip: some View {
        switch step.state {
        case .completed:
            Text("home_v2_welcome_done".localized)
                .font(.custom("NunitoSans-Bold", size: 12))
                .foregroundColor(Color("green_middle"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("green_light").opacity(0.15))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("green_middle"), lineWidth: 1)
                )
        case .skipped:
            Text("home_v2_welcome_skipped".localized)
                .font(.custom("NunitoSans-Bold", size: 12))
                .foregroundColor(Color(red: 0.373, green: 0.353, blue: 0.341))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.925, green: 0.906, blue: 0.894))
                .cornerRadius(12)
        case .active:
            Text("home_v2_welcome_todo".localized)
                .font(.custom("NunitoSans-Bold", size: 12))
                .foregroundColor(Color("orange_app"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("orange_light_a50").opacity(0.3))
                .cornerRadius(12)
        }
    }
}
