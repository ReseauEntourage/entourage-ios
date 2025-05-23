import Foundation
import UIKit

protocol CellMainFilterDelegate: AnyObject {
    func didUpdateText(text: String)
    func didClickButton()
    func shouldCloseSearch()
}

enum CellMainFilterMod {
    case group
    case event
    case action
}

class CellMainFilter: UITableViewCell, UITextFieldDelegate {
    
    // Outlet
    @IBOutlet weak var ui_textfield: UITextField!
    
    // Variable
    var haveFilter = false {
        didSet {

        }
    }
    class var identifier: String {
        return String(describing: self)
    }
    weak var delegate: CellMainFilterDelegate?
    var mod: CellMainFilterMod = .group
    private var textChangeTimer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        ui_textfield.delegate = self
        ui_textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTextFieldIcons()
        
        // Configurer le clavier pour afficher le bouton "Rechercher"
        ui_textfield.returnKeyType = .search
    }
    
    private func setupTextFieldIcons() {
        let arrowButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            arrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        arrowButton.tintColor = UIColor.appOrange
        arrowButton.addTarget(self, action: #selector(closeTextField), for: .touchUpInside)
        arrowButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        leftPaddingView.addSubview(arrowButton)
        arrowButton.center = leftPaddingView.center
        ui_textfield.leftView = leftPaddingView
        
        let crossButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            crossButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        crossButton.tintColor = UIColor.appOrange
        crossButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        crossButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rightPaddingView.addSubview(crossButton)
        crossButton.center = rightPaddingView.center
        ui_textfield.rightView = rightPaddingView
        ui_textfield.leftViewMode = .always
        ui_textfield.rightViewMode = .always
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Code exécuté lorsque l'édition commence
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Code exécuté lorsque l'édition se termine
    }
    
    @objc private func closeTextField() {
        ui_textfield.text = ""
        delegate?.didUpdateText(text: "")
        delegate?.shouldCloseSearch()
    }
    
    @objc private func clearTextField() {
        ui_textfield.text = ""
        delegate?.didUpdateText(text: "")
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            delegate?.didUpdateText(text: "")
        }
        textChangeTimer?.invalidate()
        textChangeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(notifyTextChange), userInfo: textField.text, repeats: false)
    }
    
    @objc private func notifyTextChange(_ timer: Timer) {
        if let text = timer.userInfo as? String {
            delegate?.didUpdateText(text: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ferme le clavier
        return true
    }
    
    func configure(selected: Bool, numberOfFilter: Int, mod: CellMainFilterMod, isSearching: Bool) {
        self.mod = mod
        self.haveFilter = selected

        let placeholderFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        switch mod {
        case .group:
            self.ui_textfield.setPlaceholder(text: "main_filter_cell_group_placeholder".localized, font: placeholderFont)
        case .event:
            self.ui_textfield.setPlaceholder(text: "main_filter_cell_event_placeholder".localized, font: placeholderFont)
        case .action:
            self.ui_textfield.setPlaceholder(text: "main_filter_cell_action_placeholder".localized, font: placeholderFont)
        }
    }

}

extension UITextField {
    func setPlaceholder(text: String, font: UIFont) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: font
        ]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
}
