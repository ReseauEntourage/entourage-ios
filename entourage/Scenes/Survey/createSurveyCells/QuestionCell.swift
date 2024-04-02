import UIKit

protocol QuestionCellDelegate {
    func onValidateQuestion(title: String)
    func textViewDidChangeInCell(_ cell: QuestionCell)

}

class QuestionCell: UITableViewCell, UITextViewDelegate {
    
    // OUTLETS
    @IBOutlet weak var lui_label_title: UILabel!
    @IBOutlet weak var ui_text_view: UITextView!
    var delegate: QuestionCellDelegate? = nil
    class var identifier: String {
        return String(describing: self)
    }
    // Placeholder Label
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Poser votre question"
        label.font = UIFont(name: "NunitoSans-Italic", size: 15)
        label.textColor = UIColor.gray
        label.isHidden = true
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configuration initiale
        ui_text_view.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (ui_text_view.font?.pointSize)! / 2)
        placeholderLabel.frame.size = CGSize(width: ui_text_view.frame.width - 10, height: 20)
        placeholderLabel.isHidden = ui_text_view.text.count > 0
        ui_text_view.isScrollEnabled = false

        ui_text_view.delegate = self
        ui_text_view.font = UIFont(name: "NunitoSans-Regular", size: 15)
        ui_text_view.autocapitalizationType = .sentences
        addToolbarToKeyboard()
    }
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 300
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !textView.text.isEmpty {
            delegate?.onValidateQuestion(title: textView.text)
        } else {
            placeholderLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.textViewDidChangeInCell(self)

    }
    
    func configure() {
        // Configuration supplémentaire si nécessaire
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
