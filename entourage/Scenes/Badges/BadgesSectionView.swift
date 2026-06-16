import SwiftUI

struct BadgesSectionView: View {
    let obtainedKeys: [String]
    let onShowAllBadges: () -> Void
    let onBadgeTap: (UserBadgeProgress) -> Void

    private var obtainedProgress: [UserBadgeProgress] {
        buildBadgeProgress(obtainedKeys: obtainedKeys).filter { $0.isObtained }
    }

    private var displayedProgress: [UserBadgeProgress] {
        let all = buildBadgeProgress(obtainedKeys: obtainedKeys)
        let obtained = all.filter { $0.isObtained }
        return obtained.isEmpty ? all : obtained
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title row
            HStack {
                Text("badges_section_title".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)))
                    .foregroundColor(.black)
                    .kerning(0.8)

                Spacer()

                Button(action: onShowAllBadges) {
                    Text("badges_see_all".localized)
                        .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)))
                        .foregroundColor(Color(UIColor.appOrange))
                }
            }

            // Horizontal badge cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(displayedProgress, id: \.definition.key.rawValue) { p in
                        BadgeProfileCardView(progress: p)
                            .onTapGesture { onBadgeTap(p) }
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

            Text(progress.definition.titleKey.localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 76)
        }
        .frame(width: 96, height: 110)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(UIColor.appOrange), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
