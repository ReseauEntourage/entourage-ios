//
//  OnboardingLanguageStoryBoard.swift
//  entourage
//
//  Created by Clement entourage on 30/10/2023.
//

import Foundation
import UIKit

class OnboardingLanguageStoryBoard:UIViewController{
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_label_select_language: UILabel!
    @IBOutlet weak var ui_button_next: UIButton!
    
    var tableDTO = [LanguageTableDTO]()
    var lastSelectedIndexPath: IndexPath?

    override func viewDidLoad() {
        configureUI()
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: LanguageCell.identifier, bundle: nil), forCellReuseIdentifier: LanguageCell.identifier)
        ui_table_view.register(UINib(nibName: LangValidateButton.identifier, bundle: nil), forCellReuseIdentifier: LangValidateButton.identifier)
        fillDTO()

    }
    func configureUI(){
        /*"onboarding_lang_bienvenue" = "Welcome !";
         "onboarding_lang_select" = "Select your language";
         "onboarding_lang_suivant" = "Next";*/
        self.ui_label_title.text = "onboarding_lang_bienvenue".localized
        self.ui_label_select_language.text = "onboarding_lang_select".localized
        self.ui_button_next.setTitle("onboarding_lang_suivant".localized, for: .normal)
        self.ui_button_next.addTarget(self, action: #selector(onNextClicked), for: .touchUpInside)
    }
    
    func fillDTO(){
        tableDTO.removeAll()
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        let languages = ["fr", "en","uk", "es", "de", "ro", "pl"]
        for lang in languages {
            let isSelected = lang == preferredLanguage
            tableDTO.append(.languageCell(lang: lang, isSelected: isSelected))
            if isSelected {
                lastSelectedIndexPath = IndexPath(row: tableDTO.count - 1, section: 0)
            }
        }
        ui_table_view.reloadData()
    }
    
    @objc func onNextClicked(){
        let sb = UIStoryboard.init(name: StoryboardName.intro, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
}

extension OnboardingLanguageStoryBoard:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
            
        case .languageCell(lang: let lang, isSelected: let isSelected):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell{
                cell.selectionStyle = .none
                cell.configure(lang: lang, isSelected: isSelected)
                return cell
            }
            return UITableViewCell()
        case .validateButton:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Désélectionner la précédente langue choisie
        tableDTO = tableDTO.map { dto in
            switch dto {
            case .languageCell(let lang, _):
                return .languageCell(lang: lang, isSelected: false)
            case .validateButton:
                return .validateButton
            }
        }
        // Sélectionner la nouvelle langue
        switch tableDTO[indexPath.row] {
        case .languageCell(let lang, _):
            tableDTO[indexPath.row] = .languageCell(lang: lang, isSelected: true)
            // Sauvegarder la langue dans les préférences
            LanguageManager.saveLanguageToPreferences(languageCode: lang)
            // Changer la langue de l'application
            LanguageManager.setLocale(langCode: lang)
        case .validateButton:
            print("never happen")
        }
        configureUI()
        ui_table_view.reloadData()
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
