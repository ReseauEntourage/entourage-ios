import Foundation
import UIKit

class ProfileTranslationViewController: UIViewController {
    
    @IBOutlet weak var ui_label_language: UILabel!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var ic_cross: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialisation du label
        ui_label_language.text = "onboarding_lang_select".localized

        // Configuration du switch basé sur le cookie
        `switch`.isOn = getCookieValue()

        // Configuration du UITapGestureRecognizer pour ic_cross
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeModal))
        ic_cross.isUserInteractionEnabled = true
        ic_cross.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func onValidateClick(_ sender: Any) {
        // Enregistrement de la nouvelle valeur du switch dans le cookie
        setCookieValue(value: `switch`.isOn)
        
        // Fermeture de la fenêtre
        closeModal()
    }
    
    @objc func closeModal() {
        // Fermeture de la vue modale
        dismiss(animated: true, completion: nil)
    }

    // Fonction pour obtenir la valeur du cookie (à adapter selon ton implémentation)
    func getCookieValue() -> Bool {
        if UserDefaults.standard.object(forKey: "isTranslatedByDefault") == nil {
            // Si non, on définit la valeur par défaut à true
            UserDefaults.standard.set(true, forKey: "isTranslatedByDefault")
        }
        // Puis on retourne la valeur
        return UserDefaults.standard.bool(forKey: "isTranslatedByDefault")
    }

    // Fonction pour définir la valeur du cookie (à adapter selon ton implémentation)
    func setCookieValue(value: Bool) {
        // Ici, enregistre la valeur dans le cookie "isTranslatedByDefault"
        // Remplace ceci par ton code de gestion de cookies
        UserDefaults.standard.set(value, forKey: "isTranslatedByDefault")
    }
}
