import UIKit
import ActiveLabel
import SDWebImage

class NeighborhoodDetailTopCell: UITableViewCell {
    
    // MARK: - IBOutlets
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
    @IBOutlet weak var see_more_button: UIButton!
    @IBOutlet weak var ui_taglist_view: TagListView!
    @IBOutlet weak var ui_btn_share: UIButton?
    @IBOutlet weak var btn_join: UIButton!
    @IBOutlet weak var contraint_share_left_counstraint: NSLayoutConstraint!
    @IBOutlet weak var contraint_height_tag_list_view: NSLayoutConstraint!
    
    @IBOutlet weak var contraint_top_button_see_more: NSLayoutConstraint!
    // MARK: - Properties
    weak var delegate: NeighborhoodDetailTopCellDelegate? = nil
    
    let topMarginConstraint: CGFloat = 24
    let cornerRadiusTag: CGFloat = 15
    
    var isFollowingGroup = false
    var isFromOnlyDetail = false
    
    private var isAboutGroupExpanded: Bool = false
    private var fullAboutGroupText: String = ""
    private let truncatedLength: Int = 150
    
    class var identifier: String { return String(describing: self) }
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Configuration de la vue principale
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        // Configuration des labels
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_about_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lbl_about_title?.text = "neighborhood_detail_about_title".localized
        ui_lbl_about_desc?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        // Activation de la copie longue sur le label de description
        if ui_lbl_about_desc != nil {
            ui_lbl_about_desc.enableLongPressCopy()
            ui_lbl_about_desc.isUserInteractionEnabled = true
        }
        
        // Configuration du bouton de join
        ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_view_button_join.layer.cornerRadius = ui_view_button_join.frame.height / 2
        ui_view_button_join.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_button_join.layer.borderWidth = 1
        
        // Configuration de la TagListView
        ui_taglist_view?.backgroundColor = .appBeigeClair
        ui_taglist_view?.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view?.cornerRadius = cornerRadiusTag
        ui_taglist_view?.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view?.textColor = .appOrange
        ui_taglist_view?.alignment = .left
        ui_taglist_view?.marginY = 12
        ui_taglist_view?.marginX = 15
        ui_taglist_view?.paddingX = 10
        ui_taglist_view?.paddingY = 9
        ui_taglist_view.isHidden = true
        
        // Configuration des images des membres
        [ui_img_member_1, ui_img_member_2, ui_img_member_3].forEach { imageView in
            imageView?.layer.cornerRadius = (imageView?.frame.height ?? 0) / 2
            imageView?.clipsToBounds = true
        }
        
        // Configuration du bouton de partage
        configureWhiteButton(self.ui_btn_share!, withTitle: "neighborhood_add_post_send_button".localized)
        
