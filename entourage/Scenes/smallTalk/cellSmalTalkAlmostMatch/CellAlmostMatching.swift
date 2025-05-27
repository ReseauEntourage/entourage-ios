import UIKit
import SDWebImage

class CellAlmostMatching: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var avatar1: UIImageView!
    @IBOutlet weak var avatar2: UIImageView!
    @IBOutlet weak var avatar3: UIImageView!
    @IBOutlet weak var avatar4: UIImageView!
    @IBOutlet weak var avatar5: UIImageView!
    @IBOutlet weak var avatar6: UIImageView!
    @IBOutlet weak var ui_title_cell: UILabel!
    @IBOutlet weak var ui_list_name: UILabel!
    @IBOutlet weak var ui_btn_join: UIButton!

    // MARK: - Callback
    var onJoinTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureWhiteButton(ui_btn_join, withTitle: NSLocalizedString("small_talk_other_band_join", comment: ""))
        ui_btn_join.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
    }

    // MARK: - Configure
    func configure(with request: UserSmallTalkRequestWithMatchData) {
        // Avatars
        let avatarURLs: [String] = request.users.compactMap { $0.avatar_url }
        renderAvatars(urls: avatarURLs)

        // Noms
        let names: [String] = request.users.map { $0.display_name }
        let namesFormatted = names.joined(separator: " et ")
        ui_title_cell.text = String(format: NSLocalizedString("small_talk_other_band_with", comment: ""), namesFormatted)

        // Texte d’incompatibilité
        ui_list_name.text = mismatchText(for: request)
    }

    // MARK: - Actions
    @objc private func joinTapped() {
        onJoinTapped?()
    }

    // MARK: - Helpers
    private func renderAvatars(urls: [String]) {
        let imageViews = [avatar1, avatar2, avatar3, avatar4, avatar5, avatar6]
        imageViews.forEach { $0?.isHidden = true }

        for (index, url) in urls.prefix(imageViews.count).enumerated() {
            guard let imageView = imageViews[index] else { continue }
            imageView.isHidden = false
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
            imageView.sd_setImage(
                with: URL(string: url),
                placeholderImage: UIImage(named: "placeholder_user"),
                options: .continueInBackground,
                completed: nil
            )
        }
    }

    private func mismatchText(for request: UserSmallTalkRequestWithMatchData) -> String {
        if !request.hasMatchedLocality {
            return NSLocalizedString("small_talk_other_band_different_location", comment: "")
        }
        if !request.hasMatchedInterest {
            return NSLocalizedString("small_talk_other_band_different_interests", comment: "")
        }
        if !request.hasMatchedGender {
            return NSLocalizedString("small_talk_other_band_different_gender", comment: "")
        }
        if !request.hasMatchedFormat {
            return NSLocalizedString("small_talk_other_band_different_format", comment: "")
        }
        return NSLocalizedString("small_talk_other_band_group", comment: "")
    }

    private func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
}
