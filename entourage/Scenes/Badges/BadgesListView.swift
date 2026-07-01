import SwiftUI
import UIKit

struct BadgesListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var apiBadges: [UserBadgeAPI] = []
    @State private var isLoading = true
    @State private var selectedProgress: UserBadgeProgress?
    @State private var showIntro = false
    private let hPad: CGFloat = 20

    private var allProgress: [UserBadgeProgress] { buildBadgeProgress(apiBadges: apiBadges) }
    private var obtained: [UserBadgeProgress] { allProgress.filter { $0.isObtained } }
    private var inProgress: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress > 0 } }
    private var notStarted: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress == 0 } }
    private var isEmptyState: Bool { obtained.isEmpty && inProgress.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if isEmptyState {
                        emptyStateContent
                    } else {
                        fullContent
                    }

                    Button(action: { showIntro = true }) {
                        Text("badges_faq_link".localized)
                            .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)))
                            .foregroundColor(Color(UIColor.appOrange))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .sheet(isPresented: $showIntro) {
                        BadgesIntroView(
                            onDiscover: { showIntro = false },
                            onDismiss: { showIntro = false }
                        )
                    }
                }
                .padding(.top, 16)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear { fetchBadges() }
        .onChange(of: selectedProgress == nil) { isNil in
            if isNil { fetchBadges() }
        }
        .overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                }
            }
        )
        .sheet(item: $selectedProgress) { p in
            BadgeDetailSheet(
                progress: p,
                isMe: true,
                onShowAllBadges: { selectedProgress = nil },
                onCta: {
                    if p.isObtained {
                        selectedProgress = nil
                    } else {
                        BadgesListView.navigateToBadgeCta(key: p.definition.key)
                    }
                }
            )
        }
    }

    // MARK: - Data

    private func fetchBadges() {
        guard let userId = UserDefaults.currentUser?.uuid else {
            isLoading = false
            return
        }
        UserService.getDetailsForUser(userId: userId) { user, _ in
            self.apiBadges = user?.badges ?? []
            self.isLoading = false
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        ZStack {
            Text("badges_list_title".localized)
                .font(Font(UIFont(name: "NunitoSans-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(.leading, hPad)
                }
                Spacer()
            }
        }
        .frame(height: 44)
        .padding(.top, 30)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Empty state (0 badges)

    private var emptyStateContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Carte héro
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(allProgress, id: \.definition.key.rawValue) { p in
                        Image(p.definition.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .opacity(0.5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Text("badges_list_main_title".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("badges_list_intro".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(16)
            .background(Color(UIColor.appOrangeLight).opacity(0.18))
            .cornerRadius(16)
            .padding(.horizontal, hPad)

            // Carte "premier badge" CTA
            if let firstDef = allProgress.first?.definition {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(firstDef.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("badges_empty_start_label".localized.uppercased())
                                .font(Font(UIFont(name: "NunitoSans-Bold", size: 11) ?? .systemFont(ofSize: 11, weight: .bold)))
                                .foregroundColor(Color(UIColor.appOrange))
                                .kerning(0.5)
                            Text(String(format: "badges_empty_badge_title".localized, firstDef.titleKey.localized))
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)))
                                .foregroundColor(.black)
                        }
                    }

                    Text(firstDef.descriptionShortKey.localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                        .foregroundColor(.black.opacity(0.8))

                    Button(action: {
                        BadgesListView.navigateToBadgeCta(key: firstDef.key)
                    }) {
                        Text("badges_empty_cta".localized)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.appOrange))
                            .cornerRadius(30)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.appOrangeLight).opacity(0.18))
                .cornerRadius(16)
                .padding(.horizontal, hPad)
            }

            // En-tête "Tous les badges 0/5"
            Text(String(format: "badges_all_title".localized, 0, allProgress.count))
                .font(Font(UIFont(name: "NunitoSans-Bold", size: 13) ?? .systemFont(ofSize: 13, weight: .bold)))
                .foregroundColor(.black)
                .padding(.horizontal, hPad)
                .padding(.top, 12)
                .padding(.bottom, 6)

            // Tous les badges en mode "non commencé"
            VStack(spacing: 10) {
                ForEach(allProgress, id: \.definition.key.rawValue) { item in
                    BadgeListRowView(progress: item)
                        .onTapGesture { selectedProgress = item }
                }
            }
            .padding(.horizontal, hPad)
        }
    }

    // MARK: - Full content (avec badges)

    private var fullContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !obtained.isEmpty {
                sectionHeader(String(format: "badges_section_obtained".localized, obtained.count, allProgress.count))
                badgeRows(items: obtained)
                    .padding(.bottom, 4)
            }
            if !inProgress.isEmpty {
                sectionHeader(String(format: "badges_section_in_progress".localized, inProgress.count, allProgress.count))
                badgeRows(items: inProgress)
                    .padding(.bottom, 4)
            }
            if !notStarted.isEmpty {
                sectionHeader(String(format: "badges_section_not_started".localized, notStarted.count, allProgress.count))
                badgeRows(items: notStarted)
                    .padding(.bottom, 4)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Font(UIFont(name: "Quicksand-Bold", size: 13) ?? .systemFont(ofSize: 13, weight: .bold)))
            .foregroundColor(.black)
            .padding(.horizontal, hPad)
            .padding(.top, 8)
            .padding(.bottom, 10)
    }

    private func badgeRows(items: [UserBadgeProgress]) -> some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.definition.key.rawValue) { item in
                BadgeListRowView(progress: item)
                    .onTapGesture { selectedProgress = item }
            }
        }
        .padding(.horizontal, hPad)
    }
}

// MARK: - BadgeListRowView

struct BadgeListRowView: View {
    let progress: UserBadgeProgress
    private var def: BadgeDefinition { progress.definition }

    private var isActive: Bool { progress.isObtained || progress.progress > 0 }

    var body: some View {
        HStack(spacing: 12) {
            Image(def.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .opacity(isActive ? 1.0 : 0.4)

            VStack(alignment: .leading, spacing: 4) {
                Text(def.titleKey.localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)))
                    .foregroundColor(.black)

                // Sous-titre
                if progress.isObtained {
                    let rawDate = progress.obtainedDate ?? ""
                    let dateText = rawDate.isEmpty ? "" : formatBadgeDate(rawDate)
                    Text(dateText.isEmpty ? "badge_obtained".localized : String(format: "badge_obtained_on".localized, dateText))
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                } else {
                    Text(def.descriptionShortKey.localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                        .lineLimit(3)
                }

                // Barre de progression
                if progress.isObtained {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.18, green: 0.65, blue: 0.37))
                                .frame(width: geo.size.width, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 2)
                } else if progress.progress > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.appOrange))
                                .frame(width: geo.size.width * CGFloat(progress.progress) / CGFloat(max(progress.target, 1)), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .overlay(
                        Text("\(progress.progress)/\(progress.target)")
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                            .foregroundColor(Color(UIColor.appOrange))
                            .offset(x: 0, y: 12),
                        alignment: .trailing
                    )
                    .padding(.bottom, 14)
                    .padding(.top, 2)
                } else {
                    // Non commencé
                    Text("0/\(progress.target)")
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(isActive ? Color.white : Color(red: 0.937, green: 0.937, blue: 0.957))
        .cornerRadius(12)
    }
}

// MARK: - Tab navigation helper

extension BadgesListView {
    static func navigateToBadgeCta(key: BadgeKey) {
        NotificationCenter.default.post(
            name: NSNotification.Name(kNotificationBadgeCta),
            object: nil,
            userInfo: [kNotificationBadgeCtaKey: key.rawValue]
        )
    }
}
