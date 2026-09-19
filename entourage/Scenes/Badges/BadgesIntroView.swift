import SwiftUI

struct BadgesIntroView: View {
    let onDiscover: () -> Void
    let onDismiss: () -> Void

    @Environment(\.presentationMode) var presentationMode

    private struct IntroPoint {
        let circleColor: Color
        let dotColor: Color
        let title: String
        let body: String
    }

    private let points: [IntroPoint] = [
        IntroPoint(
            circleColor: Color(red: 0.99, green: 0.92, blue: 0.90),
            dotColor: Color(UIColor.appOrange),
            title: "badges_intro_point1_title".localized,
            body: "badges_intro_point1_body".localized
        ),
        IntroPoint(
            circleColor: Color(red: 0.88, green: 0.96, blue: 0.91),
            dotColor: Color(red: 0.18, green: 0.55, blue: 0.34),
            title: "badges_intro_point2_title".localized,
            body: "badges_intro_point2_body".localized
        ),
        IntroPoint(
            circleColor: Color(red: 0.99, green: 0.97, blue: 0.88),
            dotColor: Color(red: 0.85, green: 0.68, blue: 0.22),
            title: "badges_intro_point3_title".localized,
            body: "badges_intro_point3_body".localized
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(UIColor.appGris112))
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            ScrollView {
                VStack(spacing: 0) {
                    // En-tête beige avec images des badges
                    HStack(spacing: 12) {
                        ForEach(allBadgeDefinitions, id: \.key.rawValue) { def in
                            Image(def.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 28)
                    .background(Color(UIColor.appOrangeLight).opacity(0.35))
                    .frame(maxWidth: .infinity)

                    // Corps
                    VStack(spacing: 32) {
                        // Titre + sous-titre
                        VStack(spacing: 10) {
                            Text("badges_intro_title".localized)
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 26) ?? .systemFont(ofSize: 26, weight: .bold)))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)

                            Text("badges_intro_subtitle".localized)
                                .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                                .foregroundColor(Color(UIColor.appGris112))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)

                        // Points
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(0..<points.count, id: \.self) { i in
                                introPointRow(points[i])
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Boutons
                        VStack(spacing: 12) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                onDiscover()
                            }) {
                                Text("badges_intro_cta".localized)
                                    .font(Font(UIFont(name: "Quicksand-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(UIColor.appOrange))
                                    .cornerRadius(30)
                            }

                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                onDismiss()
                            }) {
                                Text("badges_intro_later".localized)
                                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    private func introPointRow(_ point: IntroPoint) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Cercle coloré avec point
            ZStack {
                Circle()
                    .fill(point.circleColor)
                    .frame(width: 48, height: 48)
                Circle()
                    .fill(point.dotColor)
                    .frame(width: 14, height: 14)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(point.title)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)))
                    .foregroundColor(.black)

                Text(point.body)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
