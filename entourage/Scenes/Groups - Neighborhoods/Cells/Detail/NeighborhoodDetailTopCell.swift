import UIKit
import ActiveLabel

class NeighborhoodDetailTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_constraint_listview_top_margin: NSLayoutConstraint?

    @IBOutlet weak var ui_main_view: UIView!

    @IBOutlet weak var ui_title: UILabel!

    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_view_members_more: UIView!

    @IBOutlet weak var ui_view_button_join: UIView!
    @IBOutlet weak var ui_img_bt_join: UIImageView!
    @IBOutlet weak var ui_lbl_bt_join: UILabel!

    @IBOutlet weak var ui_lbl_about_title: UILabel!
    @IBOutlet weak var ui_lbl_about_desc: ActiveLabel!

    @IBOutlet weak var ui_taglist_view: TagListView!
    @IBOutlet weak var ui_btn_share: UIButton?
    @IBOutlet weak var btn_join: UIButton!

    weak var delegate: NeighborhoodDetailTopCellDelegate? = nil

    let topMarginConstraint: CGFloat = 24
    let cornerRadiusTag: CGFloat = 15

    var isFollowingGroup = false
    var isFromOnlyDetail = false

    private var isAboutGroupExpanded: Bool = false
    private var fullAboutGroupText: String = ""

    class var identifier: String { return String(describing: self) }

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius

        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_about_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lbl_about_title?.text = "neighborhood_detail_about_title".localized
        ui_lbl_about_desc?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())

        if ui_lbl_about_desc != nil {
            ui_lbl_about_desc.enableLongPressCopy()
            ui_lbl_about_desc.isUserInteractionEnabled = true
        }

        ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_view_button_join.layer.cornerRadius = ui_view_button_join.frame.height / 2
        ui_view_button_join.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_button_join.layer.borderWidth = 1

        ui_taglist_view?.backgroundColor = .appBeigeClair
        ui_taglist_view?.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view?.cornerRadius = cornerRadiusTag
        ui_taglist_view?.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view?.textColor = .appOrange
        ui_taglist_view?.alignment = .left

        ui_taglist_view?.marginY = 12
        ui_taglist_view?.marginX = 12

        ui_taglist_view?.paddingX = 15
        ui_taglist_view?.paddingY = 9

        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
        ui_btn_share?.setTitle("neighborhood_add_post_send_button".localized, for: .normal)
        ui_taglist_view.isHidden = true
    }

    private func truncateAboutGroup(_ text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        if text.count > 150 {
            let truncatedText = String(text.prefix(150)) + "..."
            attributedText.mutableString.setString(truncatedText)
        }

        // Ajout du texte "Voir plus" avec style souligné et couleur orange
        let voirPlusText = NSAttributedString(string: "\nVoir plus", attributes: [
            .foregroundColor: UIColor.appOrange,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        attributedText.append(voirPlusText)
        return attributedText
    }

    @objc func toggleAboutGroupExpansion() {
        guard let delegate = delegate else { return }
        isAboutGroupExpanded.toggle()

        if isAboutGroupExpanded {
            let fullText = NSMutableAttributedString(string: fullAboutGroupText)
            // Ajout du texte "Voir moins" avec style souligné et couleur orange
            let voirMoinsText = NSAttributedString(string: "\nVoir moins", attributes: [
                .foregroundColor: UIColor.appOrange,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ])
            fullText.append(voirMoinsText)
            ui_lbl_about_desc?.attributedText = fullText
            ui_taglist_view.isHidden = false // Affiche la TagListView
        } else {
            ui_lbl_about_desc?.attributedText = truncateAboutGroup(fullAboutGroupText)
            ui_taglist_view.isHidden = true // Masque la TagListView
        }

        setupActiveLabel()
        delegate.updateHeightCell()
    }

    private func setupActiveLabel() {
        ui_lbl_about_desc?.customize { label in
            label.enabledTypes = [.custom(pattern: "(Voir plus|Voir moins)")]
            label.customColor[.custom(pattern: "(Voir plus|Voir moins)")] = UIColor.appOrange
            label.customSelectedColor[.custom(pattern: "(Voir plus|Voir moins)")] = UIColor.appOrange
            label.handleCustomTap(for: .custom(pattern: "(Voir plus|Voir moins)")) { _ in
                self.toggleAboutGroupExpansion()
            }

            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                if case .custom = type {
                    atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                }
                return atts
            }
        }
    }

    func populateCell(neighborhood: Neighborhood?, isFollowingGroup: Bool, isFromOnlyDetail: Bool, delegate: NeighborhoodDetailTopCellDelegate) {
        if let _isMember = neighborhood?.isMember {
            if _isMember {
                btn_join.setVisibilityGone()
            }
        }
        self.delegate = delegate
        self.isFollowingGroup = isFollowingGroup
        self.isFromOnlyDetail = isFromOnlyDetail
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_view_members_more.isHidden = true

        guard let neighborhood = neighborhood else { return }

        for i in 0..<neighborhood.members.count {
            if i > 2 { break }
            switch i {
            case 0:
                ui_img_member_1.isHidden = false
                updateImageUrl(image: ui_img_member_1, imageUrl: neighborhood.members[i].imageUrl)
            case 1:
                ui_img_member_2.isHidden = false
                updateImageUrl(image: ui_img_member_2, imageUrl: neighborhood.members[i].imageUrl)
            case 2:
                ui_img_member_3.isHidden = false
                updateImageUrl(image: ui_img_member_3, imageUrl: neighborhood.members[i].imageUrl)
            default:
                break
            }
        }

        if neighborhood.membersCount > 3 {
            ui_view_members_more.isHidden = false
        }

        ui_lbl_nb_members.text = neighborhood.members.count > 1
            ? String(format: "neighborhood_detail_members".localized, neighborhood.membersCount)
            : String(format: "neighborhood_detail_member".localized, neighborhood.membersCount)

        ui_title.text = neighborhood.name

        if let aboutGroup = neighborhood.aboutGroup {
            fullAboutGroupText = aboutGroup
            ui_lbl_about_desc?.attributedText = isAboutGroupExpanded
                ? NSAttributedString(string: fullAboutGroupText)
                : truncateAboutGroup(fullAboutGroupText)
        } else {
            ui_lbl_about_desc?.text = ""
        }

        // Gestion des tags
        if let _interests = neighborhood.interests {
            ui_taglist_view?.removeAllTags()
            for interest in _interests {
                if let tagName = Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) {
                    ui_taglist_view?.addTag(tagName)
                } else {
                    ui_taglist_view?.addTag(interest)
                }
            }
            if _interests.isEmpty {
                ui_constraint_listview_top_margin?.constant = 0
            } else {
                ui_constraint_listview_top_margin?.constant = topMarginConstraint
            }
        } else {
            ui_constraint_listview_top_margin?.constant = topMarginConstraint
        }

        setupActiveLabel()
        ui_btn_share?.addTarget(self, action: #selector(onBtnShareClicked), for: .touchUpInside)
    }

    private func updateImageUrl(image: UIImageView, imageUrl: String?) {
        if let imageUrl = imageUrl, let mainUrl = URL(string: imageUrl) {
            image.sd_setImage(with: mainUrl, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            image.image = UIImage(named: "placeholder_user")
        }
    }

    @objc func onBtnShareClicked() {
        delegate?.shareGroup()
    }

    @IBAction func action_show_members(_ sender: Any) {
        delegate?.showMembers()
    }

    @IBAction func action_join_leave(_ sender: Any) {
        isFollowingGroup ? delegate?.showDetailFull() : delegate?.joinLeave()
    }
}

// MARK: - Protocol
protocol NeighborhoodDetailTopCellDelegate: AnyObject {
    func showMembers()
    func joinLeave()
    func showDetailFull()
    func showWebUrl(url: URL)
    func shareGroup()
    func updateHeightCell()
}

class NeighborhoodDetailTopMemberCell: NeighborhoodDetailTopCell {

}
