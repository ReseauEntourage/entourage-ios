import UIKit

final class Checkbox: UIButton {
    var isChecked: Bool {
        get { isSelected }
        set { isSelected = newValue; updateAccessibility() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        if #available(iOS 13.0, *) {
            let unchecked = UIImage(systemName: "square")
            let checked = UIImage(systemName: "checkmark.square.fill")

            setImage(unchecked, for: .normal)
            setImage(checked, for: .selected)
        }

        contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        addTarget(self, action: #selector(toggleChecked), for: .touchUpInside)

        // Pas de surbrillance orange au clic
        adjustsImageWhenHighlighted = false

        accessibilityTraits.insert(.button)
        accessibilityTraits.insert(.selected)
        accessibilityLabel = "Case à cocher"
        updateAccessibility()

        updateColors()
    }

    @objc private func toggleChecked() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
        updateAccessibility()
        updateColors()
    }

    private func updateAccessibility() {
        accessibilityValue = isSelected ? "cochée" : "décochée"
    }

    private func updateColors() {
        if isSelected {
            tintColor = UIColor.appOrange
        } else {
            tintColor = UIColor.appGris112
        }
    }
}
