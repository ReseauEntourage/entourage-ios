//
//  InterestsCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 31/05/2024.
//

import Foundation
import UIKit

class InterestsCollectionViewCell: UICollectionViewCell {
    
    // Outlets
    @IBOutlet weak var ui_image_choice: UIImageView!
    @IBOutlet weak var ui_image_check: UIImageView!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    @IBOutlet weak var ui_container_view: UIView!
    
    // Mapping généré dynamiquement pour éviter le crash "Duplicate keys"
    private lazy var subtitlesMapping: [String: String] = {
        var map = [String: String]()
        
        // Fonction interne pour insérer les traductions en toute sécurité
        func addMapping(apiKeys: [String], locKey: String, subKey: String) {
            let subtitle = NSLocalizedString(subKey, comment: "")
            let translatedTitle = NSLocalizedString(locKey, comment: "")
            
            // Cette façon d'assigner écrase les doublons au lieu de faire crasher Swift
            map[translatedTitle] = subtitle
            for key in apiKeys {
                map[key] = subtitle
            }
        }
        
        // Ajout des correspondances (Clés API + Traductions)
        addMapping(apiKeys: ["sport", "Sport", "Sports"], locKey: "enhanced_onboarding_interest_sport", subKey: "interest_sport_subtitle")
        addMapping(apiKeys: ["animaux", "Animaux"], locKey: "enhanced_onboarding_interest_animals", subKey: "interest_animaux_subtitle")
        addMapping(apiKeys: ["marauding", "Maraudes sociales"], locKey: "enhanced_onboarding_interest_social_marauding", subKey: "interest_marauding_subtitle")
        addMapping(apiKeys: ["bien-etre", "Bien-être"], locKey: "enhanced_onboarding_interest_wellbeing", subKey: "interest_bien_etre_subtitle")
        addMapping(apiKeys: ["cuisine", "Cuisine"], locKey: "enhanced_onboarding_interest_cooking", subKey: "interest_cuisine_subtitle")
        addMapping(apiKeys: ["culture", "Art & Culture"], locKey: "enhanced_onboarding_interest_art_culture", subKey: "interest_culture_subtitle")
        addMapping(apiKeys: ["nature", "Nature"], locKey: "enhanced_onboarding_interest_nature", subKey: "interest_nature_subtitle")
        addMapping(apiKeys: ["jeux", "Jeux"], locKey: "enhanced_onboarding_interest_games", subKey: "interest_jeux_subtitle")
        addMapping(apiKeys: ["activites", "Activités manuelles", "Activités Manuelles"], locKey: "enhanced_onboarding_interest_manual_activities", subKey: "interest_activites_subtitle")
        addMapping(apiKeys: ["other", "Autre"], locKey: "enhanced_onboarding_interest_other", subKey: "interest_other_subtitle")
        
        return map
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ui_container_view.layer.borderWidth = 1
        self.ui_image_choice.backgroundColor = UIColor.appBeige
        self.ui_image_choice.layer.cornerRadius = 30
    }
    
    func configure(choice: OnboardingChoice, isSelected: Bool) {
        print("choice : ", choice.title)
        
        // 1. Assigner le titre reçu
        self.ui_title_label.text = choice.title

        // 2. Récupérer le sous-titre de façon sécurisée
        let cleanTitle = choice.title.trimmingCharacters(in: .whitespaces)
        let lowercasedTitle = cleanTitle.lowercased()
        
        let sub = choice.subtitle
            ?? subtitlesMapping[cleanTitle]
            ?? subtitlesMapping[lowercasedTitle]
            ?? ""

        // 3. Gérer l'affichage ou le masquage du sous-titre
        if !sub.trimmingCharacters(in: .whitespaces).isEmpty {
            self.ui_subtitle_label?.text = sub
            self.ui_subtitle_label?.isHidden = false
        } else {
            self.ui_subtitle_label?.isHidden = true
            self.ui_subtitle_label?.text = ""
        }

        // 4. Style graphique (images et bordures selon la sélection)
        self.ui_image_choice.image = UIImage(named: choice.img)
        
        if isSelected {
            ui_image_check.image = UIImage(named: "ic_onboarding_checked")
            self.ui_container_view.layer.borderColor = UIColor.appOrangeLight.cgColor
            self.ui_container_view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 235/255, alpha: 0.5)
        } else {
            ui_image_check.image = UIImage(named: "ic_onboarding_unchecked")
            self.ui_container_view.layer.borderColor = UIColor.appGrey151.cgColor
            self.ui_container_view.backgroundColor = .clear
        }
    }
}
