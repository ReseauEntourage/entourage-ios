import UIKit

/// Protocol to communicate events from the AssociationPresentationCell back to the enclosing controller.
protocol AssociationPresentationCellDelegate: AnyObject {
    /// Called when the user taps the upload logo button.
    func associationPresentationCellDidTapUploadLogo(_ cell: AssociationPresentationCell)
    /// Called whenever the description text changes.
    func associationPresentationCell(_ cell: AssociationPresentationCell, didChangeDescription text: String)
}

class AssociationPresentationCell: UITableViewCell, UITextViewDelegate {

    weak var delegate: AssociationPresentationCellDelegate?

    // MARK: - UI Elements

    // Image principale (120x120)
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.systemGray5
        iv.layer.cornerRadius = 60 // 120 / 2
        // Fallback placeholder
        iv.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // --- MODIFICATION 1 : Le Conteneur (Rond Orange) ---
    private let editContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange // Fond Orange
        view.layer.cornerRadius = 17   // 34 / 2
        view.clipsToBounds = true
        
        // Bordure légère
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.borderWidth = 1
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true // Important pour capter le clic
        return view
    }()

    // --- MODIFICATION 2 : L'icône Crayon (Blanc) ---
    private let editIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear // Transparent
        
        // Image du crayon
        if let customImage = UIImage(named: "ic_profil_full_pen") {
            iv.image = customImage.withRenderingMode(.alwaysTemplate)
        } else {
            iv.image = UIImage(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)
        }
        
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white // Blanc (pour contraster avec le fond orange)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = false // Le clic est géré par le container
        return iv
    }()

    // Label Description
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("description_association_label", value: "Description de votre association", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Zone de texte editable (Hauteur agrandie)
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1.0
        tv.layer.cornerRadius = 4.0
        
        // Padding interne du texte pour qu'il ne colle pas aux bords
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = UIColor.lightGray
        tv.text = "Ex. : Association de quartier œuvrant pour le lien social via des événements ouverts à tous."
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Layout

    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .white

        contentView.addSubview(logoImageView)
        
        // On ajoute le conteneur PUIS l'image dedans
        contentView.addSubview(editContainerView)
        editContainerView.addSubview(editIconImageView)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)

        descriptionTextView.delegate = self

        // Gestures
        let tapLogo = UITapGestureRecognizer(target: self, action: #selector(uploadLogoTapped))
        logoImageView.addGestureRecognizer(tapLogo)
        
        // On met le geste sur le conteneur orange
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(uploadLogoTapped))
        editContainerView.addGestureRecognizer(tapEdit)

        NSLayoutConstraint.activate([
            // 1. Logo Centré (120x120)
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            // 2. Conteneur (Rond Orange de 34x34)
            editContainerView.topAnchor.constraint(equalTo: logoImageView.topAnchor),
            editContainerView.trailingAnchor.constraint(equalTo: logoImageView.trailingAnchor),
            editContainerView.widthAnchor.constraint(equalToConstant: 34),
            editContainerView.heightAnchor.constraint(equalToConstant: 34),
            
            // 3. Icône Crayon avec PADDING
            // On fixe les bords de l'image à 8 points des bords du conteneur
            editIconImageView.topAnchor.constraint(equalTo: editContainerView.topAnchor, constant: 8),
            editIconImageView.bottomAnchor.constraint(equalTo: editContainerView.bottomAnchor, constant: -8),
            editIconImageView.leadingAnchor.constraint(equalTo: editContainerView.leadingAnchor, constant: 8),
            editIconImageView.trailingAnchor.constraint(equalTo: editContainerView.trailingAnchor, constant: -8),

            // 4. Label
            descriptionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 5. Text Input (Hauteur fixe 250)
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Configuration

    func configure(image: UIImage?, description: String?) {
        if let image = image {
            logoImageView.image = image
            logoImageView.contentMode = .scaleAspectFill
        } else {
            if let placeholder = UIImage(named: "placeholder_user") {
                logoImageView.image = placeholder
            } else {
                logoImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
            }
        }

        if let text = description, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionTextView.textColor = UIColor.black
            descriptionTextView.text = text
        } else {
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.text = "Ex. : Association de quartier œuvrant pour le lien social via des événements ouverts à tous."
        }
    }

    // MARK: - Actions

    @objc private func uploadLogoTapped() {
        delegate?.associationPresentationCellDidTapUploadLogo(self)
    }

    // MARK: - UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Ex. : Association de quartier œuvrant pour le lien social via des événements ouverts à tous."
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 800 {
            let index = textView.text.index(textView.text.startIndex, offsetBy: 800)
            textView.text = String(textView.text[..<index])
        }
        delegate?.associationPresentationCell(self, didChangeDescription: textView.text)
    }
}
