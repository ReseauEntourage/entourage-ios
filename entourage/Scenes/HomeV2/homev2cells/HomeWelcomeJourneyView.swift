import Foundation
import SwiftUI
import Combine

enum WelcomeJourneyStepType: Equatable {
    case video
    case webinar
    case papotages
}

enum WelcomeJourneyStepState {
    case completed
    case active
    case future
}

struct WelcomeJourneyStep {
    let type: WelcomeJourneyStepType
    let title: String
    let subtitle: String
    let buttonTitle: String
    let iconName: String
    var state: WelcomeJourneyStepState = .future
}

class WelcomeJourneyViewModel: ObservableObject {
    @Published var steps: [WelcomeJourneyStep] = []
    @Published var isFullyCompleted: Bool = false
    @Published var hideEntirely: Bool = false

    var onStepTapped: ((WelcomeJourneyStepType) -> Void)?

    func update(with userEvents: [String]?, hasInitiallyCompletedAll: inout Bool?) {
        let events = userEvents ?? []

        // On se fie uniquement au backend pour l'état d'avancement
        let hasWatchedVideo = events.contains("onboarding.resource.welcome_watched")
        let hasJoinedWebinar = events.contains("onboarding.outing.webinar_or_first_steps")
        let hasJoinedPapotages = events.contains("onboarding.outing.papotagesHack")

        let allCompleted = hasWatchedVideo && hasJoinedWebinar && hasJoinedPapotages

        if hasInitiallyCompletedAll == nil {
            hasInitiallyCompletedAll = allCompleted
        }

        if hasInitiallyCompletedAll == true {
            self.hideEntirely = true
            return
        }

        self.hideEntirely = false
        self.isFullyCompleted = allCompleted

        var step1State: WelcomeJourneyStepState = hasWatchedVideo ? .completed : .active
        var step2State: WelcomeJourneyStepState = .future
        var step3State: WelcomeJourneyStepState = .future

        if step1State == .completed {
            step2State = hasJoinedWebinar ? .completed : .active
        }

        if step2State == .completed {
            step3State = hasJoinedPapotages ? .completed : .active
        }

        steps = [
            WelcomeJourneyStep(
                type: .video,
                title: "home_v2_welcome_video_title".localized,
                subtitle: "home_v2_welcome_video_subtitle".localized,
                buttonTitle: "home_v2_welcome_video_btn".localized,
                iconName: "video.fill",
                state: step1State
            ),
            WelcomeJourneyStep(
                type: .webinar,
                title: "home_v2_welcome_webinar_title".localized,
                subtitle: "home_v2_welcome_webinar_subtitle".localized,
                buttonTitle: "home_v2_welcome_webinar_btn".localized,
                iconName: "person.2.fill",
                state: step2State
            ),
            WelcomeJourneyStep(
                type: .papotages,
                title: "home_v2_welcome_papotages_title".localized,
                subtitle: "home_v2_welcome_papotages_subtitle".localized,
                buttonTitle: "home_v2_welcome_papotages_btn".localized,
                iconName: "message.fill",
                state: step3State
            )
        ]
    }
    var completedCount: Int {
        steps.filter { $0.state == .completed }.count
    }

    var progressText: String {
        return String(format: "home_v2_welcome_progress".localized, completedCount, steps.count)
    }

    var microcopy: String {
        switch completedCount {
        case 0: return "home_v2_welcome_microcopy_0".localized
        case 1: return "home_v2_welcome_microcopy_1".localized
        case 2: return "home_v2_welcome_microcopy_2".localized
        default: return "home_v2_welcome_microcopy_3".localized
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
                }
                .padding(.horizontal, 16)

                ProgressView(value: Double(viewModel.completedCount), total: Double(max(viewModel.steps.count, 3)))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("orange_app")))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                if viewModel.isFullyCompleted {
                    // Success Layout
                    VStack(spacing: 0) {
                        Text("home_v2_welcome_microcopy_3".localized)
                            .font(.custom("Quicksand-Bold", size: 15))
                            .foregroundColor(Color(red: 45/255, green: 104/255, blue: 50/255))
                            .multilineTextAlignment(.center)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color("green_light").opacity(0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 45/255, green: 104/255, blue: 50/255), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } else {
                    // Microcopy
                    Text(viewModel.microcopy)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 16)

                    // Steps List
                    VStack(spacing: 10) {
                        ForEach(viewModel.steps.indices, id: \.self) { index in
                            let step = viewModel.steps[index]
                            WelcomeJourneyStepView(step: step) {
                                if step.state == .active {
                                    viewModel.onStepTapped?(step.type)
                                }
                            }
                            .disabled(step.state != .active)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .padding(.top, 16)
            .background(Color("white_orange_home")) // matches the table view background
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WelcomeJourneyStepView: View {
    let step: WelcomeJourneyStep
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) { // Espacement plus compact
                HStack(alignment: .top, spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(step.state == .completed ? Color(red: 45/255, green: 104/255, blue: 50/255) : Color("orange_light_a50").opacity(0.3))
                            .frame(width: 36, height: 36)

                        Image(systemName: step.state == .completed ? "checkmark" : step.iconName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(step.state == .completed ? .white : Color("orange_app"))
                    }

                    // Texts
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text(step.title)
                                .font(.custom("Quicksand-Bold", size: 14))
                                .foregroundColor(step.state == .completed ? Color(red: 45/255, green: 104/255, blue: 50/255) : (step.state == .future ? Color.gray : Color.black))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            if step.state == .completed {
                                Text("home_v2_welcome_done".localized)
                                    .font(.custom("NunitoSans-Bold", size: 12))
                                    .foregroundColor(Color(red: 45/255, green: 104/255, blue: 50/255))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("green_light").opacity(0.15))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 45/255, green: 104/255, blue: 50/255), lineWidth: 1)
                                    )
                            } else if step.state == .active {
                                Text("home_v2_welcome_todo".localized)
                                    .font(.custom("NunitoSans-Bold", size: 12))
                                    .foregroundColor(Color("orange_app"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("orange_light_a50").opacity(0.3))
                                    .cornerRadius(12)
                            }
                        }

                        Text(step.subtitle)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(step.state == .completed ? Color(red: 45/255, green: 104/255, blue: 50/255) : Color.gray)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                }

                // CTA Button (only if active)
                if step.state == .active {
                    Text(step.buttonTitle)
                        .font(.custom("Quicksand-Bold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color("orange_app"))
                        .cornerRadius(32)
                        .padding(.top, 8)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(step.state == .active ? Color("orange_app") : (step.state == .completed ? Color(red: 45/255, green: 104/255, blue: 50/255) : Color(UIColor.systemGray5)), lineWidth: step.state == .active ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(step.state == .active ? 0.05 : 0), radius: 8, x: 0, y: 2)
            .opacity(step.state == .future ? 0.6 : (step.state == .completed ? 0.9 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
