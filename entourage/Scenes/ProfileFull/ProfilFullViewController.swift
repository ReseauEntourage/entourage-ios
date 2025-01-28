//
//  ProfilFullViewController.swift
//  entourage
//
//  Created by Clement entourage on 09/01/2025.
//

import UIKit

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
    
    
    // VARIABLE
    var tableDTO = [ProfileFullDTO]()
    var user: User?
    var isMe: Bool = true
    
    let profileImageMaxHeight: CGFloat = 120
    let profileImageMinHeight: CGFloat = 0
    let tableViewTopMax: CGFloat = 100
    let tableViewTopMin: CGFloat = 60
    
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
        
        // Arrondi et bordure blanche sur l’image de profil
        img_profile.layer.cornerRadius = img_profile.frame.width / 2
        img_profile.layer.borderWidth = 1
        img_profile.layer.borderColor = UIColor.white.cgColor
        img_profile.clipsToBounds = true
        
        // Ajout d’un geste pour fermer la vue sur le bouton back
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackButtonTap))
        btn_back.isUserInteractionEnabled = true
        btn_back.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleBackButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadImage()
        loadDTO()
    }
    
    func loadImage(){
        if let url = URL(string: user?.avatarURL ?? ""){
            img_profile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
    }
    
    /// Charge les lignes du tableau (sans sous-titres, line by line)
    func loadDTO() {
        tableDTO.removeAll()
        
        guard let user = user else { return }
        
        // 1) Header
        tableDTO.append(.header(user: user))
        
        // 2) Activité principale
        tableDTO.append(.mainUserActivity(user: user))
        
        // --------------------------------------------------
        // SECTION : Préférences
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
            subtitle: ""
        ))
        
        // b) Envies d’agir
        let actionTitle = isMe
            ? "preferences_action_title".localized      // "Mes envies d'agir"
            : "preferences_action_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_action",
            title: actionTitle,
            subtitle: ""
        ))
        
        // c) Catégories d’entraide
        let categoriesTitle = isMe
            ? "preferences_action_categories_title".localized
            : "preferences_action_categories_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_action_category",
            title: categoriesTitle,
            subtitle: ""
        ))
        
        // d) Disponibilités
        let availabilityTitle = isMe
            ? "preferences_availability_title".localized
            : "preferences_availability_title_others".localized
        tableDTO.append(.standard(
            img: "ic_profil_full_disponibility",
            title: availabilityTitle,
            subtitle: ""
        ))
        
        // --------------------------------------------------
        // SECTION : Paramètres (si c’est mon profil)
        // --------------------------------------------------
        if isMe {
            tableDTO.append(.section(title: "settings_section_title".localized)) // "Paramètres"
            
            // 1) Langue
            tableDTO.append(.standard(
                img: "ic_profil_full_language",
                title: "settings_language_title".localized, // "Langue"
                subtitle: ""
            ))
            
            // 2) Notifications
            tableDTO.append(.standard(
                img: "ic_profil_full_notif",
                title: "settings_notifications_title".localized, // "Notifications"
                subtitle: ""
            ))
            
            // 3) Débloquer des contacts
            tableDTO.append(.standard(
                img: "ic_profil_full_block_people",
                title: "settings_unblock_contacts_title".localized, // "Débloquer des contacts"
                subtitle: ""
            ))
            
            // 4) Partager une idée
            tableDTO.append(.standard(
                img: "ic_profil_full_suggest",
                title: "settings_feedback_title".localized, // "Partager une idée"
                subtitle: ""
            ))
            
            // 5) Partager l'application
            // ATTENTION : pas d’icône 'ic_profil_full_share' dans la liste fournie,
            // on peut réutiliser 'ic_profil_full_suggest' ou un autre au besoin.
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
}

// MARK: - UIScrollViewDelegate (réduction photo de profil au scroll)
extension ProfilFullViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let newHeight = max(profileImageMaxHeight - offsetY, profileImageMinHeight)
        
        // Calcul d'une nouvelle valeur pour la contrainte
        let newTopConstraint = max(tableViewTopMin, tableViewTopMax - offsetY)
        
        UIView.animate(withDuration: 0.1, animations: {
            // Réduction de l’image
            self.img_profile.transform = CGAffineTransform(
                scaleX: newHeight / self.profileImageMaxHeight,
                y: newHeight / self.profileImageMaxHeight
            )
            self.img_profile.alpha = newHeight / self.profileImageMaxHeight
            
            // Mise à jour de la contrainte de la TableView
            self.constraint_table_view_top.constant = newTopConstraint
            
            // Forcer la mise à jour du layout
            self.view.layoutIfNeeded()
        })
    }
}

