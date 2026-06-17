import SwiftUI

struct ProfileSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    settingsRows
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    Text(viewModel.getAppVersion())
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)))
                        .foregroundColor(.gray)
                        .padding(.vertical, 16)
                }
            }
            .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("settings_section_title".localized, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    // MARK: - Rows

    private var settingsRows: some View {
        VStack(spacing: 0) {
            Button(action: { viewModel.navigationDelegate?.showLanguageSelector() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_language",
                    title: "settings_language_title".localized,
                    subtitle: formatLanguage(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.showNotificationSettings() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_notif",
                    title: "settings_notifications_title".localized,
                    subtitle: formatNotifications(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.showBlockedContacts() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_block_people",
                    title: "settings_unblock_contacts_title".localized,
                    subtitle: formatBlockedUsers(),
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.openFeedbackUrl() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_suggest",
                    title: "settings_feedback_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.shareApp() }) {
                ProfileStandardRow(
                    imageName: "ic_profile_full_share",
                    title: "settings_share_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.showHelp() }) {
                ProfileStandardRow(
                    imageName: "ic_profile_help",
                    title: "settings_help_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

            Button(action: { viewModel.navigationDelegate?.showPasswordChange() }) {
                ProfileStandardRow(
                    imageName: "ic_profil_full_mdp",
                    title: "settings_password_title".localized,
                    subtitle: "",
                    isMe: true
                )
            }
            .buttonStyle(PlainButtonStyle())

            Divider().padding(.leading, 52)

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

            Divider().padding(.leading, 52)

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
    }

    // MARK: - Formatters

    private func formatLanguage() -> String {
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        let languageMapping: [String: String] = [
            "fr": "lang_fr", "en": "lang_en", "es": "lang_es",
            "ar": "lang_ar", "uk": "lang_uk", "de": "lang_de",
            "ro": "lang_ro", "pl": "lang_pl"
        ]
        let key = languageMapping[preferredLanguage]?.localized ?? "lang_fr".localized
        return String(key.dropFirst(3))
    }

    private func formatNotifications() -> String {
        if viewModel.activatedNotif.isEmpty {
            return "settings_notifications_subtitle_none".localized
        }
        return String(format: "settings_notifications_subtitle".localized, viewModel.activatedNotif.joined(separator: ", "))
    }

    private func formatBlockedUsers() -> String {
        let n = viewModel.numberOfBlocked
        if n == 0 { return "settings_unblock_contacts_subtitle_none".localized }
        return String.localizedStringWithFormat(
            n == 1 ? "settings_unblock_contacts_subtitle".localized : "settings_unblock_contacts_subtitle_plural".localized,
            n
        )
    }
}
