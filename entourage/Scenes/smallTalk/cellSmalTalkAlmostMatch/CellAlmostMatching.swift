//
//  CellAlmostMatching.swift
//  entourage
//
//  Created by Clement entourage on 21/05/2025.
//

import UIKit
import SDWebImage

class CellAlmostMatching: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var avatar1: UIImageView!
    @IBOutlet weak var avatar2: UIImageView!
    @IBOutlet weak var avatar3: UIImageView!
    @IBOutlet weak var avatar4: UIImageView!
    @IBOutlet weak var avatar5: UIImageView!
    @IBOutlet weak var avatar6: UIImageView! // au cas où tu veuilles en ajouter un 6e
    @IBOutlet weak var ui_title_cell: UILabel!
    @IBOutlet weak var ui_list_name: UILabel!
    @IBOutlet weak var ui_btn_join: UIButton!

    // MARK: - Variables
    var onJoinTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureWhiteButton(ui_btn_join, withTitle: NSLocalizedString("small_talk_other_band_join", comment: ""))
        ui_btn_join.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
    }

    // MARK: - Configure
    func configure(with request: UserSmallTalkRequest,
                   matchingLocality: Bool,
                   matchingGender: Bool,
                   matchingGroup: String) {

        // Avatars à afficher
        let avatarURLs: [String] = request.smalltalk?.members.compactMap { $0.avatar_url } ??
            (request.user != nil ? [request.user!.avatar_url].compactMap { $0 } : [])

        renderAvatars(urls: avatarURLs)

        // Noms à afficher
        let names: [String] = request.smalltalk?.members.compactMap { $0.display_name } ??
            (request.user != nil ? [request.user!.display_name] : [])

        let namesFormatted = names.joined(separator: " et ")
        ui_title_cell.text = String(format: NSLocalizedString("small_talk_other_band_with", comment: ""), namesFormatted)

        // Type de différence
        ui_list_name.text = determineMismatchText(
            request: request,
            matchingLocality: matchingLocality,
            matchingGender: matchingGender,
            matchingGroup: matchingGroup
        )
    }

    // MARK: - Actions
    @objc private func joinTapped() {
        onJoinTapped?()
    }

    // MARK: - Helpers
    private func renderAvatars(urls: [String]) {
        let imageViews = [avatar1, avatar2, avatar3, avatar4, avatar5]

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

    private func determineMismatchText(request: UserSmallTalkRequest,
                                       matchingLocality: Bool,
                                       matchingGender: Bool,
                                       matchingGroup: String) -> String {
        if matchingLocality && request.match_locality == false {
            return NSLocalizedString("small_talk_other_band_different_location", comment: "")
        }
        if matchingGender && request.match_gender == false {
            return NSLocalizedString("small_talk_other_band_different_interests", comment: "")
        }
        if matchingGroup == "one" && request.match_format != "one" {
            return NSLocalizedString("small_talk_other_band_duo", comment: "")
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
