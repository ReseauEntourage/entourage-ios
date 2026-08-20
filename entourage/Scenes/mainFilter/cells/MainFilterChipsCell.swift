import Foundation
import UIKit

struct MainFilterChipItem {
    let id: String
    let title: String
    let iconName: String?
    let accentColor: UIColor
}

enum MainFilterChipsStyle {
    // Independent multi-select toggles, each chip keeps its own accent color when selected.
    case toggle
    // Exclusive single-select, shared accent color, hollow/filled circle indicator.
    case radio
}

protocol MainFilterChipsCellDelegate: AnyObject {
    func mainFilterChipsCell(_ cell: MainFilterChipsCell, didSelect id: String)
}

class MainFilterChipsCell: UITableViewCell {
    static let identifier = "MainFilterChipsCell"

    weak var delegate: MainFilterChipsCellDelegate?

    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(items: [MainFilterChipItem], selectedIds: Set<String>, style: MainFilterChipsStyle) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for item in items {
            let isSelected = selectedIds.contains(item.id)
            let btn = makeChip(item: item, isSelected: isSelected, style: style)
            stackView.addArrangedSubview(btn)
        }

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacer)
    }

    private func makeChip(item: MainFilterChipItem, isSelected: Bool, style: MainFilterChipsStyle) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.accessibilityIdentifier = item.id
        btn.setTitle(item.title, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)

        if style == .radio {
            let symbolName = isSelected ? "largecircle.fill.circle" : "circle"
            btn.setImage(UIImage(systemName: symbolName), for: .normal)
            btn.tintColor = isSelected ? .white : UIColor.appGreyOff
        } else if let iconName = item.iconName {
            btn.setImage(UIImage(named: iconName), for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
        }

        applyStyle(btn, item: item, isSelected: isSelected)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func applyStyle(_ btn: UIButton, item: MainFilterChipItem, isSelected: Bool) {
        if isSelected {
            btn.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
            btn.backgroundColor = item.accentColor
            btn.layer.borderColor = item.accentColor.cgColor
            btn.setTitleColor(.white, for: .normal)
        } else {
            btn.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 14)
            btn.backgroundColor = .white
            btn.layer.borderColor = item.accentColor.cgColor
            btn.setTitleColor(item.accentColor, for: .normal)
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        guard let id = sender.accessibilityIdentifier else { return }
        delegate?.mainFilterChipsCell(self, didSelect: id)
    }
}
