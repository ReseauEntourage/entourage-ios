//
//  ProfilFullViewController.swift
//  entourage
//
//  Created by Clement entourage on 09/01/2025.
//

import UIKit

protocol ImageReUpLoadDelegate{
    func reloadOnImageUpdate()
}

enum ProfileFullDTO {
    case header(user: User)
    case mainUserActivity(user: User)
    case section(title: String)
    case standard(img: String, title: String, subtitle: String)
}

class ProfilFullViewController: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var btn_back: UIImageView!
    @IBOutlet weak var btn_signal: UIImageView!
    @IBOutlet weak var constraint_table_view_top: NSLayoutConstraint!
    @IBOutlet weak var image_modify: UIImageView!
    @IBOutlet weak var ui_view_image_modify: UIView!
    
    
    // VARIABLE
    var tableDTO = [ProfileFullDTO]()
    var user: User?
    var isMe: Bool = true
    var activated_notif : [String] = []
    var numberOfBlocked :Int = 0
    var userIdToDisplay: String?

    let profileImageMaxHeight: CGFloat = 120
    let profileImageMinHeight: CGFloat = 0
    let modifyButtonMaxHeight: CGFloat = 30

    let tableViewTopMax: CGFloat = 70
    let tableViewTopMin: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        user = UserDefaults.currentUser
        
        // Enregistrement des NIB/Cell
        ui_table_view.register(UINib(nibName: HeaderProfilFullCell.identifier, bundle: nil),
                               forCellReuseIdentifier: HeaderProfilFullCell.identifier)
        ui_table_view.register(UINib(nibName: ProfileFullStandardCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ProfileFullStandardCell.identifier)
        ui_table_view.register(UINib(nibName: ProfileSectionCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ProfileSectionCell.identifier)
        ui_table_view.register(UINib(nibName: MainStatUserCell.identifier, bundle: nil),
                               forCellReuseIdentifier: MainStatUserCell.identifier)
        
        
        // Ajout d’un padding visuel en réduisant légèrement la taille de l’image
        ui_view_image_modify.layer.cornerRadius = 15 // Arrondi de 1dp
        ui_view_image_modify.layer.borderWidth = 1 // Bordure blanche de 1dp
        ui_view_image_modify.layer.borderColor = UIColor.white.cgColor
        ui_view_image_modify.clipsToBounds = true

        
        
        // Ajout d’un geste pour fermer la vue sur le bouton back
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackButtonTap))
        btn_back.isUserInteractionEnabled = true
        btn_back.addGestureRecognizer(tapGesture)
        
        //Ajout click image_modify
        ui_view_image_modify.isUserInteractionEnabled = true
        let tapModifyGesture = UITapGestureRecognizer(target: self, action: #selector(modifyImageClick))
        ui_view_image_modify.addGestureRecognizer(tapModifyGesture)
        
    }
    
    @objc func handleBackButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.user == nil{
            self.user = UserDefaults.currentUser
        }
        loadData()

        

    }
    
    func loadData(){
        HomeService.getNotifsPermissions { notifPerms, error in
            // Vérifier et afficher les notifications activées
            if let notifPerms = notifPerms {
                var activeNotifs: [String] = []

                if notifPerms.chat_message {
                    activeNotifs.append("message")
                }
                if notifPerms.neighborhood {
                    activeNotifs.append("groupe")
                }
                if notifPerms.outing {
                    activeNotifs.append("événement")
                }
                if notifPerms.action {
                    activeNotifs.append("action")
                }
                self.activated_notif = activeNotifs
                //self.activated_notif = activeNotifs.joined(separator: ", ")
                MessagingService.getUsersBlocked { blockedUsers, error in
                    self.numberOfBlocked = blockedUsers?.count ?? 0
                    if let _otherUserId = self.userIdToDisplay {
                        self.isMe = false
                        UserService.getDetailsForUser(userId: _otherUserId) { returnUser, error in
                            if let returnUser = returnUser {
                                self.user = returnUser
                                self.loadImage()
                                self.loadDTO()
                            }
                        }

                    }else{
                        UserService.getDetailsForUser(userId: self.user?.uuid ?? "") { returnUser, error in
                            if let returnUser = returnUser {
                                self.user = returnUser
                                self.loadImage()
                                self.loadDTO()
                            }
                        }

                    }
                }
            }
        }
    }
    
    func loadImage(){
        if let url = URL(string: user?.avatarURL ?? ""){
            self.img_profile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
    }
    
    @objc func modifyImageClick() {
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)

        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
        
        // Instancier le UINavigationController
        if let navVC = sb.instantiateViewController(withIdentifier: "editProfilePhotoNav") as? UINavigationController,
           let editPhotoVC = navVC.topViewController as? UserPhotoAddViewController { // Récupérer le premier VC
            editPhotoVC.pictureSettingDelegate = self // Assigner le delegate
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    func modifyProfile(){
        AnalyticsLoggerManager.logEvent(name: Profile_action_modify)
        let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
        if let navVC = sb.instantiateViewController(withIdentifier: "editProfileMainNav") as? UINavigationController , let editVC = navVC.topViewController as? ProfileEditorViewController  {
            editVC.profilFullDelegate = self
            editVC.currentUser = self.user
            self.present(navVC, animated: true)

        }
    }
    
    private func openEnhancedOnboarding(mode: EnhancedOnboardingMode) {
        // On configure la variable de configuration pour savoir qu’on vient des settings
        EnhancedOnboardingConfiguration.shared.isInterestsFromSetting = true
        
        // Instancier le storyboard (adaptez le nom s’il est différent)
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "enhancedOnboarding") as? EnhancedViewController {
            // On spécifie le mode (interest, concern, involvement ou choiceDisponibility)
            EnhancedOnboardingConfiguration.shared.isInterestsFromSetting = true
            vc.mode = mode
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }

    
    func showPopLogout() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_logout_pop_logout".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_logout_pop_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_logout_pop_title".localized, message: "params_logout_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .Logout
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopSuppress() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_suppress_pop_suppress".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_suppress_pop_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_suppress_pop_title".localized, message: "params_suppress_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
    
    
    func getLocalizedKey(for lang: String) -> String {
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
        
        return languageMapping[lang]?.localized ?? "lang_fr".localized // Valeur par défaut : français
    }
    func loadDTO() {
        tableDTO.removeAll()
        
        guard let user = user else { return }
        
        // 1) Header
        tableDTO.append(.header(user: user))
        
        // 2) Activité principale
        tableDTO.append(.mainUserActivity(user: user))
        
        // --------------------------------------------------
        // PRÉPARATION DES SOUS-TITRES POUR LES PRÉFÉRENCES
        // --------------------------------------------------
        
        // (A) Centres d’intérêt
        let userInterests = user.interests ?? []
        let interestsDisplay: String
        if userInterests.isEmpty {
            interestsDisplay = "no_data_available".localized  // "Non renseigné"
        } else {
            // Exemple: ["sport", "cuisine"] → "Sport, Cuisine"
            interestsDisplay = userInterests
                .map { TagsUtils.showTagTranslated($0) }
                .joined(separator: ", ")
        }
        
        // (B) Envies d’agir
        let userInvolvements = user.involvements ?? []
        let involvementsDisplay: String
        if userInvolvements.isEmpty {
            involvementsDisplay = "no_data_available".localized
        } else {
            involvementsDisplay = userInvolvements
                .map { TagsUtils.showTagTranslated($0) }
                .joined(separator: ", ")
        }
        
        // (C) Catégories d’entraide
        let userConcerns = user.concerns ?? []
        let concernsDisplay: String
        if userConcerns.isEmpty {
            concernsDisplay = "no_data_available".localized
        } else {
            concernsDisplay = userConcerns
                .map { TagsUtils.showTagTranslated($0) }
                .joined(separator: ", ")
        }
        
        // (D) Disponibilités
        let userAvailability = user.availability ?? [:]  // [String: [String]]
        let availabilityDisplay: String
        if userAvailability.isEmpty {
            availabilityDisplay = "no_data_available".localized
        } else {
            /*
             Exemple:
             userAvailability = [
               "1": ["09:00-12:00", "14:00-18:00"],
               "3": ["14:00-18:00"]
             ]
             → "Lundi (Matin, Après-midi) • Mercredi (Après-midi)"
            */
            var availabilityParts: [String] = []
            for (dayKey, slots) in userAvailability {
                let dayLabel = dayName(for: dayKey)
                let slotLabels = slots
                    .map { timeSlotName(for: $0) }
                    .joined(separator: ", ")
                availabilityParts.append("\(dayLabel) (\(slotLabels))")
            }
            availabilityDisplay = availabilityParts.joined(separator: " • ")
        }
        
        // --------------------------------------------------
        // SECTION : PRÉFÉRENCES
        // --------------------------------------------------
        let preferencesSectionTitle = isMe
            ? "preferences_section_title".localized // "Mes préférences"
            : "preferences_section_title_others".localized // "Ses préférences"
        tableDTO.append(.section(title: preferencesSectionTitle))
        
        // a) Centres d'intérêt
        let interestsTitle = isMe
            ? "preferences_interest_title".localized    // "Mes centres d'intérêt"
            : "preferences_interest_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_interest",
            title: interestsTitle,
            subtitle: interestsDisplay
        ))
        
        // b) Envies d’agir
        let actionTitle = isMe
            ? "preferences_action_title".localized      // "Mes envies d'agir"
            : "preferences_action_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_action",
            title: actionTitle,
            subtitle: involvementsDisplay
        ))
        
        // c) Catégories d’entraide
        let categoriesTitle = isMe
            ? "preferences_action_categories_title".localized
            : "preferences_action_categories_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_action_category",
            title: categoriesTitle,
            subtitle: concernsDisplay
        ))
        
        // d) Disponibilités
        let availabilityTitle = isMe
            ? "preferences_availability_title".localized
            : "preferences_availability_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_disponibility",
            title: availabilityTitle,
            subtitle: availabilityDisplay
        ))
        
        // --------------------------------------------------
        // SECTION : PARAMÈTRES (si c’est mon profil)
        // --------------------------------------------------
        if isMe {
            tableDTO.append(.section(title: "settings_section_title".localized)) // "Paramètres"
            
            // 1) Langue
            let preferredLanguage = LanguageManager.loadLanguageFromPreferences()

            tableDTO.append(.standard(
                img: "ic_profil_full_language",
                title: "settings_language_title".localized, // "Langue"
                subtitle: getLocalizedKey(for: preferredLanguage)
            ))
            
            // Gestion du sous-titre des notifications
            let notifSubtitle: String
            if activated_notif.isEmpty {
                notifSubtitle = "settings_notifications_subtitle_none".localized
            } else {
                notifSubtitle = String(format: "settings_notifications_subtitle".localized, activated_notif.joined(separator: ", "))
            }

            // Gestion du sous-titre des utilisateurs bloqués
            let blockedUsersSubtitle: String
            if numberOfBlocked == 0 {
                blockedUsersSubtitle = "settings_unblock_contacts_subtitle_none".localized
            } else {
                blockedUsersSubtitle = String.localizedStringWithFormat(
                    numberOfBlocked == 1 ? "settings_unblock_contacts_subtitle".localized : "settings_unblock_contacts_subtitle_plural".localized,
                    numberOfBlocked
                )
            }
            
            // 2) Notifications
            tableDTO.append(.standard(
                img: "ic_profil_full_notif",
                title: "settings_notifications_title".localized, // "Notifications"
                subtitle: notifSubtitle
            ))
            
            // 3) Débloquer des contacts
            tableDTO.append(.standard(
                img: "ic_profil_full_block_people",
                title: "settings_unblock_contacts_title".localized, // "Débloquer des contacts"
                subtitle: blockedUsersSubtitle
            ))
            
            // 4) Partager une idée
            tableDTO.append(.standard(
                img: "ic_profil_full_suggest",
                title: "settings_feedback_title".localized, // "Partager une idée"
                subtitle: ""
            ))
            
            // 5) Partager l'application
            tableDTO.append(.standard(
                img: "ic_profil_full_suggest",
                title: "settings_share_title".localized, // "Partager l'application"
                subtitle: ""
            ))
            
            // 6) Changer de mot de passe
            tableDTO.append(.standard(
                img: "ic_profil_full_mdp",
                title: "settings_password_title".localized, // "Changer de mot de passe"
                subtitle: ""
            ))
            
            // 7) Se déconnecter
            tableDTO.append(.standard(
                img: "ic_profil_full_log_out",
                title: "logout_button".localized, // "Se déconnecter"
                subtitle: ""
            ))
            
            // 8) Supprimer mon compte
            tableDTO.append(.standard(
                img: "ic_profil_full_suppress_account",
                title: "delete_account_button".localized, // "Supprimer mon compte"
                subtitle: ""
            ))
        }
        
        // On recharge le tableau
        ui_table_view.reloadData()
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ProfilFullViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let dto = tableDTO[indexPath.row]
        
        switch dto {
        case .header(let user):
            if let cell = tableView.dequeueReusableCell(withIdentifier: HeaderProfilFullCell.identifier) as? HeaderProfilFullCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(user: user)
                return cell
            }
            
        case .mainUserActivity(let user):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MainStatUserCell") as? MainStatUserCell {
                cell.selectionStyle = .none
                let stats: UserStats = user.stats ?? UserStats()
                cell.populateCell(
                    isMe: true,
                    neighborhoodsCount: stats.neighborhoodsCount,
                    outingsCount: stats.outingsCount ?? -1,
                    myDate: user.creationDate
                )
                return cell
            }
            
        case .section(let title):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSectionCell") as? ProfileSectionCell {
                cell.selectionStyle = .none
                cell.configure(title: title)
                return cell
            }
            
        case .standard(let img, let title, let subtitle):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileFullStandardCell") as? ProfileFullStandardCell {
                cell.selectionStyle = .none
                // On laisse subtitle vide, selon la demande
                cell.configure(image: img, title: title, subtitle: subtitle)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = tableDTO[indexPath.row]
        
        switch selectedItem {
        case .standard(let img, let title, _):
            switch title {
                
            case "preferences_interest_title".localized :
                // Ouvrir l’onboarding en mode "interest"
                openEnhancedOnboarding(mode: .interest)
                    
            case "preferences_action_title".localized :
                // Ouvrir l’onboarding en mode "involvement"
                openEnhancedOnboarding(mode: .involvement)
                    
            case "preferences_action_categories_title".localized :
                // Ouvrir l’onboarding en mode "concern"
                openEnhancedOnboarding(mode: .concern)
                    
            case "preferences_availability_title".localized :
                // Ouvrir l’onboarding en mode "choiceDisponibility"
                openEnhancedOnboarding(mode: .choiceDisponibility)
            case "settings_language_title".localized:
                // Navigation vers le choix de langue
                let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "language") as? ProfileLanguageChooseViewController {
                    vc.delegate = self
                    vc.fromSettings = true
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            case "settings_notifications_title".localized:
                // Navigation vers les paramètres de notifications
                let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "paramsNotifsVC")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            case "settings_help_title".localized:
                // Navigation vers la section d'aide
                let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "paramsHelpVC")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            case "settings_unblock_contacts_title".localized:
                // Navigation vers le déblocage de contacts
                let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "editBlockedVC")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            case "settings_feedback_title".localized:
                // Ouvrir l'URL de suggestion
                
                if let url = URL(string: MENU_SUGGEST_URL) {
                    WebLinkManager.openUrlInApp(url: url, presenterViewController: self)
                }
                
            case "settings_share_title".localized:
                // Partager l'application
                let textShare = String(format: "menu_info_text_share".localized, ENTOURAGE_BITLY_LINK)
                let vc = UIActivityViewController(activityItems: [textShare], applicationActivities: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            case "settings_password_title".localized:
                // Navigation vers le changement de mot de passe
                let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "editpwdNav")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            case "logout_button".localized:
                // Afficher la pop-up de déconnexion
                showPopLogout()
                
            case "delete_account_button".localized:
                // Afficher la pop-up de suppression de compte
                showPopSuppress()
                
            default:
                // Gérer les options spécifiques des préférences si besoin
                if title == "preferences_availability_title".localized ||
                   title == "preferences_interest_title".localized ||
                   title == "preferences_action_title".localized ||
                   title == "preferences_action_categories_title".localized {
                    print("Action non définie pour: \(title)")
                }
                break
            }

        default:
            // Aucune action pour les autres types d’éléments (header, section, etc.)
            break
        }
    }

}

