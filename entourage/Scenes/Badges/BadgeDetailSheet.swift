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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Emoji + title header
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
                    .padding(.vertical, 16)
                    .background(Color(UIColor.appOrangeLight).opacity(0.15))

                    // Status card
                    statusCard
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)

                    Divider()

                    // How it works
                    badgeSection(
                        title: "badge_how_it_works_title".localized,
                        body: def.howItWorksKey.localized,
                        background: Color(UIColor.appOrangeLight).opacity(0.15)
                    )

                    // Mechanism
                    mechanismSection

                    // What it means
                    badgeSection(
                        title: "badge_what_it_means_title".localized,
                        body: def.whatItMeansKey.localized,
                        background: Color.white
                    )

                    Spacer().frame(height: 16)

                    // CTA button
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
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

    @ViewBuilder
    private var statusCard: some View {
        if isObtained {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                        .font(.system(size: 13, weight: .bold))
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
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(red: 0.88, green: 0.96, blue: 0.91))
            .cornerRadius(12)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("badge_not_obtained".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(.black)

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
            .background(Color(UIColor.appOrangeLight).opacity(0.2))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private var mechanismSection: some View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(red: 0.88, green: 0.96, blue: 0.91).opacity(def.isReversible ? 0 : 1).blendMode(.normal))
        .background(def.isReversible ? Color(UIColor.appOrangeLight).opacity(0.1) : Color(red: 0.88, green: 0.96, blue: 0.91))
    }

    private func badgeSection(title: String, body: String, background: Color) -> some View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(background)
    }

    private func handleCta() {
        if !isObtained {
            showUnlocked = true
        }
        // When obtained: CTA navigates somewhere — TODO when backend ready
    }
}
