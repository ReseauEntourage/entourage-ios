import Foundation
import SwiftUI
import Combine

enum WelcomeJourneyStepType: Equatable {
    case video
    case webinar
    case papotages
}

struct WelcomeJourneyStep {
    let type: WelcomeJourneyStepType
    let title: String
    let subtitle: String
    let buttonTitle: String
    let completedTitle: String
    let completedSubtitle: String
    let iconName: String
    var isCompleted: Bool
}

class WelcomeJourneyViewModel: ObservableObject {
    @Published var steps: [WelcomeJourneyStep] = []

    // Callbacks to trigger navigation in UIKit
    var onStepTapped: ((WelcomeJourneyStepType) -> Void)?

    func update(with userEvents: [String]?) {
        let events = userEvents ?? []

        let hasWatchedVideo = UserDefaults.standard.bool(forKey: "hasWatchedWelcomeVideo") || events.contains("onboarding.resource.welcome_watched")
        let hasJoinedWebinar = events.contains("onboarding.outing.webinar_or_first_steps")
        let hasJoinedPapotages = events.contains("onboarding.outing.papotages")

        steps = [
            WelcomeJourneyStep(
                type: .video,
                title: "home_v2_welcome_video_title".localized,
                subtitle: "home_v2_welcome_video_subtitle".localized,
                buttonTitle: "home_v2_welcome_video_btn".localized,
                completedTitle: "home_v2_welcome_video_completed_title".localized,
                completedSubtitle: "home_v2_welcome_video_completed_subtitle".localized,
                iconName: "checkmark.circle",
                isCompleted: hasWatchedVideo
            ),
            WelcomeJourneyStep(
                type: .webinar,
                title: "home_v2_welcome_webinar_title".localized,
                subtitle: "home_v2_welcome_webinar_subtitle".localized,
                buttonTitle: "home_v2_welcome_webinar_btn".localized,
                completedTitle: "home_v2_welcome_webinar_completed_title".localized,
                completedSubtitle: "home_v2_welcome_webinar_completed_subtitle".localized,
                iconName: "person.2",
                isCompleted: hasJoinedWebinar
            ),
            WelcomeJourneyStep(
                type: .papotages,
                title: "home_v2_welcome_papotages_title".localized,
                subtitle: "home_v2_welcome_papotages_subtitle".localized,
                buttonTitle: "home_v2_welcome_papotages_btn".localized,
                completedTitle: "home_v2_welcome_papotages_completed_title".localized,
                completedSubtitle: "home_v2_welcome_papotages_completed_subtitle".localized,
                iconName: "bubble.right",
                isCompleted: hasJoinedPapotages
            )
        ]
    }

    var completedCount: Int {
        steps.filter { $0.isCompleted }.count
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
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .bottom) {
                Text("home_v2_welcome_title".localized)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.black)
                Spacer()
                Text("\(viewModel.completedCount)/\(viewModel.steps.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("orange_app"))
            }
            .padding(.horizontal, 20)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 12)

                    let progressWidth = geometry.size.width * CGFloat(viewModel.completedCount) / CGFloat(max(1, viewModel.steps.count))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("orange_app"))
                        .frame(width: progressWidth, height: 12)
                        .animation(.easeInOut, value: viewModel.completedCount)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, 20)

            // Microcopy
            Text("Continuez comme ça, vous allez y arriver 🌟") // Mockup static text - wait, maybe use microcopy logic but just this text
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.black)
                .padding(.horizontal, 20)

            // Steps List
            VStack(spacing: 12) {
                ForEach(viewModel.steps.indices, id: \.self) { index in
                    let step = viewModel.steps[index]
                    WelcomeJourneyStepView(step: step) {
                        viewModel.onStepTapped?(step.type)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .background(Color("white_orange_home")) // matches the table view background
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct WelcomeJourneyStepView: View {
    let step: WelcomeJourneyStep
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(step.isCompleted ? Color("green_light") : Color("orange_light_a50").opacity(0.3))
                            .frame(width: 44, height: 44)

                        Image(systemName: step.iconName)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(step.isCompleted ? .white : Color("orange_app"))
                    }

                    // Texts
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text(step.isCompleted ? step.completedTitle : step.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(step.isCompleted ? Color("green_logout") : Color.black)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            if step.isCompleted {
                                Text("home_v2_welcome_done".localized)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color("green_logout"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("green_light"), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                            } else {
                                Text("home_v2_welcome_todo".localized)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color("orange_app"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color("orange_light_a50").opacity(0.3))
                                    .cornerRadius(12)
                            }
                        }

                        Text(step.isCompleted ? step.completedSubtitle : step.subtitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(step.isCompleted ? Color("green_light") : Color("grey"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }

                // CTA Button (only if not completed)
                if !step.isCompleted {
                    Text(step.buttonTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("orange_app"))
                        .cornerRadius(12)
                        .padding(.top, 8)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(step.isCompleted ? Color("green_light").opacity(0.5) : Color(UIColor.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
