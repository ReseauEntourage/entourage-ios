import SwiftUI

struct BadgeUnlockedSheet: View {
    let definition: BadgeDefinition
    let firstName: String
    let onSeeBadges: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Top beige area with animated dots + emoji
            ZStack {
                Color(UIColor.appOrangeLight).opacity(0.3)
                BadgeDotsAnimationView()
                Image(definition.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)

            // Bottom white content
            VStack(spacing: 16) {
                Text(String(format: "badge_unlocked_bravo".localized, firstName))
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 24) ?? .systemFont(ofSize: 24)))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("badge_unlocked_subtitle".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .multilineTextAlignment(.center)

                Text(definition.titleKey.localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? .systemFont(ofSize: 18)))
                    .foregroundColor(Color(UIColor.appOrange))
                    .multilineTextAlignment(.center)

                Text(definition.unlockedMessageKey.localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer().frame(height: 8)

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onSeeBadges()
                }) {
                    Text("badge_unlocked_see_badges".localized)
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? .systemFont(ofSize: 16)))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(UIColor.appOrange))
                        .cornerRadius(30)
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("badge_unlocked_continue".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(Color(UIColor.appGris112))
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .background(Color.white)
        }
        .overlay(
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color(UIColor.appGris112))
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }
            .padding(16),
            alignment: .topTrailing
        )
        .edgesIgnoringSafeArea(.top)
    }
}
