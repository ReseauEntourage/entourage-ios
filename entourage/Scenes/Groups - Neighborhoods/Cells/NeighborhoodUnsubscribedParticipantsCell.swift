import UIKit

class NeighborhoodUnsubscribedParticipantsCell: UITableViewCell {

    let titleLabel = UILabel()
    let typeLabel = UILabel()
    let subtitleLabel = UILabel()
    let iconImageView = UIImageView()
    let bgIconView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(named: "BeigeClair") ?? UIColor(red: 255/255, green: 245/255, blue: 237/255, alpha: 1.0)

        bgIconView.backgroundColor = UIColor(named: "appOrange") ?? .orange
        bgIconView.layer.cornerRadius = 25
        bgIconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgIconView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        bgIconView.addSubview(iconImageView)

        typeLabel.font = ApplicationTheme.getFontCourantBoldNoir()
        typeLabel.textColor = .black
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLabel)

        subtitleLabel.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        subtitleLabel.textColor = UIColor(named: "grey_reaction") ?? .gray
        subtitleLabel.text = "Ajoutés sur place"
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            bgIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bgIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bgIconView.widthAnchor.constraint(equalToConstant: 50),
            bgIconView.heightAnchor.constraint(equalToConstant: 50),

            iconImageView.centerXAnchor.constraint(equalTo: bgIconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: bgIconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            typeLabel.leadingAnchor.constraint(equalTo: bgIconView.trailingAnchor, constant: 12),
            typeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            subtitleLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(count: Int, isAskForHelp: Bool) {
        if isAskForHelp {
            let labelText = count > 1 ? "\(count) personnes isolées" : "\(count) personne isolée"
            typeLabel.text = labelText
            iconImageView.image = UIImage(named: "user") // Find the right image
        } else {
            let labelText = count > 1 ? "\(count) riverains" : "\(count) riverain"
            typeLabel.text = labelText
            iconImageView.image = UIImage(named: "ic_neighb_home") // Find the right image
        }
    }
}
