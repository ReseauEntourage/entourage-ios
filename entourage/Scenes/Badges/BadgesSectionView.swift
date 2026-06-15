import SwiftUI

struct BadgesSectionView: View {
    let obtainedKeys: [String]
    let onShowAllBadges: () -> Void
    let onBadgeTap: (UserBadgeProgress) -> Void

    private var obtainedProgress: [UserBadgeProgress] {
        buildBadgeProgress(obtainedKeys: obtainedKeys).filter { $0.isObtained }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("badges_section_title".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(.black)
                    .textCase(.uppercase)

                Spacer()

                Button(action: onShowAllBadges) {
                    Text("badges_see_all".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                        .foregroundColor(Color(UIColor.appOrange))
                }
            }

            if obtainedProgress.isEmpty {
                Text("badges_none_yet".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(obtainedProgress, id: \.definition.key.rawValue) { p in
                            BadgePillView(progress: p)
                                .onTapGesture { onBadgeTap(p) }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

private struct BadgePillView: View {
    let progress: UserBadgeProgress

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.appOrangeLight).opacity(0.4))
                    .frame(width: 56, height: 56)
                Text(progress.definition.emoji)
                    .font(.system(size: 30))
            }

            Text(progress.definition.titleKey.localized)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)
        }
        .frame(width: 80)
    }
}
