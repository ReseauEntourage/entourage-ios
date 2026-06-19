import SwiftUI

struct BadgesSectionView: View {
    let apiBadges: [UserBadgeAPI]
    let isMe: Bool
    let onShowAllBadges: () -> Void
    let onBadgeTap: ((UserBadgeProgress) -> Void)?  // nil pour les autres profils

    private var displayedProgress: [UserBadgeProgress] {
        let all = buildBadgeProgress(apiBadges: apiBadges)
        let obtained = all.filter { $0.isObtained }
        return obtained.isEmpty ? all : obtained
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("badges_section_title".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)))
                    .foregroundColor(.black)
                    .kerning(0.8)

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
        VStack(spacing: 6) {
            Text(progress.definition.emoji)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .multilineTextAlignment(.center)
                .opacity(progress.isObtained ? 1.0 : 0.4)

            Text(progress.definition.titleKey.localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                .foregroundColor(progress.isObtained ? .black : Color(UIColor.appGris112))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 76)
        }
        .frame(width: 96, height: 110)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progress.isObtained ? Color(UIColor.appOrange) : Color(UIColor.systemGray4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
