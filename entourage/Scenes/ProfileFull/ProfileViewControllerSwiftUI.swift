import SwiftUI
import SDWebImage

// MARK: - Color Extensions
extension Color {
    static var appBeige: Color {
        return Color(red: 1, green: 0.91764705882352937, blue: 0.86274509803921573)
    }
}

// MARK: - Navigation Protocol
protocol ProfileNavigationDelegate: AnyObject {
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
        uiView.frame = CGRect(origin: .zero, size: size) // <-- Ajoute cette ligne
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
    @Environment(\.presentationMode) private var presentationMode
    @State private var scrollOffset: CGFloat = 0
    @State private var showBadgesList = false
    @State private var selectedBadgeProgress: UserBadgeProgress?
    @State private var showSettings = false


    var body: some View {
        return ScrollView {
            VStack(spacing: 0) {
                // Header with profile image and back button
                ZStack {
                    // Use the same background image as UIKit version
                    Image("ic_backgrnd_welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 170) // Match UIKit height
                        .clipped()
                }
                .overlay(
                    ZStack(alignment: .top) {
                        // Profile Image and Modify Button
                        VStack {
                            Spacer()
                                .frame(height: 120)
                            ZStack(alignment: .bottomTrailing) {
                                ProfileImageView(
                                    urlString: viewModel.user?.avatarURL,
                                    size: CGSize(width: 120, height: 120)

                                )
                                .frame(width: 120 ,height: 120)
                                .clipped()
                                .cornerRadius(60)
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
                                    .frame(width: 30, height: 30)
                                    .opacity(1.0)
                                }
                            }
                            .frame(width: 80, height: 80)
                        }

                        // Back Button & Signal Button
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

                            if viewModel.isMe {
                                Button(action: { showSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.black.opacity(0.45))
                                        .clipShape(Circle())
                                }
                            } else {
                                Button(action: { viewModel.onSignalUserClick() }) {
                                    Image("ic_signal_orange")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .colorMultiply(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.black.opacity(0.45))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 52)
                    }
                )

                Spacer()
                    .frame(height: 20)
                VStack(spacing: 10) {
                    // Name - centered, bold
                    if let displayName = viewModel.user?.displayName, !displayName.isEmpty {
                        Text(displayName)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Roles and Partner stack (beige pills with orange text)
                    if let roles = viewModel.user?.roles, !roles.isEmpty, 
                       let partnerText = viewModel.user?.partner?.name ?? viewModel.user?.organization?.name, !partnerText.isEmpty {
                        HStack(spacing: 4) {
                            // Roles pill
                            if !roles.isEmpty {
                                Text(roles.joined(separator: " • "))
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appOrange))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.appBeige)
                                    .cornerRadius(11)
                                    .fixedSize(horizontal: true, vertical: false)
                            }

                            // Partner pill
                            if !partnerText.isEmpty {
                                HStack(spacing: 4) {
                                    if let partnerLogoUrl = viewModel.user?.partner?.smallLogoUrl {
                                        PartnerLogoView(urlString: partnerLogoUrl)
                                            .frame(width: 30, height: 30)
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
                                .onTapGesture {
                                    viewModel.onPartnerClick()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else if let roles = viewModel.user?.roles, !roles.isEmpty {
                        // Only roles
                        Text(roles.joined(separator: " • "))
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appOrange))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.appBeige)
                            .cornerRadius(11)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: true, vertical: false)
                    } else if let partnerText = viewModel.user?.partner?.name ?? viewModel.user?.organization?.name, !partnerText.isEmpty {
                        // Only partner
                        HStack(spacing: 4) {
                            if let partnerLogoUrl = viewModel.user?.partner?.smallLogoUrl {
                                PartnerLogoView(urlString: partnerLogoUrl)
                                    .frame(width: 30, height: 30)
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
                        .onTapGesture {
                            viewModel.onPartnerClick()
                        }
                    }

                    // Info stack (city, phone, email, birthdate, description)
                    VStack(spacing: 10) {
                        if let city = viewModel.user?.addressPrimary?.displayAddress, !city.isEmpty {
                            let radiusString = String(viewModel.user?.radiusDistance ?? 0)
                            let fullAddress = "\(city) - \(radiusString) km"
                            Text(fullAddress)
                                .font(Font(UIFont(name: "HelveticaNeue", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if let phone = viewModel.user?.phone, !phone.isEmpty, viewModel.isMe {
                            Text(ProfileViewHelpers.formatPhoneNumber(phone))
                                .font(Font(UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if let email = viewModel.user?.email, !email.isEmpty, viewModel.isMe {
                            Text(email)
                                .font(Font(UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if let birthdate = viewModel.user?.birthdate, !birthdate.isEmpty, viewModel.isMe {
                            Text(ProfileViewHelpers.formatBirthdate(birthdate))
                                .font(Font(UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if let aboutText = viewModel.user?.about, !aboutText.isEmpty {
                            Text(aboutText)
                                .font(Font(UIFont.systemFont(ofSize: 15)))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 10)

                    // Modify or Send Message button - match UIKit style
                    Button(action: {
                        if viewModel.isMe {
                            viewModel.modifyProfile()
                        } else {
                            viewModel.sendMessage()
                        }
                    }) {
                        Text(viewModel.isMe ? "modify".localized : "detail_user_send_message".localized)
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

                // Main user activity
                if let user = viewModel.user {
                    MainStatUserView(isMe: viewModel.isMe, user: user)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }

                // Badges section (tous les profils)
                BadgesSectionView(
                    apiBadges: viewModel.apiBadges,
                    isMe: viewModel.isMe,
                    onShowAllBadges: { showBadgesList = true },
                    onBadgeTap: viewModel.isMe ? { p in selectedBadgeProgress = p } : nil
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .fullScreenCover(isPresented: $showBadgesList) {
                    BadgesListView()
                }
                .sheet(item: $selectedBadgeProgress) { p in
                    BadgeDetailSheet(
                        progress: p,
                        isMe: viewModel.isMe,
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

            }
        }
        .edgesIgnoringSafeArea(.top)
        .id(viewModel.user?.uuid ?? "profile")
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView(viewModel: viewModel)
        }
    }
}

// MARK: - Helpers

enum ProfileViewHelpers {
    static func formatPhoneNumber(_ number: String) -> String {
        var formatted = number
        if number.hasPrefix("+33") {
            formatted = "0" + number.dropFirst(3)
        }
        let digits = formatted.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        guard digits.count == 10 else { return number }
        return stride(from: 0, to: digits.count, by: 2).map { i -> String in
            let start = digits.index(digits.startIndex, offsetBy: i)
            let end = digits.index(start, offsetBy: 2, limitedBy: digits.endIndex) ?? digits.endIndex
            return String(digits[start..<end])
        }.joined(separator: " ")
    }

    static func formatBirthdate(_ raw: String) -> String {
        if let date = Utils.getDateFromWSDateString(raw) {
            return Utils.formatEventDate(date: date)
        }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        if let date = parser.date(from: raw) {
            let display = DateFormatter()
            display.dateFormat = "dd/MM/yyyy"
            return display.string(from: date)
        }
        return raw
    }
}

// MARK: - Subviews

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

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale.getPreferredLocale()
        fmt.dateFormat = "MM/yyyy"
        return fmt.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title — "Mon activité" / "Son activité"
            Text(isMe ? "mainUserTitleActivity".localized : "detail_user_his_activity".localized)
                .font(.custom("Quicksand-Bold", size: 15))
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.bottom, 18)

            // Member since card (full width)
            if let date = user.creationDate {
                VStack(spacing: 2) {
                    Text("memberSince".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.black)
                    Text(formatDate(date))
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.appOrangeLight), lineWidth: 1))
                .padding(.bottom, 12)
            }

            // Two stat cards side by side
            HStack(spacing: 8) {
                let groups = user.stats?.neighborhoodsCount ?? 0
                let outings = max(0, user.stats?.outingsCount ?? 0)

                statCard(
                    count: groups,
                    label: groups <= 1 ? "mainUserTitleGroup".localized : "mainUserTitleGroups".localized,
                    systemIcon: "person.2.fill"
                )
                statCard(
                    count: outings,
                    label: outings <= 1 ? "mainUserTitleOuting".localized : "mainUserTitleOutings".localized,
                    systemIcon: "calendar"
                )
            }
        }
        .padding(10)
        .background(Color.appBeige)
        .cornerRadius(10)
    }

    private func statCard(count: Int, label: String, systemIcon: String) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.custom("Quicksand-Bold", size: 20))
                .foregroundColor(count == 0 ? Color(UIColor.appGris112) : .black)

            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.appOrange))
                Text(label)
                    .font(.custom("NunitoSans-Regular", size: 13))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.appOrangeLight), lineWidth: 1))
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
                if isMe { 
                    viewModel.navigationDelegate?.openEnhancedOnboarding(mode: .interest)
                }
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
        guard let interests = interests, !interests.isEmpty else { 
            return "no_data_available".localized 
        }
        let result = interests.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        return result
    }

    private func formatInvolvements(_ involvements: [String], isAssociation: Bool) -> String {
        guard !involvements.isEmpty else { 
            return "no_data_available".localized 
        }
        let result = involvements.map { isAssociation ? TagsUtils.showOrientationTranslated($0) : TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        return result
    }

    private func formatConcerns(_ concerns: [String]?) -> String {
        guard let concerns = concerns, !concerns.isEmpty else { 
            return "no_data_available".localized 
        }
        let result = concerns.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        return result
    }

    private func formatAvailability(_ availability: [String: [String]]?) -> String {
        guard let availability = availability, !availability.isEmpty else { 
            return "no_data_available".localized 
        }
        var availabilityParts: [String] = []
        for (dayKey, slots) in availability {
            let dayLabel = dayName(for: dayKey)
            let slotLabels = slots.map { timeSlotName(for: $0) }.joined(separator: ", ")
            availabilityParts.append("\\(dayLabel) (\\(slotLabels))")
        }
        let result = availabilityParts.joined(separator: " • ")
        return result
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

            Button(action: { 
                viewModel.navigationDelegate?.showLanguageSelector() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_language",
                    title: "settings_language_title".localized,
                    subtitle: formatLanguage(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showNotificationSettings() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_notif",
                    title: "settings_notifications_title".localized,
                    subtitle: formatNotifications(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showBlockedContacts() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_block_people",
                    title: "settings_unblock_contacts_title".localized,
                    subtitle: formatBlockedUsers(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.openFeedbackUrl() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_suggest",
                    title: "settings_feedback_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.shareApp() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profile_full_share",
                    title: "settings_share_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showHelp() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profile_help",
                    title: "settings_help_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showPasswordChange() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_mdp",
                    title: "settings_password_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showLogoutAlert() 
            }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_log_out",
                    title: "logout_button".localized,
                    subtitle: "",
                    isMe: true,
                    isDestructive: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { 
                viewModel.navigationDelegate?.showDeleteAccountAlert() 
            }) {
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
        let result = String(localizedKey.dropFirst(3))
        return result
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
            let result = String(format: "settings_notifications_subtitle".localized, activatedNotif.joined(separator: ", "))
            return result
        }
    }

    private func formatBlockedUsers() -> String {
        if numberOfBlocked == 0 {
            return "settings_unblock_contacts_subtitle_none".localized
        } else {
            let result = String.localizedStringWithFormat(
                numberOfBlocked == 1 ? "settings_unblock_contacts_subtitle".localized : "settings_unblock_contacts_subtitle_plural".localized,
                numberOfBlocked
            )
            return result
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
    @Published var apiBadges: [UserBadgeAPI] = []

    weak var navigationDelegate: ProfileNavigationDelegate?

    func handleBackButtonTap() {}

    func loadData() {
        guard let currentUser = UserDefaults.currentUser else { 
            return 
        }

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
                        self?.apiBadges = returnUser.badges ?? []
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
        guard let currentPartner = self.user?.partner else { 
            return 
        }
        navigationDelegate?.showPartnerDetails(partner: currentPartner)
    }

    func sendMessage() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        guard let currentUserId = user?.sid.description else { 
            return 
        }
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
        return "Version \(version) (\(build))"
    }
}

// MARK: - BasicProfileNavigationDelegate

/// Delegate used when showing another user's profile from any context.
/// Handles partner, conversation, and report navigation. All isMe-only actions are no-ops.
class BasicProfileNavigationDelegate: NSObject, ProfileNavigationDelegate {
    weak var presenter: UIViewController?

    init(presenter: UIViewController) { self.presenter = presenter }

    func showImagePicker() {}
    func showProfileEditor(user: User?) {}
    func openEnhancedOnboarding(mode: EnhancedOnboardingMode) {}
    func showLanguageSelector() {}
    func showNotificationSettings() {}
    func showHelp() {}
    func showBlockedContacts() {}
    func openFeedbackUrl() {}
    func shareApp() {}
    func showPasswordChange() {}
    func showLogoutAlert() {}
    func showDeleteAccountAlert() {}

    func showPartnerDetails(partner: Partner) {
        guard let navVc = UIStoryboard(name: StoryboardName.partnerDetails, bundle: nil)
                .instantiateInitialViewController() as? UINavigationController,
              let vc = navVc.topViewController as? PartnerDetailViewController else { return }
        if let id = partner.aid { vc.partnerId = id } else { vc.partner = partner }
        DispatchQueue.main.async { AppState.getTopViewController()?.present(navVc, animated: true) }
    }

    func showConversation(conversation: Conversation?) {
        DispatchQueue.main.async {
            guard let convId = conversation?.uid else { return }
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC")
                as? ConversationDetailMessagesViewController {
                vc.setupFromOtherVC(conversationId: convId, title: conversation?.title,
                                    isOneToOne: true, conversation: conversation)
                AppState.getTopViewController()?.present(vc, animated: true)
            }
        }
    }

    func showReportUser(user: User?) {
        guard let vc = UIStoryboard(name: StoryboardName.userDetail, bundle: nil)
            .instantiateViewController(withIdentifier: "reportUserMainVC")
            as? ReportUserMainViewController else { return }
        vc.user = user
        DispatchQueue.main.async { AppState.getTopViewController()?.present(vc, animated: true) }
    }
}

// MARK: - Presentation helper

private var associatedDelegateKey = "profileNavDelegate"

extension UIViewController {
    /// Present the SwiftUI profile for a given userId.
    /// Automatically detects if it's the current user and sets isMe accordingly.
    func presentOtherUserProfile(userId: String) {
        let currentUserId = UserDefaults.currentUser?.sid.description ?? ""
        let isCurrentUser = !userId.isEmpty && userId == currentUserId

        let vm = ProfileViewModel()
        if isCurrentUser {
            // Own profile — no userIdToDisplay, loadData will set isMe=true
            vm.isMe = true
        } else {
            vm.userIdToDisplay = userId
            vm.isMe = false
        }
        let delegate = BasicProfileNavigationDelegate(presenter: self)
        vm.navigationDelegate = delegate
        let hc = UIHostingController(rootView: ProfileView(viewModel: vm))
        hc.modalPresentationStyle = .fullScreen
        objc_setAssociatedObject(hc, &associatedDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        present(hc, animated: true)
    }
}
