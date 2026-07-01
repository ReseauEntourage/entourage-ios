import SwiftUI

struct BadgesSectionView: View {
    let apiBadges: [UserBadgeAPI]
    let isMe: Bool
    let onShowAllBadges: () -> Void
    let onBadgeTap: ((UserBadgeProgress) -> Void)?  // nil pour les autres profils

    private var displayedProgress: [UserBadgeProgress] {
        buildBadgeProgress(apiBadges: apiBadges)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("badges_section_title".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)))
                    .foregroundColor(.black)

                Spacer()

                if isMe {
                    Button(action: onShowAllBadges) {
                        Text("badges_see_all".localized)
                            .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)))
                            .foregroundColor(Color(UIColor.appOrange))
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(displayedProgress, id: \.definition.key.rawValue) { p in
                        BadgeProfileCardView(progress: p, showProgressWhenObtained: isMe)
                            .onTapGesture {
                                if let tap = onBadgeTap {
                                    tap(p)
                                }
                            }
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }
}

private struct BadgeProfileCardView: View {
    let progress: UserBadgeProgress
    var showProgressWhenObtained: Bool = false

    private var isObtained: Bool { progress.isObtained }
    private var isInProgress: Bool { !progress.isObtained && progress.progress > 0 }

    var body: some View {
        VStack(spacing: 6) {
            Image(progress.definition.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .opacity(isObtained || isInProgress ? 1.0 : 0.4)

            Text(progress.definition.titleKey.localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 12) ?? .systemFont(ofSize: 12)))
                .foregroundColor(isObtained ? .black : Color(UIColor.appGris112))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100, height: 32, alignment: .center)

            statusLabel
                .frame(height: 28, alignment: .top)
        }
        .frame(width: 120)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.appOrange).opacity(isObtained ? 0.4 : 0.15), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var statusLabel: some View {
        if isObtained {
            VStack(spacing: 2) {
                Text("badge_obtained".localized)
                    .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 10) ?? .systemFont(ofSize: 10, weight: .semibold)))
                    .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
            }
        } else if isInProgress {
            Text("\(progress.progress)/\(progress.target)")
                .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 10) ?? .systemFont(ofSize: 10, weight: .semibold)))
                .foregroundColor(Color(UIColor.appOrange))
        } else {
            Text("badge_not_obtained".localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 10) ?? .systemFont(ofSize: 10)))
                .foregroundColor(Color(UIColor.appGris112))
        }
    }
}
