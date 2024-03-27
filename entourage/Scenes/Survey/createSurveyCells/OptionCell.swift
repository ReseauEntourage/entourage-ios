import UIKit

protocol OptionCellDelegate {
    func onOptionChanged(option: String, numberInList:Int)
}

class OptionCell: UITableViewCell, UITextViewDelegate {
    
    // OUTLET
    @IBOutlet weak var ui_text_view: UITextView!
    var delegate: OptionCellDelegate? = nil
    var numberInList = 0
    class var identifier: String {
        return String(describing: self)
    }
    // Placeholder Label
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "+ Ajouter votre option"
        label.font = UIFont(name: "NunitoSans-Italic", size: 16) // Ajuste la taille de la police si nécessaire
        label.textColor = UIColor.gray
        label.isHidden = true
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTextView()
    }
    
    private func setupTextView() {
        ui_text_view.delegate = self
        ui_text_view.font = UIFont(name: "NunitoSans-Regular", size: 16)
        ui_text_view.autocapitalizationType = .sentences
        addUnderlineToTextView()
        
        ui_text_view.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (ui_text_view.font?.pointSize ?? 16) / 2)
        placeholderLabel.frame.size = CGSize(width: ui_text_view.bounds.width - 10, height: 20)
        placeholderLabel.isHidden = ui_text_view.text.count > 0
        addToolbarToKeyboard()
    }
    
    func addUnderlineToTextView() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: ui_text_view.frame.height - 1, width: ui_text_view.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        ui_text_view.layer.addSublayer(bottomLine)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            delegate?.onOptionChanged(option: textView.text, numberInList: self.numberInList)
        } else {
            placeholderLabel.isHidden = false
        }
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func configure(numberInList:Int) {
        self.numberInList = numberInList
    }
    
    private func addToolbarToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Fermer", style: .done, target: self, action: #selector(dismissKeyboard))

        toolbar.setItems([flexSpace, doneButton], animated: true)
        ui_text_view.inputAccessoryView = toolbar
    }
    @objc private func dismissKeyboard() {
        ui_text_view.resignFirstResponder()
    }
}
