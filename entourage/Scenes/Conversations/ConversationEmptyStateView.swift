import UIKit

final class ConversationEmptyStateView: UIView {

    var onChipSelected: ((String) -> Void)?

    private let chipData: [(label: String, draft: String)] = [
        (
            label: "messaging_empty_chip_bonjour".localized,
            draft: "messaging_empty_draft_bonjour".localized
        ),
        (
            label: "messaging_empty_chip_main".localized,
            draft: "messaging_empty_draft_main".localized
        ),
        (
            label: "messaging_empty_chip_question".localized,
            draft: "messaging_empty_draft_question".localized
        ),
        (
            label: "messaging_empty_chip_evenement".localized,
            draft: "messaging_empty_draft_evenement".localized
        )
    ]

    // #FEEAE3 — light orange circle background
    private static let iconBgColor = UIColor(red: 0xFE/255.0, green: 0xEA/255.0, blue: 0xE3/255.0, alpha: 1)
    // #FFD4B2 — chip border at rest
    private static let chipBorderColor = UIColor(red: 0xFF/255.0, green: 0xD4/255.0, blue: 0xB2/255.0, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white

        // ── Icon circle ──────────────────────────────────────────────────────
        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = ConversationEmptyStateView.iconBgColor
        iconCircle.layer.cornerRadius = 40

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .appOrange
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = UIImage(named: "ic_no_message_neighborhood")
        }
        iconCircle.addSubview(iconImageView)

        // ── Title ────────────────────────────────────────────────────────────
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "messaging_empty_state_title".localized
        titleLabel.font = ApplicationTheme.getFontQuickSandBold(size: 17)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        // ── Subtitle ─────────────────────────────────────────────────────────
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "messaging_empty_state_subtitle".localized
        subtitleLabel.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        subtitleLabel.textColor = .appGris112
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // ── Chips ────────────────────────────────────────────────────────────
        let chipsStack = UIStackView()
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsStack.axis = .vertical
        chipsStack.spacing = 8
        chipsStack.alignment = .center

        for (index, item) in chipData.enumerated() {
            chipsStack.addArrangedSubview(makeChipButton(title: item.label, tag: index))
        }

        // ── Main vertical stack ───────────────────────────────────────────────
        let contentStack = UIStackView(arrangedSubviews: [iconCircle, titleLabel, subtitleLabel, chipsStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.setCustomSpacing(20, after: iconCircle)
        contentStack.setCustomSpacing(8, after: titleLabel)
        contentStack.setCustomSpacing(24, after: subtitleLabel)

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            // Icon circle: 80×80
            iconCircle.widthAnchor.constraint(equalToConstant: 80),
            iconCircle.heightAnchor.constraint(equalToConstant: 80),
            // Icon image: 36×36 centered in circle
            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            // Main stack: centered vertically, padded horizontally
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }

    private func makeChipButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = ApplicationTheme.getFontNunitoSemiBold(size: 13)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = ConversationEmptyStateView.chipBorderColor.cgColor
        btn.backgroundColor = .white
        btn.contentEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
        btn.tag = tag
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(chipPressed(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(chipReleased(_:)), for: [.touchUpOutside, .touchCancel])
        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        animateChip(sender, highlighted: false)
        onChipSelected?(chipData[sender.tag].draft)
        isHidden = true
    }

    @objc private func chipPressed(_ sender: UIButton) {
        animateChip(sender, highlighted: true)
    }

    @objc private func chipReleased(_ sender: UIButton) {
        animateChip(sender, highlighted: false)
    }

    private func animateChip(_ btn: UIButton, highlighted: Bool) {
        UIView.animate(withDuration: 0.15) {
            btn.backgroundColor = highlighted ? ConversationEmptyStateView.iconBgColor : .white
            btn.layer.borderColor = highlighted
                ? UIColor.appOrange.cgColor
                : ConversationEmptyStateView.chipBorderColor.cgColor
            btn.setTitleColor(highlighted ? UIColor.appOrange : .black, for: .normal)
        }
    }
}
