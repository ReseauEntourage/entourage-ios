import SwiftUI

struct BadgesListView: View {
    let obtainedKeys: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedProgress: UserBadgeProgress?
    @State private var showDetail = false

    private var allProgress: [UserBadgeProgress] { buildBadgeProgress(obtainedKeys: obtainedKeys) }
    private var obtained: [UserBadgeProgress] { allProgress.filter { $0.isObtained } }
    private var inProgress: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress > 0 } }
    private var notStarted: [UserBadgeProgress] { allProgress.filter { !$0.isObtained && $0.progress == 0 } }
    private var isEmpty: Bool { obtained.isEmpty && inProgress.isEmpty }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if isEmpty {
                        emptyHeader
                    } else {
                        fullHeader
                    }

                    if isEmpty {
                        badgeSection(title: nil, items: allProgress)
                    } else {
                        if !obtained.isEmpty {
                            badgeSection(
                                title: String(format: "badges_section_obtained".localized, obtained.count, allBadgeDefinitions.count),
                                items: obtained
                            )
                        }
                        if !inProgress.isEmpty {
                            badgeSection(
                                title: String(format: "badges_section_in_progress".localized, inProgress.count, allBadgeDefinitions.count),
                                items: inProgress
                            )
                        }
                        if !notStarted.isEmpty {
                            badgeSection(
                                title: String(format: "badges_section_not_started".localized, notStarted.count, allBadgeDefinitions.count),
                                items: notStarted
                            )
                        }
                    }

                    Button(action: {}) {
                        Text("badges_faq_link".localized)
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                            .foregroundColor(Color(UIColor.appOrange))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("badges_list_title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .sheet(isPresented: $showDetail) {
            if let p = selectedProgress {
                BadgeDetailSheet(
                    progress: p,
                    obtainedKeys: obtainedKeys,
                    onShowAllBadges: {}
                )
            }
        }
    }

    private var emptyHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("badges_list_main_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? .systemFont(ofSize: 20)))
                .foregroundColor(.black)

            Text(String(format: "badges_list_subtitle".localized, 0, 0, allBadgeDefinitions.count))
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                .foregroundColor(Color(UIColor.appGris112))

            VStack(alignment: .leading, spacing: 8) {
                Text("badges_empty_start_label".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                    .foregroundColor(Color(UIColor.appGris112))

                if let firstDef = allBadgeDefinitions.first {
                    Text("\(firstDef.emoji) \(firstDef.titleKey.localized)")
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                        .foregroundColor(.black)
                }

                Text(allBadgeDefinitions.map { $0.emoji }.joined(separator: "  "))
                    .font(.system(size: 22))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }

    private var fullHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("badges_list_main_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? .systemFont(ofSize: 20)))
                .foregroundColor(.black)

            Text(String(format: "badges_list_subtitle".localized, obtained.count, inProgress.count, allBadgeDefinitions.count - obtained.count - inProgress.count))
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? .systemFont(ofSize: 14)))
                .foregroundColor(Color(UIColor.appGris112))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func badgeSection(title: String?, items: [UserBadgeProgress]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title {
                Text(title)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
            ForEach(items, id: \.definition.key.rawValue) { item in
                BadgeListRowView(progress: item)
                    .onTapGesture {
                        selectedProgress = item
                        showDetail = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }
        }
    }
}

private struct BadgeListRowView: View {
    let progress: UserBadgeProgress

    private var def: BadgeDefinition { progress.definition }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(progress.isObtained ? Color(UIColor.appOrangeLight).opacity(0.4) : Color(UIColor.systemGray5))
                    .frame(width: 52, height: 52)
                Text(def.emoji)
                    .font(.system(size: 28))
                    .opacity(progress.isObtained || progress.progress > 0 ? 1.0 : 0.45)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(def.titleKey.localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? .systemFont(ofSize: 15)))
                    .foregroundColor(.black)

                if progress.isObtained {
                    let dateText = progress.obtainedDate ?? ""
                    if dateText.isEmpty {
                        Text("badge_obtained".localized)
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appGris112))
                    } else {
                        Text(String(format: "badge_obtained_on".localized, dateText))
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appGris112))
                    }
                } else {
                    Text(def.descriptionShortKey.localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? .systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                        .lineLimit(1)
                }

                progressBar
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(progress.isObtained ? Color(red: 0.18, green: 0.65, blue: 0.37) : Color(UIColor.appOrange))
                    .frame(
                        width: progress.isObtained
                            ? geo.size.width
                            : geo.size.width * CGFloat(progress.progress) / CGFloat(def.maxProgress),
                        height: 6
                    )
            }
        }
        .frame(height: 6)
        .overlay(
            HStack {
                Spacer()
                if progress.isObtained {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.37))
                        .offset(y: 12)
                } else {
                    Text("\(progress.progress)/\(def.maxProgress)")
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 11) ?? .systemFont(ofSize: 11)))
                        .foregroundColor(Color(UIColor.appOrange))
                        .offset(y: 12)
                }
            }
        )
        .padding(.bottom, 14)
    }
}
