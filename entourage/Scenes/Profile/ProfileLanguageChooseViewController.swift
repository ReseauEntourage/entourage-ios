//
//  ProfileLanguageChooseViewController.swift
//  entourage
//
//  Created by Clement entourage on 26/10/2023.
//

import Foundation
import UIKit

protocol ProfileLanguageCloseDelegate{
    func onDismiss()
}

enum LanguageTableDTO {
    case backArrow
    case title(title:String)
    case languageCell(lang:String, isSelected:Bool)
    case translationCell
    case validateButton
}

class ProfileLanguageChooseViewController:UIViewController{
    
    @IBOutlet weak var ui_table_view: UITableView!
    
    var tableDTO = [LanguageTableDTO]()
    var lastSelectedIndexPath: IndexPath?
    var delegate:ProfileLanguageCloseDelegate?
    var fromSettings = false
    var lang:String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: LanguageCell.identifier, bundle: nil), forCellReuseIdentifier: LanguageCell.identifier)
        ui_table_view.register(UINib(nibName: LangValidateButton.identifier, bundle: nil), forCellReuseIdentifier: LangValidateButton.identifier)
        ui_table_view.register(UINib(nibName: TranslationCell.identifier, bundle: nil), forCellReuseIdentifier: TranslationCell.identifier)
        ui_table_view.register(UINib(nibName: "EnhancedOnboardingTitle", bundle: nil), forCellReuseIdentifier: "titleCell")
        ui_table_view.register(UINib(nibName: "EnhancecOnboardingBackCell", bundle: nil), forCellReuseIdentifier: "enhancecOnboardingBackCell")
        fillDTO()

    }
    
    func showPopChange() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "ok".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "cancell".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "attention_pop_title".localized, message: "language_change_redirect".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)

        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
    
    
    func fillDTO(){
        tableDTO.removeAll()
        tableDTO.append(.backArrow)
        tableDTO.append(.title(title: "Choix de la langue"))
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        let languages = ["fr", "en", "uk", "es", "de", "ro", "pl","ar"]
        for lang in languages {
            let isSelected = lang == preferredLanguage
            tableDTO.append(.languageCell(lang: lang, isSelected: isSelected))
            if isSelected {
                lastSelectedIndexPath = IndexPath(row: tableDTO.count - 1, section: 0)
            }
        }
        tableDTO.append(.title(title: "Traduction"))
        tableDTO.append(.translationCell)
        tableDTO.append(.validateButton)
        ui_table_view.reloadData()
    }
    
    @objc func onCrossClicked(){
        self.dismiss(animated: true) {
        }
    }
}

extension ProfileLanguageChooseViewController:UITableViewDelegate,UITableViewDataSource{
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
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "LangValidateButton") as? LangValidateButton{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure()
                return cell
            }
        case .translationCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "TranslationCell") as? TranslationCell{
                cell.selectionStyle = .none
                return cell
            }
        case .backArrow:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "enhancecOnboardingBackCell", for: indexPath) as? EnhancecOnboardingBackCell else {
                return UITableViewCell()
            }
            cell.configure(isFromSettings: true)
            cell.selectionStyle = .none
            return cell
        case .title(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as? EnhancedOnboardingTitle else {
                return UITableViewCell()
            }
            cell.configure(title: title, subtitle: "")
            cell.selectionStyle = .none
            return cell
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
            case .translationCell:
                return .translationCell
            case .backArrow:
                return .backArrow
            case .title(let title):
                return .title(title:title)
            }
        }
        // Sélectionner la nouvelle langue sans sauvegarde immédiate
        switch tableDTO[indexPath.row] {
        case .languageCell(let lang, _):
            tableDTO[indexPath.row] = .languageCell(lang: lang, isSelected: true)
        case .validateButton:
            // Sauvegarder la langue dans les préférences lors de la validation
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                switch tableDTO[lastSelectedIndexPath.row] {
                case .languageCell(let lang, _):
                    LanguageManager.saveLanguageToPreferences(languageCode: lang)
                    LanguageManager.setLocale(langCode: lang)
                    if let _userId = UserDefaults.currentUser?.sid {
                        UserService.updateLanguage(userId: _userId, lang: lang) { success in
                            print("changed lang to: ", lang)
                        }
                    }
                case .validateButton:
                    break
                case .translationCell:
                    break
                case .backArrow:
                    break
                case .title(title: let title):
                    break
                }
            }
            
        case .translationCell:
            return
        case .backArrow:
            self.dismiss(animated: true) {
            }
        case .title(title: let title):
            break
        }
        lastSelectedIndexPath = indexPath
        ui_table_view.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProfileLanguageChooseViewController:OnValidateButtonClickedDelegate{
    func onCancel() {
        self.dismiss(animated: true){
            
        }
    }
    
    func onClickedValidate() {
        // Sauvegarder la langue sélectionnée lors du clic sur le bouton de validation
        if let lastSelectedIndexPath = lastSelectedIndexPath {
            switch tableDTO[lastSelectedIndexPath.row] {
            case .languageCell(let lang, _):
                self.lang = lang
                self.showPopChange()
            case .validateButton:
                break
            case .translationCell:
                break
            case .backArrow:
                break
            case .title(title: let title):
                break
            }
        }
    }
}

extension ProfileLanguageChooseViewController:MJAlertControllerDelegate{
    func validateLeftButton(alertTag: MJAlertTAG) {

    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        LanguageManager.saveLanguageToPreferences(languageCode: lang)
        LanguageManager.setLocale(langCode: lang)
        if let _userId = UserDefaults.currentUser?.sid {
            UserService.updateLanguage(userId: _userId, lang: lang) { success in
                print("changed lang to: ", self.lang)
            }
        }
    }
    
    
}
