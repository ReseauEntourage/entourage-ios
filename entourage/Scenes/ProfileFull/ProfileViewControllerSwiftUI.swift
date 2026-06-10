import SwiftUI
import SDWebImage

// MARK: - Navigation Protocol
protocol ProfileNavigationDelegate: AnyObject {
    func dismiss()
    func showImagePicker()
    func showProfileEditor(user: User?)
    func showPartnerDetails(partner: Partner)
    func showConversation(conversation: Conversation?)
    func showReportUser(user: User?)
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

// MARK: - Views Components

struct ProfileImageView: UIViewRepresentable {
    let urlString: String?
    let size: CGSize

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let urlString = urlString, let url = URL(string: urlString) {
            uiView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            uiView.image = UIImage(named: "placeholder_user")
        }
    }
}

struct PartnerLogoView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let url = URL(string: urlString) {
            uiView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
}

// MARK: - Main View

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                let offsetY = geometry.frame(in: .global).minY
                let imageSize = max(120 + offsetY, 60)
                let scale = imageSize / 120
                let modifyButtonSize = max(30 * scale, 0)

                VStack(spacing: 0) {
                    // Header with profile image and back button
                    ZStack {
                        Color(UIColor.appOrange)
                            .frame(height: 200)

                        LinearGradient(
                            gradient: Gradient(colors: [Color(UIColor.appOrange).opacity(0.8), Color(UIColor.appOrange)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    }
                    .overlay(
                        ZStack(alignment: .top) {
                            // Profile Image and Modify Button
                            HStack {
                                Spacer()
                                ZStack(alignment: .bottomTrailing) {
                                    ProfileImageView(
                                        urlString: viewModel.user?.avatarURL,
                                        size: CGSize(width: imageSize, height: imageSize)
                                    )
                                    .scaleEffect(scale)
                                    .opacity(scale > 0.5 ? 1 : 0)

                                    if viewModel.isMe {
                                        Button(action: {
                                            viewModel.modifyImageClick()
                                        }) {
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.orange)
                                                .clipShape(Circle())
                                        }
                                        .frame(width: modifyButtonSize, height: modifyButtonSize)
                                        .opacity(modifyButtonSize > 20 ? 1 : 0)
                                    }
                                }
                                .frame(width: 120, height: 120)
                                Spacer()
                            }
                            .offset(y: min(offsetY, 0))

                            // Back Button & Signal Button
                            HStack {
                                Button(action: {
                                    viewModel.handleBackButtonTap()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }

                                Spacer()

                                if !viewModel.isMe {
                                    Button(action: {
                                        viewModel.onSignalUserClick()
                                    }) {
                                        Image("ic_signal")
                                            .renderingMode(.template)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 40)
                        }
                    )

                    // User info section
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            if let displayName = viewModel.user?.displayName, !displayName.isEmpty {
                                Text(displayName)
                                    .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)))
                                    .foregroundColor(.black)
                            }

                            if let roles = viewModel.user?.roles, !roles.isEmpty {
                                Text(roles.joined(separator: " • "))
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                    .foregroundColor(.black)
                            }

                            if let city = viewModel.user?.addressPrimary?.displayAddress, !city.isEmpty {
                                Text(city)
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                    .foregroundColor(Color(.gray))
                            }
                        }

                        // Description
                        if let aboutText = viewModel.user?.about, !aboutText.isEmpty {
                            Text(aboutText)
                                .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Partner and roles
                        if let partnerText = viewModel.user?.partner?.name ?? viewModel.user?.organization?.name, !partnerText.isEmpty {
                            Button(action: { viewModel.onPartnerClick() }) {
                                HStack {
                                    if let partnerLogoUrl = viewModel.user?.partner?.smallLogoUrl {
                                        PartnerLogoView(urlString: partnerLogoUrl)
                                            .frame(width: 30, height: 30)
                                    }
                                    Text(partnerText)
                                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        // Modify or Send Message button
                        Button(action: {
                            if viewModel.isMe {
                                viewModel.modifyProfile()
                            } else {
                                viewModel.sendMessage()
                            }
                        }) {
                            Text(viewModel.isMe ? "modify".localized : "detail_user_send_message".localized)
                                .font(Font(UIFont(name: "Quicksand-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14)))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.appOrange))
                                .cornerRadius(25)
                        }
                    }
                    .padding()

                    // Main user activity
                    if let user = viewModel.user {
                        MainStatUserView(isMe: viewModel.isMe, user: user)
                            .padding(.horizontal)
                    }

                    // User infos section
                    if let user = viewModel.user {
                        let hasInfo = !(user.birthdate?.isNullOrEmpty() ?? true) ||
                                    !(user.phone?.isNullOrEmpty() ?? true) ||
                                    !(user.email?.isNullOrEmpty() ?? true) ||
                                    !(user.addressPrimary?.displayAddress?.isNullOrEmpty() ?? true)
                        if hasInfo {
                            UserInfosSectionView(user: user)
                                .padding(.horizontal)
                        }
                    }

                    // Interests section
                    if let interests = viewModel.user?.interests, !interests.isEmpty {
                        InterestsSectionView(interests: interests)
                            .padding(.horizontal)
                    }

                    // Preferences section
                    if let user = viewModel.user {
                        PreferencesSectionView(
                            isMe: viewModel.isMe,
                            user: user,
                            activatedNotif: viewModel.activatedNotif,
                            numberOfBlocked: viewModel.numberOfBlocked,
                            viewModel: viewModel
                        )
                        .padding(.horizontal)
                    }

                    // Settings section (only for current user)
                    if viewModel.isMe {
                        SettingsSectionView(
                            activatedNotif: viewModel.activatedNotif,
                            numberOfBlocked: viewModel.numberOfBlocked,
                            viewModel: viewModel
                        )
                        .padding(.horizontal)

                        // App version
                        Text(viewModel.getAppVersion())
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Subviews

struct InterestsSectionView: View {
    let interests: [String]

    var body: some View {
        VStack(spacing: 0) {
            Text("detail_user_his_interests".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            InterestTagsView(interests: interests)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.vertical, 8)
    }
}

struct UserInfosSectionView: View {
    let user: User

    func formatRadiusText() -> Text {
        let currentRadius = user.radiusDistance ?? 0
        let str = String(format: "mainUserCityRadius".localized, currentRadius)
        let radiusStr = String(currentRadius)

        if let range = str.range(of: radiusStr) {
            let before = str[str.startIndex..<range.lowerBound]
            let after = str[range.upperBound...]

            return Text(before) +
                Text(radiusStr)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                    .foregroundColor(Color(UIColor.appOrange)) +
                Text(after)
        }
        return Text(str)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("mainUserTitleInfos".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let birthdate = user.birthdate, !birthdate.isEmpty {
                InfoRow(title: "mainUserTitleBirth".localized, value: birthdate)
            }

            if let phone = user.phone, !phone.isEmpty {
                InfoRow(title: "mainUserTitlePhone".localized, value: phone)
            }

            if let email = user.email, !email.isEmpty {
                InfoRow(title: "mainUserTitleEmail".localized, value: email)
            }

            if let city = user.addressPrimary?.displayAddress, !city.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("mainUserTitleCity".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appOrange))

                    Text(city)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                        .foregroundColor(.black)
                }

                formatRadiusText()
                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.vertical, 8)
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                .foregroundColor(Color(UIColor.appOrange))

            Text(value)
                .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                .foregroundColor(.black)
        }
    }
}

struct InterestTagsView: View {
    let interests: [String]

    var body: some View {
        WrappingHStack(alignment: .center, spacing: 8) {
            ForEach(interests, id: \.self) { interest in
                InterestTagView(text: Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) ?? interest)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct InterestTagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)))
            .foregroundColor(Color(UIColor.appOrange))
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(Color(UIColor.appOrangeLight_50))
            .cornerRadius(15)
    }
}

struct WrappingHStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content

    init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        _VariadicView.Tree(Layout()) {
            content()
        }
    }

    private struct Layout: _VariadicView_MultiViewRoot {
        func body(children: _VariadicView.Children) -> some View {
            let views = children.map { AnyView($0) }
            return WrappingHStackLayout(views: views, alignment: .center, spacing: 8)
        }
    }
}

struct WrappingHStackLayout: View {
    let views: [AnyView]
    let alignment: HorizontalAlignment
    let spacing: CGFloat

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(0..<self.views.count, id: \.self) { i in
                self.views[i]
                    .padding(.trailing, self.spacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) < 1) { return 0 }
                        return d[.leading]
                    })
                    .alignmentGuide(.trailing, computeValue: { d in
                        let result = width
                        width += d.width + self.spacing
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if abs(width - d.width) < 1 {
                            width = 0
                            height += d.height + self.spacing
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct MainStatUserView: View {
    let isMe: Bool
    let user: User

    func formatCreationDate(_ date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/yyyy"
        return dateFormat.string(from: date)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isMe ? "mainUserTitleActivity".localized : "detail_user_his_activity".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                .foregroundColor(.black)

            HStack(spacing: 32) {
                VStack {
                    let count = user.stats?.neighborhoodsCount ?? 0
                    Text("\\(count)")
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                        .foregroundColor(count == 0 ? .gray : .black)

                    Text(count <= 1 ? "mainUserTitleGroup".localized : "mainUserTitleGroups".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(.black)
                }

                VStack {
                    let count = user.stats?.outingsCount ?? -1
                    let displayCount = count < 0 ? 0 : count
                    Text("\\(displayCount)")
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                        .foregroundColor(displayCount == 0 ? .gray : .black)

                    Text(displayCount <= 1 ? "mainUserTitleOuting".localized : "mainUserTitleOutings".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(.black)
                }
            }

            if let myDate = user.creationDate {
                HStack {
                    Text("mainUserTitleMember".localized)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                        .foregroundColor(.black)

                    let dateString = self.formatCreationDate(myDate)
                    Text(dateString)
                        .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(UIColor.appOrangeLight).opacity(0.25), radius: 4, x: 1, y: 1)
    }
}

struct PreferencesSectionView: View {
    let isMe: Bool
    let user: User
    let activatedNotif: [String]
    let numberOfBlocked: Int
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(isMe ? "preferences_section_title".localized : "preferences_section_title_others".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            Button(action: {
                if isMe { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .interest) }
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_interest",
                    title: isMe ? "preferences_interest_title".localized : "preferences_interest_title_others".localized,
                    subtitle: formatInterests(user.interests),
                    isMe: isMe
                )
            }
            .buttonStyle(PlainButtonStyle())

            let involvements = (user.partner != nil) ? (user.orientations ?? []) : (user.involvements ?? [])
            Button(action: {
                if isMe { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .involvement) }
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_action",
                    title: isMe ? "preferences_action_title".localized : "preferences_action_title_others".localized,
                    subtitle: formatInvolvements(involvements, isAssociation: user.partner != nil),
                    isMe: isMe
                )
            }
            .buttonStyle(PlainButtonStyle())

            if user.partner == nil {
                Button(action: {
                    if isMe { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .concern) }
                }) {
                    ProfileStandardRow(
                        imageName: "ic_profil_full_action_category",
                        title: isMe ? "preferences_action_categories_title".localized : "preferences_action_categories_title_others".localized,
                        subtitle: formatConcerns(user.concerns),
                        isMe: isMe
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    if isMe { viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .choiceDisponibility) }
                }) {
                    ProfileStandardRow(
                        imageName: "ic_profil_full_disponibility",
                        title: isMe ? "preferences_availability_title".localized : "preferences_availability_title_others".localized,
                        subtitle: formatAvailability(user.availability),
                        isMe: isMe
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
        var availabilityParts: [String] = []
        for (dayKey, slots) in availability {
            let dayLabel = dayName(for: dayKey)
            let slotLabels = slots.map { timeSlotName(for: $0) }.joined(separator: ", ")
            availabilityParts.append("\\(dayLabel) (\\(slotLabels))")
        }
        return availabilityParts.joined(separator: " • ")
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

struct SettingsSectionView: View {
    let activatedNotif: [String]
    let numberOfBlocked: Int
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("settings_section_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            Button(action: { viewModel.navigationDelegate?.showLanguageSelector() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_language",
                    title: "settings_language_title".localized,
                    subtitle: formatLanguage(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showNotificationSettings() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_notif",
                    title: "settings_notifications_title".localized,
                    subtitle: formatNotifications(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showBlockedContacts() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_block_people",
                    title: "settings_unblock_contacts_title".localized,
                    subtitle: formatBlockedUsers(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.openFeedbackUrl() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_suggest",
                    title: "settings_feedback_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.shareApp() }) {
                ProfileStandardRow(
                    imageName: "ic_profile_full_share",
                    title: "settings_share_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showHelp() }) {
                ProfileStandardRow(
                    imageName: "ic_profile_help",
                    title: "settings_help_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showPasswordChange() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_mdp",
                    title: "settings_password_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showLogoutAlert() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_log_out",
                    title: "logout_button".localized,
                    subtitle: "",
                    isMe: true,
                    isDestructive: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { viewModel.navigationDelegate?.showDeleteAccountAlert() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_suppress_account",
                    title: "delete_account_button".localized,
                    subtitle: "",
                    isMe: true,
                    isDestructive: true
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    private func formatLanguage() -> String {
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        let localizedKey = getLocalizedKey(for: preferredLanguage)
        return String(localizedKey.dropFirst(3))
    }

    private func getLocalizedKey(for lang: String) -> String {
        let languageMapping: [String: String] = [
            "fr": "lang_fr",
            "en": "lang_en",
            "es": "lang_es",
            "ar": "lang_ar",
            "uk": "lang_uk",
            "de": "lang_de",
            "ro": "lang_ro",
            "pl": "lang_pl"
        ]
        return languageMapping[lang]?.localized ?? "lang_fr".localized
    }

    private func formatNotifications() -> String {
        if activatedNotif.isEmpty {
            return "settings_notifications_subtitle_none".localized
        } else {
            return String(format: "settings_notifications_subtitle".localized, activatedNotif.joined(separator: ", "))
        }
    }

    private func formatBlockedUsers() -> String {
        if numberOfBlocked == 0 {
            return "settings_unblock_contacts_subtitle_none".localized
        } else {
            return String.localizedStringWithFormat(
                numberOfBlocked == 1 ? "settings_unblock_contacts_subtitle".localized : "settings_unblock_contacts_subtitle_plural".localized,
                numberOfBlocked
            )
        }
    }
}

struct ProfileStandardRow: View {
    let imageName: String
    let title: String
    let subtitle: String
    let isMe: Bool
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                    .foregroundColor(isDestructive ? .orange : .black)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                }
            }

            Spacer()

            if isMe {
                Image(systemName: "chevron.right")
                    .foregroundColor(isDestructive ? Color(UIColor.appOrange) : .black)
            }
        }
        .padding()
        .background(Color.white)
        .contentShape(Rectangle())
    }
}

// MARK: - Extension String
extension String {
    func isNullOrEmpty() -> Bool {
        return self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - ViewModel
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isMe: Bool = true
    @Published var activatedNotif: [String] = []
    @Published var numberOfBlocked: Int = 0
    @Published var userIdToDisplay: String?

    weak var navigationDelegate: ProfileNavigationDelegate?

    func handleBackButtonTap() {
        navigationDelegate?.dismiss()
    }

    func loadData() {
        guard let currentUser = UserDefaults.currentUser else { return }

        self.user = currentUser
        self.isMe = userIdToDisplay == nil

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

        let userIdToLoad = userIdToDisplay ?? currentUser.uuid ?? ""
        if !userIdToLoad.isEmpty {
            UserService.getDetailsForUser(userId: userIdToLoad) { [weak self] returnUser, error in
                DispatchQueue.main.async {
                    if let returnUser = returnUser {
                        self?.user = returnUser
                        if self?.isMe == true {
                            UserDefaults.currentUser = returnUser
                        }
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

    func onSignalUserClick() {
        navigationDelegate?.showReportUser(user: self.user)
    }

    func onPartnerClick() {
        guard let currentPartner = self.user?.partner else { return }
        navigationDelegate?.showPartnerDetails(partner: currentPartner)
    }

    func sendMessage() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        guard let currentUserId = user?.sid.description else { return }
        MessagingService.createOrGetConversation(userId: currentUserId) { [weak self] conversation, error in
            if let conversation = conversation {
                self?.navigationDelegate?.showConversation(conversation: conversation)
                return
            }
            let _ = error?.message ?? "message_error_create_conversation".localized
        }
    }

    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \\(version) (\\(build))"
    }
}
