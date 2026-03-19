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
                iconName: "video",
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
                iconName: "bubble.left.and.bubble.right",
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
                    .foregroundColor(Color("black"))
                Spacer()
                Text(viewModel.progressText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("appOrange"))
            }
            .padding(.horizontal, 20)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 8)

                    let progressWidth = geometry.size.width * CGFloat(viewModel.completedCount) / CGFloat(max(1, viewModel.steps.count))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("appOrange"))
                        .frame(width: progressWidth, height: 8)
                        .animation(.easeInOut, value: viewModel.completedCount)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 20)

            // Microcopy
            Text(viewModel.microcopy)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("black"))
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
                            .fill(step.isCompleted ? Color("appOrangeLight").opacity(0.3) : Color("appOrangeLight"))
                            .frame(width: 40, height: 40)

                        Image(systemName: step.iconName)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(step.isCompleted ? Color("appOrange") : Color("appOrange"))
                    }

                    // Texts
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(step.isCompleted ? step.completedTitle : step.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("black"))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if step.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color("appOrange"))
                                Text("home_v2_welcome_done".localized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color("appOrange"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color("appOrangeLight").opacity(0.5))
                                    .cornerRadius(12)
                            } else {
                                Text("home_v2_welcome_todo".localized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color("appOrange"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color("appOrangeLight").opacity(0.5))
                                    .cornerRadius(12)
                            }
                        }

                        Text(step.isCompleted ? step.completedSubtitle : step.subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // CTA Button (only if not completed)
                if !step.isCompleted {
                    Text(step.buttonTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("appOrange"))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(step.isCompleted ? Color("white_orange_home") : Color.white) // Adjust background based on completed state
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(step.isCompleted ? 0.0 : 0.05), radius: 5, x: 0, y: 2)
            // Border if completed
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(step.isCompleted ? Color(UIColor.systemGray5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
