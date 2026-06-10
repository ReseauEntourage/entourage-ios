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
        print("DEBUG: ProfileImageView makeUIView called, size: ", size)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        print("DEBUG: ProfileImageView makeUIView completed")
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        print("DEBUG: ProfileImageView updateUIView called, urlString: ", urlString as Any)
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
        print("DEBUG: PartnerLogoView makeUIView called")
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        print("DEBUG: PartnerLogoView makeUIView completed")
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        print("DEBUG: PartnerLogoView updateUIView called, urlString: ", urlString)
        if let url = URL(string: urlString) {
            print("DEBUG: PartnerLogoView loading image from URL: ", url)
            uiView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
}

// MARK: - Main View

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        print("DEBUG: ProfileView body called")
        return ScrollView {
            VStack(spacing: 0) {
                // Header with profile image and back button
                ZStack {
                    // Use the same background image as UIKit version
                    Image("ic_backgrnd_welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 376) // Match UIKit height
                        .clipped()
                }
                .overlay(
                    ZStack(alignment: .top) {
                        // Profile Image and Modify Button
                        VStack {
                            Spacer()
                                .frame(height: 106) // Position avatar top at 106 to match UIKit
                            
                            ZStack(alignment: .bottomTrailing) {
                                ProfileImageView(
                                    urlString: viewModel.user?.avatarURL,
                                    size: CGSize(width: 80, height: 80)
                                        

                                )
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(40)
                                if viewModel.isMe {
                                    Button(action: {
                                        print("DEBUG: Modify image button tapped")
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
                            Button(action: {
                                print("DEBUG: Back button tapped")
                                viewModel.handleBackButtonTap()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .frame(width: 50, height: 50)
                            .position(x: 50, y: 50)

                            Spacer()

                            if !viewModel.isMe {
                                Button(action: {
                                    print("DEBUG: Signal user button tapped")
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

                // Spacing between header and content (60pts like UIKit)
                Spacer()
                    .frame(height: 60)

                // User info section - redesigned to match UIKit HeaderProfilFullCell
                VStack(spacing: 10) {
                    // Name - centered, bold
                    if let displayName = viewModel.user?.displayName, !displayName.isEmpty {
                        Text(displayName)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 70)
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
                                    print("DEBUG: Partner button tapped")
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
                            print("DEBUG: Partner button tapped")
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
                            Text(phone)
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
                            Text(birthdate)
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
                        print("DEBUG: Main action button tapped, isMe: ", viewModel.isMe)
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
        .edgesIgnoringSafeArea(.top)
        .id(viewModel.user?.uuid ?? "profile")
        .onAppear {
            print("DEBUG: ProfileView onAppear called")
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
        print("DEBUG: formatRadiusText called, currentRadius: ", user.radiusDistance ?? 0)
        let currentRadius = user.radiusDistance ?? 0
        let str = String(format: "mainUserCityRadius".localized, currentRadius)
        let radiusStr = String(currentRadius)

        if let range = str.range(of: radiusStr) {
            let before = str[str.startIndex..<range.lowerBound]
            let after = str[range.upperBound...]

            let result = Text(before) +
                Text(radiusStr)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                    .foregroundColor(Color(UIColor.appOrange)) +
                Text(after)
            print("DEBUG: formatRadiusText result: ", result)
            return result
        }
        let result = Text(str)
        print("DEBUG: formatRadiusText result: ", result)
        return result
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
        print("DEBUG: formatCreationDate called, date: ", date)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/yyyy"
        let result = dateFormat.string(from: date)
        print("DEBUG: formatCreationDate result: ", result)
        return result
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
                print("DEBUG: Interests button tapped, isMe: ", isMe)
                if isMe { 
                    print("DEBUG: navigationDelegate: ", viewModel.navigationDelegate as Any)
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
                print("DEBUG: Involvements button tapped, isMe: ", isMe)
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
                    print("DEBUG: Concerns button tapped, isMe: ", isMe)
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
                    print("DEBUG: Availability button tapped, isMe: ", isMe)
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
        print("DEBUG: formatInterests called, interests: ", interests as Any)
        guard let interests = interests, !interests.isEmpty else { 
            print("DEBUG: formatInterests returning no_data_available")
            return "no_data_available".localized 
        }
        let result = interests.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        print("DEBUG: formatInterests result: ", result)
        return result
    }

    private func formatInvolvements(_ involvements: [String], isAssociation: Bool) -> String {
        print("DEBUG: formatInvolvements called, involvements: ", involvements, "isAssociation: ", isAssociation)
        guard !involvements.isEmpty else { 
            print("DEBUG: formatInvolvements returning no_data_available")
            return "no_data_available".localized 
        }
        let result = involvements.map { isAssociation ? TagsUtils.showOrientationTranslated($0) : TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        print("DEBUG: formatInvolvements result: ", result)
        return result
    }

    private func formatConcerns(_ concerns: [String]?) -> String {
        print("DEBUG: formatConcerns called, concerns: ", concerns as Any)
        guard let concerns = concerns, !concerns.isEmpty else { 
            print("DEBUG: formatConcerns returning no_data_available")
            return "no_data_available".localized 
        }
        let result = concerns.map { TagsUtils.showTagTranslated($0) }.joined(separator: ", ")
        print("DEBUG: formatConcerns result: ", result)
        return result
    }

    private func formatAvailability(_ availability: [String: [String]]?) -> String {
        print("DEBUG: formatAvailability called, availability: ", availability as Any)
        guard let availability = availability, !availability.isEmpty else { 
            print("DEBUG: formatAvailability returning no_data_available")
            return "no_data_available".localized 
        }
        var availabilityParts: [String] = []
        for (dayKey, slots) in availability {
            let dayLabel = dayName(for: dayKey)
            let slotLabels = slots.map { timeSlotName(for: $0) }.joined(separator: ", ")
            availabilityParts.append("\\(dayLabel) (\\(slotLabels))")
        }
        let result = availabilityParts.joined(separator: " • ")
        print("DEBUG: formatAvailability result: ", result)
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
                print("DEBUG: Language selector button tapped")
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
                print("DEBUG: Notification settings button tapped")
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
                print("DEBUG: Blocked contacts button tapped")
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
                print("DEBUG: Feedback button tapped")
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
                print("DEBUG: Share app button tapped")
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
                print("DEBUG: Help button tapped")
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
                print("DEBUG: Password change button tapped")
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
                print("DEBUG: Logout button tapped")
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
                print("DEBUG: Delete account button tapped")
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
        print("DEBUG: formatLanguage called")
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        print("DEBUG: preferredLanguage: ", preferredLanguage)
        let localizedKey = getLocalizedKey(for: preferredLanguage)
        let result = String(localizedKey.dropFirst(3))
        print("DEBUG: formatLanguage result: ", result)
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
        print("DEBUG: formatNotifications called, activatedNotif: ", activatedNotif)
        if activatedNotif.isEmpty {
            print("DEBUG: formatNotifications returning none")
            return "settings_notifications_subtitle_none".localized
        } else {
            let result = String(format: "settings_notifications_subtitle".localized, activatedNotif.joined(separator: ", "))
            print("DEBUG: formatNotifications result: ", result)
            return result
        }
    }

    private func formatBlockedUsers() -> String {
        print("DEBUG: formatBlockedUsers called, numberOfBlocked: ", numberOfBlocked)
        if numberOfBlocked == 0 {
            print("DEBUG: formatBlockedUsers returning none")
            return "settings_unblock_contacts_subtitle_none".localized
        } else {
            let result = String.localizedStringWithFormat(
                numberOfBlocked == 1 ? "settings_unblock_contacts_subtitle".localized : "settings_unblock_contacts_subtitle_plural".localized,
                numberOfBlocked
            )
            print("DEBUG: formatBlockedUsers result: ", result)
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

    weak var navigationDelegate: ProfileNavigationDelegate?

    func handleBackButtonTap() {
        print("DEBUG: handleBackButtonTap called")
        navigationDelegate?.dismiss()
    }

    func loadData() {
        print("DEBUG: loadData called")
        guard let currentUser = UserDefaults.currentUser else { 
            print("DEBUG: currentUser is nil")
            return 
        }
        print("DEBUG: currentUser loaded: ", currentUser)

        self.user = currentUser
        self.isMe = userIdToDisplay == nil
        print("DEBUG: isMe = ", self.isMe)

        HomeService.getNotifsPermissions { [weak self] notifPerms, error in
            guard let self = self else { return }
            print("DEBUG: getNotifsPermissions callback, notifPerms: ", notifPerms as Any, "error: ", error as Any)
            if let notifPerms = notifPerms {
                var activeNotifs: [String] = []
                if notifPerms.chat_message { activeNotifs.append("message") }
                if notifPerms.neighborhood { activeNotifs.append("groupe") }
                if notifPerms.outing { activeNotifs.append("événement") }
                if notifPerms.action { activeNotifs.append("action") }
                DispatchQueue.main.async {
                    self.activatedNotif = activeNotifs
                    print("DEBUG: activatedNotif set to: ", activeNotifs)
                }
            }
        }

        MessagingService.getUsersBlocked { [weak self] blockedUsers, error in
            print("DEBUG: getUsersBlocked callback, blockedUsers: ", blockedUsers as Any, "error: ", error as Any)
            DispatchQueue.main.async {
                self?.numberOfBlocked = blockedUsers?.count ?? 0
                print("DEBUG: numberOfBlocked set to: ", self?.numberOfBlocked ?? 0)
            }
        }

        let userIdToLoad = userIdToDisplay ?? currentUser.uuid ?? ""
        print("DEBUG: userIdToLoad = ", userIdToLoad)
        if !userIdToLoad.isEmpty {
            UserService.getDetailsForUser(userId: userIdToLoad) { [weak self] returnUser, error in
                print("DEBUG: getDetailsForUser callback, returnUser: ", returnUser as Any, "error: ", error as Any)
                DispatchQueue.main.async {
                    if let returnUser = returnUser {
                        self?.user = returnUser
                        print("DEBUG: user set to: ", returnUser)
                        if self?.isMe == true {
                            UserDefaults.currentUser = returnUser
                        }
                    }
                }
            }
        }
    }

    func modifyImageClick() {
        print("DEBUG: modifyImageClick called")
        print("DEBUG: navigationDelegate: ", navigationDelegate as Any)
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        navigationDelegate?.showImagePicker()
    }

    func modifyProfile() {
        print("DEBUG: modifyProfile called")
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        navigationDelegate?.showProfileEditor(user: self.user)
    }

    func onSignalUserClick() {
        print("DEBUG: onSignalUserClick called")
        navigationDelegate?.showReportUser(user: self.user)
    }

    func onPartnerClick() {
        print("DEBUG: onPartnerClick called")
        guard let currentPartner = self.user?.partner else { 
            print("DEBUG: currentPartner is nil")
            return 
        }
        print("DEBUG: currentPartner: ", currentPartner)
        navigationDelegate?.showPartnerDetails(partner: currentPartner)
    }

    func sendMessage() {
        print("DEBUG: sendMessage called")
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        guard let currentUserId = user?.sid.description else { 
            print("DEBUG: currentUserId is nil")
            return 
        }
        print("DEBUG: currentUserId: ", currentUserId)
        MessagingService.createOrGetConversation(userId: currentUserId) { [weak self] conversation, error in
            print("DEBUG: createOrGetConversation callback, conversation: ", conversation as Any, "error: ", error as Any)
            if let conversation = conversation {
                self?.navigationDelegate?.showConversation(conversation: conversation)
                return
            }
            let _ = error?.message ?? "message_error_create_conversation".localized
        }
    }

    func getAppVersion() -> String {
        print("DEBUG: getAppVersion called")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let result = "Version \(version) \(build)"
        print("DEBUG: getAppVersion result: ", result)
        return result
    }
}
