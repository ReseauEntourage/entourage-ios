//
//  OnboardingLanguageStoryBoard.swift
//  entourage
//
//  Created by Clement entourage on 30/10/2023.
//

import Foundation
import UIKit

class OnboardingLanguageStoryBoard: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_label_select_language: UILabel!
    @IBOutlet weak var ui_button_next: UIButton!
    
    var tableDTO = [LanguageTableDTO]()
    var lastSelectedIndexPath: IndexPath?
    var selectedLanguage: String? // Variable pour stocker la langue sélectionnée

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: LanguageCell.identifier, bundle: nil), forCellReuseIdentifier: LanguageCell.identifier)
        ui_table_view.register(UINib(nibName: LangValidateButton.identifier, bundle: nil), forCellReuseIdentifier: LangValidateButton.identifier)
        ui_table_view.register(UINib(nibName: "EnhancedOnboardingTitle", bundle: nil), forCellReuseIdentifier: "titleCell")
        ui_table_view.register(UINib(nibName: "EnhancecOnboardingBackCell", bundle: nil), forCellReuseIdentifier: "enhancecOnboardingBackCell")
        fillDTO()
    }

    func configureUI() {
        self.ui_label_title.text = "onboarding_lang_bienvenue".localized
        self.ui_label_select_language.text = "onboarding_lang_select".localized
        self.ui_button_next.setTitle("onboarding_lang_suivant".localized, for: .normal)
        self.ui_button_next.addTarget(self, action: #selector(onNextClicked), for: .touchUpInside)
        configureOrangeButton(ui_button_next, withTitle: "onboarding_lang_suivant".localized)

    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    func fillDTO() {
        tableDTO.removeAll()
        var preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        if preferredLanguage.isEmpty {
            let systemLocale = Locale.current
            preferredLanguage = systemLocale.identifier // ou systemLocale.languageCode pour juste le code de langue
            LanguageManager.saveLanguageToPreferences(languageCode: preferredLanguage)
        }

        let languages = ["fr", "en", "uk", "es", "de", "ro", "pl", "ar"]
        for lang in languages {
            let isSelected = lang == preferredLanguage
            tableDTO.append(.languageCell(lang: lang, isSelected: isSelected))
            if isSelected {
                lastSelectedIndexPath = IndexPath(row: tableDTO.count - 1, section: 0)
                selectedLanguage = lang // Définir la langue initiale sélectionnée
            }
        }
        ui_table_view.reloadData()
    }
    
    @objc func onNextClicked() {
        // Sauvegarder la langue uniquement lors du clic sur "Suivant"
        if let lang = selectedLanguage {
            LanguageManager.saveLanguageToPreferences(languageCode: lang)
            LanguageManager.setLocale(langCode: lang)
        }
        let sb = UIStoryboard.init(name: StoryboardName.intro, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
}

extension OnboardingLanguageStoryBoard: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row] {
        case .languageCell(lang: let lang, isSelected: let isSelected):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell {
                cell.selectionStyle = .none
                cell.configure(lang: lang, isSelected: isSelected)
                return cell
            }
            return UITableViewCell()
        case .validateButton:
            return UITableViewCell() // Pas besoin de bouton dans ce cas
        case .translationCell:
            return UITableViewCell()
        case .backArrow:
            return UITableViewCell()
        case .title(title: let title):
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Désélectionner la précédente langue choisie
        tableDTO = tableDTO.map { dto in
            switch dto {
            case .languageCell(let lang, _):
                return .languageCell(lang: lang, isSelected: false)
            case .validateButton:
                return .validateButton
            case .translationCell:
                return .translationCell
            case .backArrow:
                return .backArrow
            case .title(let title):
                return .title(title: title)
            }
        }
        // Sélectionner la nouvelle langue sans sauvegarder immédiatement
        switch tableDTO[indexPath.row] {
        case .languageCell(let lang, _):
            tableDTO[indexPath.row] = .languageCell(lang: lang, isSelected: true)
            selectedLanguage = lang // Stocker la langue sélectionnée
        case .validateButton:
            print("never happen")
        case .translationCell:
            print("never happen")
        case .backArrow:
            print("never happen")
        case .title(let title):
            print("never happen")
        }
        configureUI()
        ui_table_view.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
