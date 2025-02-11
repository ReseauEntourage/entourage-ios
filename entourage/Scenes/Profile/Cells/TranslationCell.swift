import UIKit

class TranslationCell: UITableViewCell {
    
    // OUTLETS
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch!
    
    // VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    var onSwitchValueChanged: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configuration de l'intitulé
        ui_title.text = "translation_bottom_fragment_title".localized
        ui_title.setFontBody(size: 15)
        
        // Configuration de l'état du switch basé sur UserDefaults
        ui_switch.isOn = getCookieValue()
        
        // Ajout d'un écouteur sur le switch
        ui_switch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        setCookieValue(value: sender.isOn)
        onSwitchValueChanged?(sender.isOn)
    }
    
    // Fonction pour obtenir la valeur du cookie
    func getCookieValue() -> Bool {
        if UserDefaults.standard.object(forKey: "isTranslatedByDefault") == nil {
            UserDefaults.standard.set(true, forKey: "isTranslatedByDefault")
        }
        return UserDefaults.standard.bool(forKey: "isTranslatedByDefault")
    }

    // Fonction pour définir la valeur du cookie
    func setCookieValue(value: Bool) {
        UserDefaults.standard.set(value, forKey: "isTranslatedByDefault")
    }
}
