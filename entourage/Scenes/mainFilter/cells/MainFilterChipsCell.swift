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
    // Exclusive single-select, shared accent color — selection is shown via fill/border only.
    case radio
}

protocol MainFilterChipsCellDelegate: AnyObject {
    func mainFilterChipsCell(_ cell: MainFilterChipsCell, didSelect id: String)
}

class MainFilterChipsCell: UITableViewCell {
    static let identifier = "MainFilterChipsCell"
    private static let chipIconSize = CGSize(width: 22, height: 22)

    weak var delegate: MainFilterChipsCellDelegate?

    private let scrollView = UIScrollView()
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

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // Chips can outgrow the screen width (e.g. two long labels side by side) — scroll
        // horizontally instead of letting the stack view compress/truncate their titles.
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalTo: stackView.heightAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16)
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
    }

    private func makeChip(item: MainFilterChipItem, isSelected: Bool, style: MainFilterChipsStyle) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.accessibilityIdentifier = item.id
        btn.setTitle(item.title, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        if let iconName = item.iconName {
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            // UIButton derives its image layout rect from the UIImage's own size, not from
            // imageView constraints — some source SVGs have no explicit width/height so their
            // viewBox (e.g. 217x207) becomes the intrinsic size otherwise. Resize the bitmap
            // itself so it matches the other, correctly-sized icons.
            btn.setImage(UIImage(named: iconName)?.resized(to: Self.chipIconSize), for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
        }

        applyStyle(btn, item: item, isSelected: isSelected, style: style)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func applyStyle(_ btn: UIButton, item: MainFilterChipItem, isSelected: Bool, style: MainFilterChipsStyle) {
        if isSelected {
            btn.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
            btn.backgroundColor = item.accentColor
            btn.layer.borderColor = item.accentColor.cgColor
            btn.setTitleColor(.white, for: .normal)
        } else {
            // Radio chips (exclusive choice) stay neutral grey when unselected — only the
            // active choice takes the accent color. Toggle chips keep their accent outline
            // even when unselected, since each one carries its own identity color. The title
            // itself always renders black so unselected chips don't read as disabled.
            let unselectedBorderColor = style == .radio ? UIColor.appGreyOff : item.accentColor
            let unselectedTextColor = style == .radio ? UIColor.black : item.accentColor
            btn.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 14)
            btn.backgroundColor = .white
            btn.layer.borderColor = unselectedBorderColor.cgColor
            btn.setTitleColor(unselectedTextColor, for: .normal)
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        guard let id = sender.accessibilityIdentifier else { return }
        delegate?.mainFilterChipsCell(self, didSelect: id)
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
