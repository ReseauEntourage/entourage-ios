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
    case languageCell(lang:String, isSelected:Bool)
    case validateButton
}

class ProfileLanguageChooseViewController:UIViewController{
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_iv_cross: UIImageView!
    @IBOutlet weak var ui_table_view: UITableView!
    
    var tableDTO = [LanguageTableDTO]()
    var lastSelectedIndexPath: IndexPath?
    var delegate:ProfileLanguageCloseDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ui_label_title.text = "onboarding_lang_select".localized
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: LanguageCell.identifier, bundle: nil), forCellReuseIdentifier: LanguageCell.identifier)
        ui_table_view.register(UINib(nibName: LangValidateButton.identifier, bundle: nil), forCellReuseIdentifier: LangValidateButton.identifier)
        fillDTO()
        ui_iv_cross.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked))
        ui_iv_cross.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func fillDTO(){
        tableDTO.removeAll()
        let preferredLanguage = LanguageManager.loadLanguageFromPreferences()
        let languages = ["fr", "en", "uk", "es", "de", "ro", "pl","ar"]
        for lang in languages {
            let isSelected = lang == preferredLanguage
            tableDTO.append(.languageCell(lang: lang, isSelected: isSelected))
            if isSelected {
                lastSelectedIndexPath = IndexPath(row: tableDTO.count - 1, section: 0)
            }
        }
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
                }
            }
            dismiss(animated: true) {
                self.delegate?.onDismiss()
            }
        }
        lastSelectedIndexPath = indexPath
        ui_table_view.reloadData()
        self.ui_label_title.text = "onboarding_lang_select".localized
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProfileLanguageChooseViewController:OnValidateButtonClickedDelegate{
    func onClickedValidate() {
        // Sauvegarder la langue sélectionnée lors du clic sur le bouton de validation
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
            }
        }
        self.dismiss(animated: true) {
            self.delegate?.onDismiss()
        }
    }
}
