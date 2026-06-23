import SwiftUI

struct BadgesSectionView: View {
    let apiBadges: [UserBadgeAPI]
    let isMe: Bool
    let onShowAllBadges: () -> Void
    let onBadgeTap: ((UserBadgeProgress) -> Void)?  // nil pour les autres profils

    private var displayedProgress: [UserBadgeProgress] {
        buildBadgeProgress(apiBadges: apiBadges).filter { $0.isObtained }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("badges_section_title".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)))
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
                HStack(spacing: 8) {
                    ForEach(displayedProgress, id: \.definition.key.rawValue) { p in
                        BadgeProfileCardView(progress: p)
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

    var body: some View {
        VStack(spacing: 5) {
            Text(progress.definition.emoji)
                .font(.system(size: 22))
                .frame(width: 38, height: 38)
                .multilineTextAlignment(.center)
                .opacity(progress.isObtained ? 1.0 : 0.4)

            Text(progress.definition.titleKey.localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 12) ?? .systemFont(ofSize: 12)))
                .foregroundColor(progress.isObtained ? .black : Color(UIColor.appGris112))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
        }
        .frame(width: 77, height: 88)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.appOrange).opacity(progress.isObtained ? 0.35 : 0.15), lineWidth: 1)
        )
    }
}
