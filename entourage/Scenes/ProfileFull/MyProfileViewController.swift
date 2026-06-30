import SwiftUI

// MARK: - Hosting Controller

final class MyProfileHostingController: UIHostingController<MyProfileView> {
    private let viewModel: MyProfileViewModel

    init(rootView: MyProfileView, viewModel: MyProfileViewModel) {
        self.viewModel = viewModel
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadData()
    }
}

// MARK: - Navigation Protocol

protocol MyProfileNavigationDelegate: AnyObject {
    func showImagePicker()
    func showProfileEditor(user: User?)
    func showPartnerDetails(partner: Partner)
    func openEnhancedOnboarding(mode: EnhancedOnboardingMode)
    func showLanguageSelector()
    func showNotificationSettings()
    func showHelp()
    func showBlockedContacts()
    func openFeedbackUrl()
    func shareApp()
    func showPasswordChange()
    func showLogoutAlert()
    func showDeleteAccountAlert()
}

// MARK: - ViewModel

class MyProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var activatedNotif: [String] = []
    @Published var numberOfBlocked: Int = 0
    @Published var apiBadges: [UserBadgeAPI] = []

    weak var navigationDelegate: MyProfileNavigationDelegate?

    func loadData() {
        guard let currentUser = UserDefaults.currentUser else { return }
        self.user = currentUser

        HomeService.getNotifsPermissions { [weak self] notifPerms, error in
            guard let self = self else { return }
            if let notifPerms = notifPerms {
                var activeNotifs: [String] = []
                if notifPerms.chat_message { activeNotifs.append("message") }
                if notifPerms.neighborhood { activeNotifs.append("groupe") }
                if notifPerms.outing { activeNotifs.append("événement") }
                if notifPerms.action { activeNotifs.append("action") }
                DispatchQueue.main.async {
                    self.activatedNotif = activeNotifs
                }
            }
        }

        MessagingService.getUsersBlocked { [weak self] blockedUsers, error in
            DispatchQueue.main.async {
                self?.numberOfBlocked = blockedUsers?.count ?? 0
            }
        }

        let userId = currentUser.uuid ?? ""
        if !userId.isEmpty {
            UserService.getDetailsForUser(userId: userId) { [weak self] returnUser, error in
                DispatchQueue.main.async {
                    if let returnUser = returnUser {
                        self?.user = returnUser
                        self?.apiBadges = returnUser.badges ?? []
                        UserDefaults.currentUser = returnUser
                    }
                }
            }
        }
    }

    func modifyImageClick() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        navigationDelegate?.showImagePicker()
    }

    func modifyProfile() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        navigationDelegate?.showProfileEditor(user: self.user)
    }

    func onPartnerClick() {
        guard let partner = self.user?.partner else { return }
        navigationDelegate?.showPartnerDetails(partner: partner)
    }

    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \(version) (\(build))"
    }
}

// MARK: - Main View

struct MyProfileView: View {
    @StateObject var viewModel: MyProfileViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showBadgesList = false
    @State private var selectedBadgeProgress: UserBadgeProgress?
    @State private var showSettings = false

    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Orange header
                ZStack {
                    Image("ic_backgrnd_welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: safeAreaTop + 120)
                        .clipped()
                }
                .overlay(
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.45))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.45))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, safeAreaTop + 8),
                    alignment: .top
                )

                // White rounded card
                VStack(spacing: 0) {
                    Spacer().frame(height: 68)

                    VStack(spacing: 10) {
                        if let displayName = viewModel.user?.displayName, !displayName.isEmpty {
                            Text(displayName)
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        rolePartnerPills

                        VStack(spacing: 8) {
                            if let city = viewModel.user?.addressPrimary?.displayAddress, !city.isEmpty {
                                let radiusString = String(viewModel.user?.radiusDistance ?? 0)
                                Text("\(city) - \(radiusString) km")
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            if let phone = viewModel.user?.phone, !phone.isEmpty {
                                Text(ProfileViewHelpers.formatPhoneNumber(phone))
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            if let email = viewModel.user?.email, !email.isEmpty {
                                Text(email)
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            if let birthdate = viewModel.user?.birthdate, !birthdate.isEmpty {
                                Text(ProfileViewHelpers.formatBirthdate(birthdate))
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            let aboutText = viewModel.user?.about?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if !aboutText.isEmpty {
                                Text(aboutText)
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 20)
                            } else {
                                Text("profile_description_placeholder".localized)
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112).opacity(0.6))
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 10)

                        Button(action: { viewModel.modifyProfile() }) {
                            Text("modify".localized)
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12)))
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 12)
                                .frame(minWidth: 136, minHeight: 48)
                                .background(Color(UIColor.appOrange))
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    .padding()

                    if let user = viewModel.user {
                        MainStatUserView(isMe: true, user: user)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }

                    BadgesSectionView(
                        apiBadges: viewModel.apiBadges,
                        isMe: true,
                        onShowAllBadges: { showBadgesList = true },
                        onBadgeTap: { p in selectedBadgeProgress = p }
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .fullScreenCover(isPresented: $showBadgesList) {
                        BadgesListView()
                    }
                    .sheet(item: $selectedBadgeProgress) { p in
                        BadgeDetailSheet(
                            progress: p,
                            isMe: true,
                            onShowAllBadges: {
                                selectedBadgeProgress = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    showBadgesList = true
                                }
                            },
                            onCta: {
                                if p.isObtained {
                                    selectedBadgeProgress = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        showBadgesList = true
                                    }
                                } else {
                                    BadgesListView.navigateToBadgeCta(key: p.definition.key)
                                }
                            }
                        )
                    }

                    if let user = viewModel.user {
                        MyPreferencesSectionView(user: user, viewModel: viewModel)
                            .padding(.horizontal)
                    }
                }
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 4)
                .padding(.bottom, 32)
                .offset(y: -60)
                .padding(.bottom, -60)
            }
            .overlay(
                HStack {
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        ProfileImageView(
                            urlString: viewModel.user?.avatarURL,
                            size: CGSize(width: 120, height: 120)
                        )
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        Button(action: { viewModel.modifyImageClick() }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        .frame(width: 32, height: 32)
                    }
                    .frame(width: 120, height: 120)
                    Spacer()
                }
                .padding(.top, safeAreaTop),
                alignment: .top
            )
        }
        .edgesIgnoringSafeArea(.top)
        .id(viewModel.user?.uuid ?? "my-profile")
        .onAppear { viewModel.loadData() }
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var rolePartnerPills: some View {
        let roles = viewModel.user?.roles ?? []
        let partnerText = viewModel.user?.partner?.name ?? viewModel.user?.organization?.name ?? ""

        if !roles.isEmpty && !partnerText.isEmpty {
            HStack(spacing: 4) {
                Text(roles.joined(separator: " • "))
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                    .foregroundColor(Color(UIColor.appOrange))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appBeige)
                    .cornerRadius(11)
                    .fixedSize(horizontal: true, vertical: false)
                HStack(spacing: 4) {
                    if let logoUrl = viewModel.user?.partner?.smallLogoUrl {
                        PartnerLogoView(urlString: logoUrl).frame(width: 30, height: 30)
                    }
                    Text(partnerText)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appOrange))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.appBeige)
                .cornerRadius(11)
                .fixedSize(horizontal: true, vertical: false)
                .onTapGesture { viewModel.onPartnerClick() }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else if !roles.isEmpty {
            Text(roles.joined(separator: " • "))
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                .foregroundColor(Color(UIColor.appOrange))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.appBeige)
                .cornerRadius(11)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: true, vertical: false)
        } else if !partnerText.isEmpty {
            HStack(spacing: 4) {
                if let logoUrl = viewModel.user?.partner?.smallLogoUrl {
                    PartnerLogoView(urlString: logoUrl).frame(width: 30, height: 30)
                }
                Text(partnerText)
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                    .foregroundColor(Color(UIColor.appOrange))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.appBeige)
            .cornerRadius(11)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: true, vertical: false)
            .onTapGesture { viewModel.onPartnerClick() }
        }
    }
}

