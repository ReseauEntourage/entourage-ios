import Foundation
import UIKit

protocol CellMainFilterDelegate: AnyObject {
    func didUpdateText(text: String)
    func didClickButton()
    func didChangeFocus(hasFocus: Bool)
}

enum CellMainFilterMod {
    case group
    case event
    case action
}

class CellMainFilter: UITableViewCell, UITextFieldDelegate {
    
    // Outlet
    @IBOutlet weak var ui_textfield: UITextField!
    @IBOutlet weak var ui_view_button: UIView!
    @IBOutlet weak var ui_label_number_filter: UILabel!
    
    @IBOutlet weak var ui_contrainst_width_button: NSLayoutConstraint!
    // Variable
    var haveFilter = false {
        didSet {
            updateViewButtonAppearance()
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
        // Ajout de la bordure grise
        ui_textfield.delegate = self
        ui_view_button.layer.borderWidth = 1
        ui_view_button.layer.borderColor = UIColor.appGreyOff.cgColor
        updateViewButtonAppearance()
        ui_textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTextFieldIcons()
    }
    
    private func setupTextFieldIcons() {
        // Setup left view with arrow button
        let arrowButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            arrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        arrowButton.tintColor = UIColor.appOrange
        arrowButton.addTarget(self, action: #selector(closeTextField), for: .touchUpInside)
        arrowButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Add padding
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        leftPaddingView.addSubview(arrowButton)
        arrowButton.center = leftPaddingView.center
        ui_textfield.leftView = leftPaddingView
        
        // Setup right view with cross button
        let crossButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            crossButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        crossButton.tintColor = UIColor.appOrange
        crossButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        crossButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Add padding
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rightPaddingView.addSubview(crossButton)
        crossButton.center = rightPaddingView.center
        ui_textfield.rightView = rightPaddingView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ui_textfield.leftViewMode = .always
        ui_textfield.rightViewMode = .always
        delegate?.didChangeFocus(hasFocus: true) // Notifier le delegate que le focus est pris
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        ui_textfield.leftViewMode = .never
        ui_textfield.rightViewMode = .never
        delegate?.didChangeFocus(hasFocus: false) // Notifier le delegate que le focus est quitté
    }
    
    @objc private func closeTextField() {
        ui_textfield.resignFirstResponder()
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
    
    private func updateViewButtonAppearance() {
        // Mise à jour de la couleur de fond en fonction de l'état de sélection
        if haveFilter {
            ui_view_button.backgroundColor = UIColor.appBeige // Assurez-vous que appColor est défini dans votre Asset Catalog
        } else {
            ui_view_button.backgroundColor = UIColor.white
        }
    }
    
    func configure(selected: Bool, numberOfFilter: Int, mod: CellMainFilterMod, isSearching: Bool) {
        self.mod = mod
        self.haveFilter = selected
        self.ui_label_number_filter.text = String(numberOfFilter)
        self.ui_label_number_filter.isHidden = !selected

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
    
    @IBAction func onTouchFilter(_ sender: Any) {
        // Mise à jour de l'état de sélection
        haveFilter.toggle()
        delegate?.didClickButton()
    }
}

// Extension pour gérer le UITextFieldDelegate

extension UITextField {
    func setPlaceholder(text: String, font: UIFont) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: font
        ]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
}
