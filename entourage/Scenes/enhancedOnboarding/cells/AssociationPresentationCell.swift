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

    // CORRECTION ICI : Bouton d'édition (30x30)
    private let editIconView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white // Fond blanc
        
        // On essaie de charger l'image nommée, sinon on met un crayon système pour tester
        if let customImage = UIImage(named: "ic_profil_full_pen") {
            iv.image = customImage
        } else {
            // Fallback système si l'asset n'est pas trouvé
            iv.image = UIImage(systemName: "pencil")
        }
        
        iv.contentMode = .scaleAspectFit // Important pour voir l'image entière
        iv.tintColor = UIColor.orange // Force la couleur si c'est une image template
        
        iv.layer.cornerRadius = 15 // 30 / 2
        iv.clipsToBounds = true
        
        // Bordure légère pour le détacher du fond si l'image est blanche
        iv.layer.borderColor = UIColor.systemGray5.cgColor
        iv.layer.borderWidth = 1
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // Label Description
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description de votre association"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Zone de texte editable
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1.0
        tv.layer.cornerRadius = 4.0
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
        contentView.addSubview(editIconView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)

        descriptionTextView.delegate = self

        // Gestures
        let tapLogo = UITapGestureRecognizer(target: self, action: #selector(uploadLogoTapped))
        logoImageView.addGestureRecognizer(tapLogo)
        
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(uploadLogoTapped))
        editIconView.addGestureRecognizer(tapEdit)

        NSLayoutConstraint.activate([
            // 1. Logo Centré (120x120)
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            // 2. Icone Crayon (30x30)
            // On le place en haut à droite, légèrement chevauché
            editIconView.topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: 0),
            editIconView.trailingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 0),
            editIconView.widthAnchor.constraint(equalToConstant: 34), // Un poil plus grand pour la zone de touche
            editIconView.heightAnchor.constraint(equalToConstant: 34),

            // 3. Label
            descriptionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 4. Text Input
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
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
