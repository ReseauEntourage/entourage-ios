import SwiftUI

// MARK: - Hosting Controller

final class OtherUserProfileHostingController: UIHostingController<OtherUserProfileView> {
    private let viewModel: OtherUserProfileViewModel

    init(rootView: OtherUserProfileView, viewModel: OtherUserProfileViewModel) {
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

protocol OtherUserProfileNavigationDelegate: AnyObject {
    func showPartnerDetails(partner: Partner)
    func showConversation(conversation: Conversation?)
    func showReportUser(user: User?)
}

// MARK: - ViewModel

class OtherUserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var apiBadges: [UserBadgeAPI] = []

    var userIdToDisplay: String
    weak var navigationDelegate: OtherUserProfileNavigationDelegate?

    init(userIdToDisplay: String) {
        self.userIdToDisplay = userIdToDisplay
    }

    func loadData() {
        if !userIdToDisplay.isEmpty {
            UserService.getDetailsForUser(userId: userIdToDisplay) { [weak self] returnUser, error in
                DispatchQueue.main.async {
                    if let returnUser = returnUser {
                        self?.user = returnUser
                        self?.apiBadges = returnUser.badges ?? []
                    }
                }
            }
        }
    }

    func onPartnerClick() {
        guard let partner = self.user?.partner else { return }
        navigationDelegate?.showPartnerDetails(partner: partner)
    }

    func sendMessage() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        guard let currentUserId = user?.sid.description else { return }
        MessagingService.createOrGetConversation(userId: currentUserId) { [weak self] conversation, error in
            if let conversation = conversation {
                self?.navigationDelegate?.showConversation(conversation: conversation)
            }
        }
    }

    func reportUser() {
        navigationDelegate?.showReportUser(user: self.user)
    }
}

// MARK: - Main View

struct OtherUserProfileView: View {
    @StateObject var viewModel: OtherUserProfileViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showBadgesList = false

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
                        Button(action: { viewModel.reportUser() }) {
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

                            let aboutText = viewModel.user?.about?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if !aboutText.isEmpty {
                                Text(aboutText)
                                    .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                                    .foregroundColor(Color(UIColor.appGris112))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 10)

                        Button(action: { viewModel.sendMessage() }) {
                            Text("detail_user_send_message".localized)
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
                        MainStatUserView(isMe: false, user: user)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }

                    BadgesSectionView(
                        apiBadges: viewModel.apiBadges,
                        isMe: false,
                        onShowAllBadges: { showBadgesList = true },
                        onBadgeTap: nil
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .fullScreenCover(isPresented: $showBadgesList) {
                        BadgesListView()
                    }

                    if let user = viewModel.user {
                        OtherUserPreferencesSectionView(user: user)
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
                    ProfileImageView(
                        urlString: viewModel.user?.avatarURL,
                        size: CGSize(width: 120, height: 120)
                    )
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    Spacer()
                }
                .padding(.top, safeAreaTop),
                alignment: .top
            )
        }
        .edgesIgnoringSafeArea(.top)
        .id(viewModel.user?.uuid ?? "other-profile")
        .onAppear { viewModel.loadData() }
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

// MARK: - Preferences Section (Other User, read-only)

struct OtherUserPreferencesSectionView: View {
    let user: User

    var body: some View {
        VStack(spacing: 0) {
            Text("preferences_section_title_others".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ProfileStandardRow(
                imageName: "ic_profil_full_interest",
                title: "preferences_interest_title_others".localized,
                subtitle: formatInterests(user.interests),
                isMe: false
            )

            let involvements = (user.partner != nil) ? (user.orientations ?? []) : (user.involvements ?? [])
            ProfileStandardRow(
                imageName: "ic_profil_full_action",
                title: "preferences_action_title_others".localized,
                subtitle: formatInvolvements(involvements, isAssociation: user.partner != nil),
                isMe: false
            )

            if user.partner == nil {
                ProfileStandardRow(
                    imageName: "ic_profil_full_action_category",
                    title: "preferences_action_categories_title_others".localized,
                    subtitle: formatConcerns(user.concerns),
                    isMe: false
                )

                ProfileStandardRow(
                    imageName: "ic_profil_full_disponibility",
                    title: "preferences_availability_title_others".localized,
                    subtitle: formatAvailability(user.availability),
                    isMe: false
                )
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

// MARK: - Default Navigation Delegate

class BasicOtherUserProfileNavigationDelegate: NSObject, OtherUserProfileNavigationDelegate {
    weak var presenter: UIViewController?

    init(presenter: UIViewController) { self.presenter = presenter }

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

// MARK: - Presentation Helper

private var associatedOtherProfileDelegateKey = "otherProfileNavDelegate"

extension UIViewController {
    func presentOtherUserProfile(userId: String) {
        let vm = OtherUserProfileViewModel(userIdToDisplay: userId)
        let delegate = BasicOtherUserProfileNavigationDelegate(presenter: self)
        vm.navigationDelegate = delegate
        let hc = UIHostingController(rootView: OtherUserProfileView(viewModel: vm))
        hc.modalPresentationStyle = .fullScreen
        objc_setAssociatedObject(hc, &associatedOtherProfileDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        present(hc, animated: true)
    }
}