// MARK: - Preferences Section

struct MyPreferencesSectionView: View {
    let user: User
    @ObservedObject var viewModel: MyProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("preferences_section_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            Button(action: { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .interest) }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_interest",
                    title: "preferences_interest_title".localized,
                    subtitle: formatInterests(user.interests),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            let involvements = (user.partner != nil) ? (user.orientations ?? []) : (user.involvements ?? [])
            Button(action: { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .involvement) }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_action",
                    title: "preferences_action_title".localized,
                    subtitle: formatInvolvements(involvements, isAssociation: user.partner != nil),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            if user.partner == nil {
                Button(action: { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .concern) }) {
                    ProfileStandardRow(
                        imageName: "ic_profil_full_action_category",
                        title: "preferences_action_categories_title".localized,
                        subtitle: formatConcerns(user.concerns),
                        isMe: true
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .choiceDisponibility) }) {
                    ProfileStandardRow(
                        imageName: "ic_profil_full_disponibility",
                        title: "preferences_availability_title".localized,
                        subtitle: formatAvailability(user.availability),
                        isMe: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    private func formatInterests(_ interests: [String]?) -> String {
        guard let interests = interests, !interests.isEmpty else { return "no_data_available".localized }
        return interests.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
    }

    private func formatInvolvements(_ involvements: [String], isAssociation: Bool) -> String {
        guard !involvements.isEmpty else { return "no_data_available".localized }
        return involvements.map { isAssociation ? TagsUtils.showOrientationTranslated($0) : TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
    }

    private func formatConcerns(_ concerns: [String]?) -> String {
        guard let concerns = concerns, !concerns.isEmpty else { return "no_data_available".localized }
        return concerns.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
    }

    private func formatAvailability(_ availability: [String: [String]]?) -> String {
        guard let availability = availability, !availability.isEmpty else { return "no_data_available".localized }
        return availability.map { dayKey, slots in
            "\(dayName(for: dayKey)) (\(slots.map { timeSlotName(for: $0) }.joined(separator: ", ")))"
        }.joined(separator: " • ")
    }

    private func dayName(for dayKey: String) -> String {
        switch dayKey {
        case "1": return "enhanced_onboarding_time_disponibility_day_monday".localized
        case "2": return "enhanced_onboarding_time_disponibility_day_tuesday".localized
        case "3": return "enhanced_onboarding_time_disponibility_day_wednesday".localized
        case "4": return "enhanced_onboarding_time_disponibility_day_thursday".localized
        case "5": return "enhanced_onboarding_time_disponibility_day_friday".localized
        case "6": return "enhanced_onboarding_time_disponibility_day_saturday".localized
        case "7": return "enhanced_onboarding_time_disponibility_day_sunday".localized
        default: return dayKey
        }
    }

    private func timeSlotName(for slot: String) -> String {
        switch slot {
        case "09:00-12:00": return "enhanced_onboarding_time_disponibility_time_morning".localized
        case "14:00-18:00": return "enhanced_onboarding_time_disponibility_time_afternoon".localized
        case "18:00-21:00": return "enhanced_onboarding_time_disponibility_time_evening".localized
        default: return slot
        }
    }
}
