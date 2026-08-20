import UIKit

protocol AvailabilityGridCellDelegate: AnyObject {
    func availabilityGridCell(_ cell: AvailabilityGridCell, didUpdateAvailability availability: [Int: Set<Int>])
}

// Grid of 7 days × 3 time slots (Matin / Après-midi / Soir).
// Each day independently holds its own set of selected slots.
class AvailabilityGridCell: UITableViewCell {
    static let identifier = "AvailabilityGridCell"

    weak var delegate: AvailabilityGridCellDelegate?

    private let stackView = UIStackView()
    private let dayAbbreviations = [
        "availability_day_mon".localized, "availability_day_tue".localized, "availability_day_wed".localized,
        "availability_day_thu".localized, "availability_day_fri".localized, "availability_day_sat".localized,
        "availability_day_sun".localized
    ]
    private let slotTitles = ["hour_morning".localized, "hour_afternoon".localized, "hour_evening".localized]

    // [dayIndex: Set<slotIndex>]  (0=Lun…6=Dim, 0=Matin 1=AM 2=Soir)
    var availability: [Int: Set<Int>] = [:]

    // chipButtons[dayIndex][slotIndex]
    private var chipButtons: [[UIButton]] = []
    private var dayLabels: [UILabel] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildGrid()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        buildGrid()
    }

    private func buildGrid() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        chipButtons = []
        dayLabels = []

        for dayIndex in 0..<7 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.alignment = .center
            rowStack.distribution = .fill

            let label = UILabel()
            label.text = dayAbbreviations[dayIndex]
            label.font = ApplicationTheme.getFontNunitoRegular(size: 14)
            label.textColor = .black
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.widthAnchor.constraint(equalToConstant: 36).isActive = true
            rowStack.addArrangedSubview(label)
            dayLabels.append(label)

            var rowButtons: [UIButton] = []
            for slotIndex in 0..<3 {
                let btn = makeChip(title: slotTitles[slotIndex], tag: dayIndex * 10 + slotIndex)
                rowStack.addArrangedSubview(btn)
                if slotIndex > 0 {
                    btn.widthAnchor.constraint(equalTo: rowButtons[0].widthAnchor).isActive = true
                }
                rowButtons.append(btn)
            }
            chipButtons.append(rowButtons)
            stackView.addArrangedSubview(rowStack)
        }
    }

    private func makeChip(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.contentHorizontalAlignment = .center
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.appGrey151.cgColor
        btn.backgroundColor = .clear
        btn.tag = tag
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return btn
    }

    func configure(availability: [Int: Set<Int>]) {
        self.availability = availability
        for dayIndex in 0..<7 {
            let hasAny = !(availability[dayIndex]?.isEmpty ?? true)
            dayLabels[dayIndex].font = hasAny
                ? ApplicationTheme.getFontQuickSandBold(size: 14)
                : ApplicationTheme.getFontNunitoRegular(size: 14)
            for slotIndex in 0..<3 {
                let selected = availability[dayIndex]?.contains(slotIndex) ?? false
                applyStyle(chipButtons[dayIndex][slotIndex], isSelected: selected)
            }
        }
    }

    private func applyStyle(_ btn: UIButton, isSelected: Bool) {
        if isSelected {
            btn.layer.borderColor = UIColor.orange.cgColor
            btn.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            btn.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        } else {
            btn.layer.borderColor = UIColor.appGrey151.cgColor
            btn.backgroundColor = .clear
            btn.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        }
    }

    @objc private func chipTapped(_ btn: UIButton) {
        let dayIndex = btn.tag / 10
        let slotIndex = btn.tag % 10

        var slots = availability[dayIndex] ?? []
        if slots.contains(slotIndex) { slots.remove(slotIndex) } else { slots.insert(slotIndex) }

        if slots.isEmpty { availability.removeValue(forKey: dayIndex) }
        else { availability[dayIndex] = slots }

        let isSelected = availability[dayIndex]?.contains(slotIndex) ?? false
        applyStyle(btn, isSelected: isSelected)

        let hasAny = !(availability[dayIndex]?.isEmpty ?? true)
        dayLabels[dayIndex].font = hasAny
            ? ApplicationTheme.getFontQuickSandBold(size: 14)
            : ApplicationTheme.getFontNunitoRegular(size: 14)

        delegate?.availabilityGridCell(self, didUpdateAvailability: availability)
    }
}
