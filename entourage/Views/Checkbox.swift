import UIKit

final class Checkbox: UIButton {
    var isChecked: Bool = false {
        didSet {
            updateImage()
        }
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
        // Désactive le tint pour afficher les images originales
        tintColor = nil
        adjustsImageWhenHighlighted = false

        // Utilise vos images sans modification
        updateImage()

        // Ajoute l'action pour le toggle
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }

    private func updateImage() {
        let imageName = isChecked ? "ic_checkbox_signed" : "ic_checkbox_unsigned"
        setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    @objc private func toggle() {
        isChecked = !isChecked
        sendActions(for: .valueChanged)
    }
}
