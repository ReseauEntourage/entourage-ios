import SwiftUI

struct BadgesListView: View {
    let obtainedKeys: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedProgress: UserBadgeProgress?
    @State private var showDetail = false
    @State private var demoMode = false

    private var effectiveKeys: [String] {
        #if DEBUG
        return demoMode ? [] : obtainedKeys
        #else
        return obtainedKeys
        #endif
    }

    private var allProgress: [UserBadgeProgress] { buildBadgeProgress(obtainedKeys: effectiveKeys) }
    private var obtained: [UserBadgeProgress] { allProgress.filter { $0.isObtained } }
    private var inProgress: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress > 0 } }
    private var notStarted: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress == 0 } }
    private var isEmpty: Bool { obtained.isEmpty && inProgress.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            ZStack {
                Text("badges_list_title".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding(.leading, 20)
                    }
                    Spacer()
                    #if DEBUG
                    Toggle("", isOn: $demoMode)
                        .labelsHidden()
                        .padding(.trailing, 16)
                        .scaleEffect(0.8)
                    #endif
                }
            }
            .frame(height: 44)
            .padding(.top, 30)
            .padding(.bottom, 12)
            .background(Color.white)

            Divider()

            // Content
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if isEmpty {
                        emptyStateHeader
                    } else {
                        fullHeader
                    }

                    if isEmpty {
                        badgeRows(items: allProgress)
                    } else {
                        if !obtained.isEmpty {
                            sectionHeader(String(format: "badges_section_obtained".localized, obtained.count, allBadgeDefinitions.count))
                            badgeRows(items: obtained)
                        }
                        if !inProgress.isEmpty {
                            sectionHeader(String(format: "badges_section_in_progress".localized, inProgress.count, allBadgeDefinitions.count))
                            badgeRows(items: inProgress)
                        }
                        if !notStarted.isEmpty {
                            sectionHeader(String(format: "badges_section_not_started".localized, notStarted.count, allBadgeDefinitions.count))
                            badgeRows(items: notStarted)
                        }
                    }

                    Button(action: {}) {
                        Text("badges_faq_link".localized)
                            .font(Font(UIFont(name: "NunitoSans-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)))
                            .foregroundColor(Color(UIColor.appOrange))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .sheet(isPresented: $showDetail) {
            if let p = selectedProgress {
                BadgeDetailSheet(
                    progress: p,
                    obtainedKeys: effectiveKeys,
                    onShowAllBadges: {}
                )
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(allBadgeDefinitions.map { $0.emoji }.joined(separator: "  "))
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            if let firstDef = allBadgeDefinitions.first {
                Text(String(format: "badges_empty_start_label".localized) + " \(firstDef.titleKey.localized) \(firstDef.emoji)")
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Text(String(format: "badges_all_title".localized, 0, allBadgeDefinitions.count))
                .font(Font(UIFont(name: "NunitoSans-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var fullHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("badges_list_main_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)))
                .foregroundColor(.black)

            Text(String(format: "badges_list_subtitle".localized, obtained.count, inProgress.count, allBadgeDefinitions.count - obtained.count - inProgress.count))
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                .foregroundColor(Color(UIColor.appGris112))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Font(UIFont(name: "NunitoSans-Bold", size: 13) ?? .systemFont(ofSize: 13, weight: .bold)))
            .foregroundColor(Color(UIColor.appGris112))
            .kerning(0.5)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private func badgeRows(items: [UserBadgeProgress]) -> some View {
        ForEach(items, id: \.definition.key.rawValue) { item in
            BadgeListRowView(progress: item)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .onTapGesture {
                    selectedProgress = item
                    showDetail = true
                }
        }
    }
}

// MARK: - Row

struct BadgeListRowView: View {
    let progress: UserBadgeProgress
    private var def: BadgeDefinition { progress.definition }

    private var cardBackground: Color {
        if progress.isObtained || progress.progress > 0 {
            return Color.white
        } else {
            return Color(UIColor.appOrangeLight).opacity(0.15)
        }
    }

    private var emojiCircleBackground: Color {
        if progress.isObtained || progress.progress > 0 {
            return Color(UIColor.appOrangeLight).opacity(0.4)
        } else {
            return Color(UIColor.systemGray5)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Emoji in circle
            ZStack {
                Circle()
                    .fill(emojiCircleBackground)
                    .frame(width: 52, height: 52)
                Text(def.emoji)
                    .font(.system(size: 26))
                    .opacity(progress.isObtained || progress.progress > 0 ? 1.0 : 0.5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(def.titleKey.localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)))
                    .foregroundColor(.black)

                // Subtitle
                if progress.isObtained {
                    let dateText = progress.obtainedDate ?? ""
                    Text(dateText.isEmpty ? "badge_obtained".localized : String(format: "badge_obtained_on".localized, dateText))
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                } else {
                    Text(def.descriptionShortKey.localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                        .foregroundColor(progress.progress > 0 ? Color(UIColor.appGris112) : .black)
                        .lineLimit(1)
                }

                // Progress bar
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
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                            .offset(x: 0, y: 12),
                        alignment: .trailing
                    )
                    .padding(.bottom, 14)
                } else if progress.progress > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.appOrange))
                                .frame(width: geo.size.width * CGFloat(progress.progress) / CGFloat(def.maxProgress), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .overlay(
                        Text("\(progress.progress)/\(def.maxProgress)")
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                            .foregroundColor(Color(UIColor.appOrange))
                            .offset(x: 0, y: 12),
                        alignment: .trailing
                    )
                    .padding(.bottom, 14)
                } else {
                    // Not started — just label
                    HStack {
                        Spacer()
                        Text("0/\(def.maxProgress)")
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)
    }
}