        // Configuration du bouton "Voir plus / Voir moins"
        configureSeeMoreButton()
        delegate?.updateHeightCell()
    }
    
    // MARK: - Configure "Voir plus" Button
    private func configureSeeMoreButton() {
        // Styliser le bouton avec un texte souligné
        updateSeeMoreButtonTitle()
        
        
        // Ajouter l'action au bouton
        see_more_button.addTarget(self, action: #selector(onSeeMoreButtonClicked), for: .touchUpInside)
    }
    
    private func updateSeeMoreButtonTitle() {
        let title = isAboutGroupExpanded ? "Voir moins" : "Voir plus"
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.appOrange
        ])
        see_more_button.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // MARK: - Actions
    @objc func onSeeMoreButtonClicked() {
        toggleAboutGroupExpansion()
    }
    
    @objc func toggleAboutGroupExpansion() {
        isAboutGroupExpanded.toggle()
        contraint_top_button_see_more?.constant = 5
        if isAboutGroupExpanded {
            ui_lbl_about_desc?.text = fullAboutGroupText
            ui_constraint_listview_top_margin?.constant = 20
        } else {
            ui_lbl_about_desc?.attributedText = truncateAboutGroup(fullAboutGroupText)
            ui_constraint_listview_top_margin?.constant = 0
        }
        if isAboutGroupExpanded{
            contraint_height_tag_list_view?.constant = calculateTagListViewHeight()
        }else{
            contraint_height_tag_list_view?.constant = 0
        }
        
        // Mise à jour du titre du bouton
        updateSeeMoreButtonTitle()
        
        // Afficher ou masquer la TagListView en fonction de l'état
        ui_taglist_view.isHidden = !isAboutGroupExpanded
        
        // Informer le délégué pour mettre à jour la hauteur de la cellule
        delegate?.updateHeightCell()
    }
    
    private func calculateTagListViewHeight() -> CGFloat {
        // Forcer un layout sur la TagListView pour qu'elle calcule ses dimensions
        ui_taglist_view?.layoutIfNeeded()
        
        // Obtenez la taille intrinsèque du TagListView
        let tagListViewHeight = ui_taglist_view?.intrinsicContentSize.height ?? 0
        return tagListViewHeight
    }
    
    // MARK: - Helper Methods
    private func truncateAboutGroup(_ text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        if text.count > truncatedLength {
            let truncatedText = String(text.prefix(truncatedLength)) + "..."
            attributedText.mutableString.setString(truncatedText)
        }
        // Toujours afficher le bouton "Voir plus / Voir moins"
        return attributedText
    }
    
    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 21
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    func populateCell(neighborhood: Neighborhood?, isFollowingGroup: Bool, isFromOnlyDetail: Bool, delegate: NeighborhoodDetailTopCellDelegate) {
        // Gestion de la visibilité du bouton de partage et du bouton de join
        if let _isMember = neighborhood?.isMember {
            if _isMember {
                contraint_share_left_counstraint.constant = 28
                btn_join.isHidden = true
            } else {
                contraint_share_left_counstraint.constant = 178
                btn_join.isHidden = false
            }
        }
        
        self.delegate = delegate
        self.isFollowingGroup = isFollowingGroup
        self.isFromOnlyDetail = isFromOnlyDetail
        
        // Réinitialiser la visibilité des images des membres
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_view_members_more.isHidden = true
        
        guard let neighborhood = neighborhood else { return }
        
        // Charger les images des membres
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
        
        // Afficher le nombre de membres
        ui_lbl_nb_members.text = neighborhood.membersCount > 1
            ? String(format: "neighborhood_detail_members".localized, neighborhood.membersCount)
            : String(format: "neighborhood_detail_member".localized, neighborhood.membersCount)
        
        // Configurer le titre du quartier
        ui_title.text = neighborhood.name
        
        // Configurer la description du quartier
        if let aboutGroup = neighborhood.aboutGroup, !aboutGroup.isEmpty {
            fullAboutGroupText = aboutGroup
            ui_lbl_about_desc?.attributedText = truncateAboutGroup(fullAboutGroupText)
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
            ui_constraint_listview_top_margin?.constant = _interests.isEmpty ? 0 : topMarginConstraint
        } else {
            ui_constraint_listview_top_margin?.constant = topMarginConstraint
        }
        
        // Toujours afficher le bouton "Voir plus / Voir moins"
        see_more_button.isHidden = false
        
        // Mettre à jour le titre du bouton "Voir plus / Voir moins"
        updateSeeMoreButtonTitle()
        
        // Masquer ou afficher la TagListView en fonction de l'état initial
        
        // Ajouter l'action au bouton de partage
        ui_btn_share?.addTarget(self, action: #selector(onBtnShareClicked), for: .touchUpInside)
        contraint_height_tag_list_view?.constant = 0
        delegate.updateHeightCell()
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

// MARK: - Subclass
class NeighborhoodDetailTopMemberCell: NeighborhoodDetailTopCell {
    // Cette sous-classe peut hériter ou ajouter des fonctionnalités spécifiques si nécessaire
}
