import SwiftUI

struct BadgeDetailSheet: View {
    let progress: UserBadgeProgress
    let isMe: Bool
    let onShowAllBadges: () -> Void
    let onCta: () -> Void  // appelé après dismiss, le parent gère la navigation

    @Environment(\.presentationMode) var presentationMode

    private var def: BadgeDefinition { progress.definition }
    private var isObtained: Bool { progress.isObtained }

    private let hPad: CGFloat = 20
    private let sectionSpacing: CGFloat = 10

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: sectionSpacing) {
                    // Emoji + titre — fond blanc
                    VStack(spacing: 8) {
                        Image(def.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 8)

                        Text(def.titleKey.localized)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 22) ?? .systemFont(ofSize: 22)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, hPad)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)

                    // Statut
                    statusCard.padding(.horizontal, hPad)

                    // Comment ça marche
                    sectionCard(title: "badge_how_it_works_title".localized, body: def.howItWorksKey.localized)

                    // Mécanique
                    mechanismCard

                    // Ce que ça représente
                    sectionCard(title: "badge_what_it_means_title".localized, body: def.whatItMeansKey.localized)

                    if isMe {
                        // Boutons CTA
                        VStack(spacing: 12) {
                            Button(action: handleCta) {
                                Text(ctaLabel)
                                    .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? .systemFont(ofSize: 16)))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(UIColor.appOrange))
                                    .cornerRadius(30)
                            }

                            if !isObtained {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        onShowAllBadges()
                                    }
                                }) {
                                    Text("badge_see_all_badges".localized)
                                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                                        .foregroundColor(Color(UIColor.appOrange))
                                }
                            }
                        }
                        .padding(.horizontal, hPad)
                        .padding(.bottom, 32)
                    }
                }
                .padding(.top, sectionSpacing)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("badge_detail_title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    // MARK: - CTA

    private var ctaLabel: String {
        isObtained ? def.ctaObtainedLabelKey.localized : def.ctaLabelKey.localized
    }

    private func handleCta() {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onCta()
        }
    }

    // MARK: - Status card

    @ViewBuilder
    private var statusCard: some View {
        if isObtained {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                    .font(.system(size: 16, weight: .bold))
                let dateText = progress.obtainedDate.map { formatBadgeDate($0) } ?? ""
                if dateText.isEmpty {
                    Text("badge_obtained".localized)
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                } else {
                    Text(String(format: "badge_obtained_on".localized, dateText))
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.18, green: 0.65, blue: 0.37).opacity(0.3), lineWidth: 1))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                // Progression header
                HStack {
                    Text("badge_your_progress".localized)
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(progress.progress)/\(progress.target)")
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(Color(UIColor.appOrange))
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(UIColor.appOrange))
                            .frame(width: geo.size.width * CGFloat(progress.progress) / CGFloat(max(progress.target, 1)), height: 8)
                    }
                }
                .frame(height: 8)

                Text(def.progressHint(remaining: max(0, progress.target - progress.progress)))
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(UIColor.systemGray4), lineWidth: 1))
        }
    }

    // MARK: - Sections

    private func sectionCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 13) ?? .systemFont(ofSize: 13)))
                .foregroundColor(Color(UIColor.appGris112))
                .textCase(.uppercase)
            Text(body)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, hPad)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var mechanismCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("badge_mechanism_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 13) ?? .systemFont(ofSize: 13)))
                .foregroundColor(Color(UIColor.appGris112))
                .textCase(.uppercase)

            HStack(spacing: 8) {
                Image(systemName: def.isReversible ? "xmark.circle" : "checkmark.circle.fill")
                    .foregroundColor(def.isReversible ? Color(UIColor.appOrange) : Color(red: 0.18, green: 0.65, blue: 0.37))
                    .font(.system(size: 18))
                    .frame(width: 20)
                Text(def.mechanismKey.localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, hPad)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
    }
}
