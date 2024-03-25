import UIKit

protocol QuestionCellDelegate {
    func onValidateQuestion(title: String)
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
        
        ui_text_view.delegate = self
        ui_text_view.font = UIFont(name: "NunitoSans-Regular", size: 15)
        ui_text_view.autocapitalizationType = .sentences
        
        addUnderlineToTextView()
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
        if !textView.text.isEmpty {
            delegate?.onValidateQuestion(title: textView.text)
        } else {
            placeholderLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func configure() {
        // Configuration supplémentaire si nécessaire
    }
}