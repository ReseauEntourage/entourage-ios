import SwiftUI

struct BadgeDetailSheet: View {
    let progress: UserBadgeProgress
    let obtainedKeys: [String]
    let onShowAllBadges: () -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var showUnlocked = false

    private var def: BadgeDefinition { progress.definition }
    // TODO: restore isObtained when backend sends real obtained state
    private var isObtained: Bool { false }

    private let hPad: CGFloat = 20
    private let sectionSpacing: CGFloat = 10

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: sectionSpacing) {
                    // Emoji + title — fond blanc
                    VStack(spacing: 8) {
                        Text(def.emoji)
                            .font(.system(size: 64))
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

                    // Statut obtenu / pas obtenu
                    statusCard
                        .padding(.horizontal, hPad)

                    // Comment ça marche — fond blanc
                    sectionCard(
                        title: "badge_how_it_works_title".localized,
                        body: def.howItWorksKey.localized
                    )

                    // Mécanique — fond blanc
                    mechanismCard

                    // Ce que ça représente — fond blanc
                    sectionCard(
                        title: "badge_what_it_means_title".localized,
                        body: def.whatItMeansKey.localized
                    )

                    // Boutons CTA
                    VStack(spacing: 12) {
                        Button(action: handleCta) {
                            Text(def.ctaLabelKey.localized)
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? .systemFont(ofSize: 16)))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(UIColor.appOrange))
                                .cornerRadius(30)
                        }

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            onShowAllBadges()
                        }) {
                            Text("badge_see_all_badges".localized)
                                .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? .systemFont(ofSize: 15)))
                                .foregroundColor(Color(UIColor.appOrange))
                        }
                    }
                    .padding(.horizontal, hPad)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 0)
                .padding(.top, sectionSpacing)
            }
            .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
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
        .sheet(isPresented: $showUnlocked) {
            BadgeUnlockedSheet(
                definition: def,
                firstName: UserDefaults.currentUser?.firstname ?? "",
                onSeeBadges: {
                    presentationMode.wrappedValue.dismiss()
                    onShowAllBadges()
                }
            )
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
                let dateText = progress.obtainedDate ?? ""
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
            .background(Color(red: 0.88, green: 0.96, blue: 0.91))
            .cornerRadius(12)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.systemGray3))
                        .font(.system(size: 16))
                    Text("badge_not_obtained".localized)
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(.black)
                }

                Text(def.descriptionShortKey.localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))

                if progress.progress > 0 && def.maxProgress > 1 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("badge_your_progress".localized)
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appGris112))
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.appOrange))
                                    .frame(width: geo.size.width * CGFloat(progress.progress) / CGFloat(def.maxProgress), height: 8)
                            }
                        }
                        .frame(height: 8)
                        Text("\(progress.progress)/\(def.maxProgress)")
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appOrange))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)
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
                Image(systemName: def.isReversible ? "arrow.clockwise.circle" : "checkmark.circle.fill")
                    .foregroundColor(def.isReversible ? Color(UIColor.appOrange) : Color(red: 0.18, green: 0.65, blue: 0.37))
                    .font(.system(size: 18))
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

    private func handleCta() {
        if !isObtained {
            showUnlocked = true
        }
        // When obtained: CTA navigates somewhere — TODO when backend ready
    }
}