// MARK: - UIScrollViewDelegate (réduction photo de profil au scroll)
extension ProfilFullViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // -- Image de profil (existant) --
        let newHeightProfile = max(profileImageMaxHeight - offsetY, profileImageMinHeight)
        let ratioProfile = newHeightProfile / profileImageMaxHeight
        
        img_profile.transform = CGAffineTransform(scaleX: ratioProfile, y: ratioProfile)
        img_profile.alpha = ratioProfile
        
        // -- Bouton "modifier" (NOUVEAU) --
        // Même logique : on calcule une "nouvelle hauteur" et on en déduit un ratio.
        // Ex. on part d’un max à 30 (modifyButtonMaxHeight).
        let newHeightModify = max(modifyButtonMaxHeight - offsetY, 0)
        let ratioModify = newHeightModify / modifyButtonMaxHeight
        
        // Application de la transformation et éventuellement du "fade"
        ui_view_image_modify.transform = CGAffineTransform(scaleX: ratioModify, y: ratioModify)
        ui_view_image_modify.alpha = ratioModify
        
        // -- Ajustement du top de la tableView (existant) --
        let newTopConstraint = max(tableViewTopMin, tableViewTopMax - offsetY)
        constraint_table_view_top.constant = newTopConstraint

        // Forcer la mise à jour du layout
        self.view.layoutIfNeeded()
    }

}


