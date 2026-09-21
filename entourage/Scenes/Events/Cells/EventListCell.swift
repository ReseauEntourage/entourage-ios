//
//  EventListCell.swift
//  entourage
//
//  Created by Jerome on 05/07/2022.
//

import UIKit
import SDWebImage

class EventListCell: UITableViewCell {

    static let EventlistMeIdentifier = "EventListMeCell"
    
    @IBOutlet weak var ui_iv_canceled: UIImageView!
    @IBOutlet weak var ui_constraint_left_title: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_location: UILabel!
    @IBOutlet weak var ui_members: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    @IBOutlet weak var ui_alpha_view: UIView!
    
    @IBOutlet weak var ic_entoutou: UIImageView!
    @IBOutlet weak var ic_entoutou_woman: UIImageView!
    @IBOutlet weak var ui_label_canceled: UILabel!
    @IBOutlet weak var ui_label_admin: UILabel?
    @IBOutlet weak var ui_subscribed_label: UILabel!

    /// Badge/wash shown over the thumbnail for a cancelled event (EN-9335). Replaces the old inline icon+text indicator.
    private let ui_badge_cancelled = EventCancelledBadgeView()
    private var isCancelled = false

    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris(size: 15))
        ui_location.setupFontAndColor(style: ApplicationTheme.getFontLegendGris(size: 15))
        ui_members.setupFontAndColor(style: ApplicationTheme.getFontLegendGris(size: 15))

        ui_image.layer.cornerRadius = 20
        ui_alpha_view.layer.cornerRadius = 20

        ui_label_admin?.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appOrangeLight))
        ui_label_admin?.text = "Admin".localized

        // Old inline "- Annulé" indicator: superseded by ui_badge_cancelled below, kept hidden for good.
        ui_iv_canceled.isHidden = true
        ui_label_canceled.isHidden = true
        ui_label_canceled.text = ""

        ui_badge_cancelled.isHidden = true
        ui_badge_cancelled.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_badge_cancelled)
        NSLayoutConstraint.activate([
            ui_badge_cancelled.topAnchor.constraint(equalTo: ui_image.topAnchor, constant: 4),
            ui_badge_cancelled.leadingAnchor.constraint(equalTo: ui_image.leadingAnchor, constant: 4),
            ui_badge_cancelled.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func populateCell(event:Event, hideSeparator:Bool) {

        isCancelled = event.isCanceled()
        ui_constraint_left_title.constant = 10

        if isCancelled {
            ui_badge_cancelled.isHidden = false
            ui_title.textColor = .appGris112
            ui_alpha_view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            ui_alpha_view.isHidden = false
        }
        else {
            ui_badge_cancelled.isHidden = true
            ui_title.textColor = .black
            ui_alpha_view.isHidden = true
        }

        var isAmbassador = false
        if let _author = event.author {
            if let _roles = _author.communityRoles{
                if _roles.contains("Équipe Entourage") || _roles.contains("Animateur Entourage") {
                    isAmbassador = true
                }
            }
        }
        
        let isReservedFemale = event.metadata?.reservedFemale ?? false

        if isReservedFemale {
            self.ic_entoutou.isHidden = false
            self.ic_entoutou.image = UIImage(named: "ic_entoutou_logo_woman")
            self.ic_entoutou_woman.isHidden = true
        }
        else if isAmbassador {
            self.ic_entoutou.isHidden = false
            self.ic_entoutou.image = UIImage(named: "ic_entoutou_logo_little")
            self.ic_entoutou_woman.isHidden = true
        }
        else {
            self.ic_entoutou.isHidden = true
            self.ic_entoutou_woman.isHidden = true
        }

        if event.isMember ?? false {
            ui_subscribed_label.isHidden = false
        }else{
            ui_subscribed_label.isHidden = true
        }
        
        ui_title.text = event.title
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else  if let imageUrl = event.metadata?.landscape_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else {
            ui_image.image = UIImage.init(named: "ic_placeholder_event")
        }
    
        ui_view_separator.isHidden = hideSeparator
        
        ui_date.text = event.startDateFormatted
        ui_location.text = event.addressName
        ui_members?.text = event.membersCount ?? 0 > 1 ? String.init(format: "event_members_cell_list".localized, event.membersCount!) : String.init(format: "event_member_cell_list".localized, event.membersCount!)
    }
    
    func setPassed(){
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGris())
        self.ui_alpha_view.isHidden = false
    }

    func setIncoming(){
        if !isCancelled {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
            self.ui_alpha_view.isHidden = true
        }
    }
    
    private func updateImage(mainUrl:URL) {
        ui_image.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_image.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
    
}
