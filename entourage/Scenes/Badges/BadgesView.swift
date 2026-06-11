import SwiftUI

struct BadgesView: View {
    @StateObject private var viewModel = BadgesViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.leading, 16)

                Spacer()

                Text("badges_title".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)))
                    .foregroundColor(.black)

                Spacer()

                // Placeholder to balance the chevron
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .padding(.trailing, 16)
            }
            .frame(height: 50)
            .background(Color.white)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if viewModel.hasAnyProgression {
                            filledHeaderView
                        } else {
                            emptyHeaderView
                        }

                        if viewModel.hasAnyProgression {
                            if !viewModel.obtainedBadges.isEmpty {
                                badgeSection(title: "badges_section_obtained".localized, count: viewModel.obtainedBadges.count, total: 5, badges: viewModel.obtainedBadges, type: .obtained)
                            }
                            if !viewModel.inProgressBadges.isEmpty {
                                badgeSection(title: "badges_section_in_progress".localized, count: viewModel.inProgressBadges.count, total: 5, badges: viewModel.inProgressBadges, type: .inProgress)
                            }
                            if !viewModel.notStartedBadges.isEmpty {
                                badgeSection(title: "badges_section_not_started".localized, count: viewModel.notStartedBadges.count, total: 5, badges: viewModel.notStartedBadges, type: .notStarted)
                            }
                        } else {
                            badgeSection(title: "badges_section_all".localized, count: 0, total: 5, badges: viewModel.badges, type: .notStarted)
                        }

                        // Footer Link
                        Button(action: {
                            // Link to help if needed
                        }) {
                            Text("badges_how_it_works".localized)
                                .font(Font(UIFont(name: "NunitoSans-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)))
                                .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.17)) // Entourage orange
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 16)
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                .background(Color(red: 0.98, green: 0.98, blue: 0.98)) // light gray background
            }
        }
        .onAppear {
            viewModel.fetchBadges()
        }
    }

    // MARK: - Header Views

    var emptyHeaderView: some View {
        VStack(spacing: 24) {
            // Emjois at top
            HStack(spacing: 16) {
                Text("👣").font(.system(size: 24))
                Text("🤝").font(.system(size: 24))
                Text("💫").font(.system(size: 32)) // bigger center
                Text("💬").font(.system(size: 24))
                Text("🌱").font(.system(size: 24))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)

            VStack(spacing: 8) {
                Text("badges_subtitle".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // dark gray

                Text("badges_empty_desc".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .multilineTextAlignment(.center)
            }

            // Orange Box
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .overlay(Text("👣").font(.system(size: 24)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("badges_start_with".localized)
                            .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .bold)))
                            .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.17))

                        Text("badges_start_with_name".localized)
                            .font(Font(UIFont(name: "NunitoSans-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)))
                            .foregroundColor(.black)
                    }
                }

                Text("badge_premier_contact_desc".localized)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))

                Button(action: {
                    // Do nothing for now
                }) {
                    Text("badges_start_with_button".localized)
                        .font(Font(UIFont(name: "NunitoSans-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.94, green: 0.44, blue: 0.17))
                        .cornerRadius(24)
                }
            }
            .padding(16)
            .background(Color.appBeige)
            .cornerRadius(16)
        }
        .padding(.bottom, 8)
    }

    var filledHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("badges_subtitle".localized)
                .font(Font(UIFont(name: "NunitoSans-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // dark gray

            Text(String(format: "badges_filled_desc".localized, viewModel.obtainedBadges.count, viewModel.inProgressBadges.count, viewModel.notStartedBadges.count))
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
    }

    // MARK: - Badge Sections

    enum BadgeSectionType {
        case obtained, inProgress, notStarted
    }

    func badgeSection(title: String, count: Int, total: Int, badges: [Badge], type: BadgeSectionType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(title)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)))
                    .foregroundColor(.black)
                Text("\(count)/\(total)")
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }

            VStack(spacing: 12) {
                ForEach(badges, id: \.name) { badge in
                    badgeCard(for: badge, type: type)
                }
            }
        }
    }

    func badgeCard(for badge: Badge, type: BadgeSectionType) -> some View {
        let isNotStarted = (type == .notStarted)

        return HStack(alignment: .top, spacing: 16) {
            // Icon
            Circle()
                .fill(isNotStarted ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.appBeige)
                .frame(width: 48, height: 48)
                .overlay(Text(getEmoji(for: badge.name)).font(.system(size: 24)).grayscale(isNotStarted ? 0.99 : 0.0).opacity(isNotStarted ? 0.5 : 1.0))

            VStack(alignment: .leading, spacing: 4) {
                Text("badge_\(badge.name)_name".localized)
                    .font(Font(UIFont(name: "NunitoSans-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)))
                    .foregroundColor(isNotStarted ? Color(red: 0.4, green: 0.4, blue: 0.4) : .black)

                if type == .obtained {
                    Text(String(format: "badges_obtained_date".localized, badge.date ?? ""))
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                } else if type == .notStarted {
                    Text("badge_\(badge.name)_desc".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                } else {
                    // in progress short desc
                    Text("badge_\(badge.name)_desc_short".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }

                // Progress bar
                if type == .obtained || type == .inProgress {
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                    .frame(height: 6)

                                let progress = type == .obtained ? 1.0 : min(1.0, Double(badge.progression ?? 0) / getMaxProgression(for: badge.name))

                                Capsule().fill(type == .obtained ? Color(red: 0.16, green: 0.5, blue: 0.3) : Color(red: 0.94, green: 0.44, blue: 0.17))
                                    .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                            }
                        }
                        .frame(height: 6)
                        .padding(.top, 8)

                        if type == .obtained {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 0.16, green: 0.5, blue: 0.3))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.top, 8)
                        } else {
                            Text("\(badge.progression ?? 0)/\(Int(getMaxProgression(for: badge.name)))")
                                .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .bold)))
                                .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.17))
                                .padding(.top, 8)
                        }
                    }
                }

                // For not started, show 0/X logic inside if needed? Actually in mockups it's on the right bottom
                if type == .notStarted && viewModel.hasAnyProgression {
                    HStack {
                        Spacer()
                        Text("0/\(Int(getMaxProgression(for: badge.name)))")
                            .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .bold)))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    }
                } else if type == .notStarted && !viewModel.hasAnyProgression {
                   HStack {
                       Spacer()
                       Text("0/\(Int(getMaxProgression(for: badge.name)))")
                           .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .bold)))
                           .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                   }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isNotStarted ? Color(red: 0.95, green: 0.95, blue: 0.95) : (type == .inProgress ? Color.appBeige : Color(red: 0.9, green: 0.9, blue: 0.9)), lineWidth: 1)
        )
    }

    func getEmoji(for name: String) -> String {
        switch name {
        case "premier_contact": return "👣"
        case "bienvenue": return "🤝"
        case "moteur_rencontres": return "💫"
        case "fidele_papotages": return "💬"
        case "voix_presente": return "🌱"
        default: return "✨"
        }
    }

    func getMaxProgression(for name: String) -> Double {
        switch name {
        case "premier_contact": return 1
        case "bienvenue": return 1
        case "moteur_rencontres": return 3
        case "fidele_papotages": return 3
        case "voix_presente": return 3
        default: return 1
        }
    }
}