extension ProfilFullViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {

    }
    
    func validateRightButton(alertTag:MJAlertTAG) {
        switch alertTag {
        case .Suppress:
            UserService.deleteUserAccount { error in
                if let error = error {
                    let errorMessage = String.init(format: "params_account_not_deleted".localized, error.message)                    
                    return
                }
                NotificationCenter.default.post(name: NSNotification.Name(notificationLoginError), object: self)
            }
        case .Logout:
            NotificationCenter.default.post(name: NSNotification.Name(notificationLoginError), object: self)
        case .None,.AcceptSettings,.AcceptAdd,.welcomeMessage:
            break
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
}

extension ProfilFullViewController:ProfileLanguageCloseDelegate{
    func onDismiss() {
        self.loadData()
    }
}

extension ProfilFullViewController {
    /// Convertit un code de jour ("1" → Lundi, "2" → Mardi, etc.) en texte localisé
    func dayName(for dayKey: String) -> String {
        switch dayKey {
        case "1":
            return "enhanced_onboarding_time_disponibility_day_monday".localized
        case "2":
            return "enhanced_onboarding_time_disponibility_day_tuesday".localized
        case "3":
            return "enhanced_onboarding_time_disponibility_day_wednesday".localized
        case "4":
            return "enhanced_onboarding_time_disponibility_day_thursday".localized
        case "5":
            return "enhanced_onboarding_time_disponibility_day_friday".localized
        case "6":
            return "enhanced_onboarding_time_disponibility_day_saturday".localized
        case "7":
            return "enhanced_onboarding_time_disponibility_day_sunday".localized
        default:
            return dayKey // ou "no_data_available".localized
        }
    }
    
    /// Convertit un créneau ("09:00-12:00" → Matin, etc.) en texte localisé
    func timeSlotName(for slot: String) -> String {
        switch slot {
        case "09:00-12:00":
            return "enhanced_onboarding_time_disponibility_time_morning".localized
        case "14:00-18:00":
            return "enhanced_onboarding_time_disponibility_time_afternoon".localized
        case "18:00-21:00":
            return "enhanced_onboarding_time_disponibility_time_evening".localized
        default:
            return slot
        }
    }
}

extension ProfilFullViewController:HeaderProfilFullCellDelegate{
    func onModifyClick() {
        self.modifyProfile()
    }
}


extension ProfilFullViewController:ImageReUpLoadDelegate{
    func reloadOnImageUpdate() {
        loadData()
    }
}
