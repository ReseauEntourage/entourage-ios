import UIKit

protocol ConversationStaffWarningDelegate: AnyObject {
    func didTapCloseWarning()
}

class ConversationStaffWarningView: UIView, UITextViewDelegate {

    weak var delegate: ConversationStaffWarningDelegate?

    private let backgroundView = UIView()
    private let messageTextView = UITextView()
    private let closeButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .clear

        backgroundView.backgroundColor = .appBeige
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backgroundView)

        messageTextView.backgroundColor = .clear
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.delegate = self
        messageTextView.textAlignment = .left
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        
        messageTextView.linkTextAttributes = [
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        backgroundView.addSubview(messageTextView)

        // MODIFICATION : On réduit la taille du symbole (pointSize: 13) pour qu'il soit moins "gros" visuellement
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let closeImage = UIImage(systemName: "xmark")?.withConfiguration(symbolConfig)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .appOrange
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            messageTextView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            messageTextView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            messageTextView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16),

            // MODIFICATION : On l'aligne en haut à droite plutôt qu'au centre
            closeButton.leadingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: 8),
            closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12), // Alignement en haut
            closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -12),
            
            // On garde une bonne zone de tap (30x30) même si l'icône dedans est plus petite
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        setupText()
    }

    private func setupText() {
        let text = "conversation_staff_warning_message".localized
        let customFont = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: customFont,
            .foregroundColor: UIColor.black
        ])

        // Find ranges
        let nsText = text as NSString
        let range15 = nsText.range(of: "15")
        let range18 = nsText.range(of: "18")
        let range115 = nsText.range(of: "115")
        let rangeGroupe = nsText.range(of: "conversation_staff_warning_group_link".localized)

        if range15.location != NSNotFound {
            attributedString.addAttribute(.link, value: "tel://15", range: range15)
        }
        if range18.location != NSNotFound {
            attributedString.addAttribute(.link, value: "tel://18", range: range18)
        }
        if range115.location != NSNotFound {
            attributedString.addAttribute(.link, value: "tel://115", range: range115)
        }
        if rangeGroupe.location != NSNotFound {
            attributedString.addAttribute(.link, value: "entourage://groupe", range: rangeGroupe)
        }

        messageTextView.attributedText = attributedString
    }

    @objc private func closeTapped() {
        delegate?.didTapCloseWarning()
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "tel" {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            return false
        } else if URL.scheme == "entourage" && URL.host == "groupe" {
            NeighborhoodService.getDefaultGroup { group, error in
                DispatchQueue.main.async {
                    if let group = group {
                        DeepLinkManager.showNeighborhoodDetail(id: group.uid)
                    }
                }
            }
            return false
        }
        return true
    }
}
