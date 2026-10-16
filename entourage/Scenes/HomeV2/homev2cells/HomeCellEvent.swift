//
//  HomeCellEvent.swift
//  entourage
//
//  Created by Clement entourage on 04/10/2023.
//

import Foundation
import UIKit
import SDWebImage


class HomeCellEvent:UICollectionViewCell{

    //OUTLET
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ui_label_place: UILabel!

    @IBOutlet weak var ui_label_date: UILabel!
    @IBOutlet weak var ui_label_interest: UILabel!
    @IBOutlet weak var ui_image_event: UIImageView!

    @IBOutlet weak var ui_image_interest: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ic_entoutou: UIImageView!

    /// Cover wash + "Annulé" badge shown when the event is cancelled (EN-9335), matching EventListCell.
    private let ui_view_cancelled_wash = UIView()
    private let ui_badge_cancelled = EventCancelledBadgeView()

    /// Participants count row (icon + label) shown below the place, opt-in via `configure(event:showMembersCount:)` (EN-9680).
    private let ui_icon_members = UIImageView(image: UIImage(named: "ic_event_list_user"))
    private let ui_label_members = UILabel()

    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.appBeige.cgColor
        containerView.clipsToBounds = true
        ui_label_title.numberOfLines = 2
        ui_label_title.lineBreakMode = .byTruncatingTail
        setupCancelledIndicators()
        setupMembersCount()
    }

    private func setupMembersCount() {
        ui_icon_members.contentMode = .scaleAspectFit
        ui_icon_members.isHidden = true
        ui_icon_members.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_icon_members)

        ui_label_members.font = UIFont(name: "NunitoSans-Regular", size: 12)
        ui_label_members.textColor = UIColor(named: "grey_light")
        ui_label_members.isHidden = true
        ui_label_members.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_label_members)

        NSLayoutConstraint.activate([
            ui_label_members.topAnchor.constraint(equalTo: ui_label_place.bottomAnchor, constant: 2),
            ui_label_members.leadingAnchor.constraint(equalTo: ui_icon_members.trailingAnchor, constant: 6),
            ui_label_members.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            ui_icon_members.leadingAnchor.constraint(equalTo: ui_label_place.leadingAnchor),
            ui_icon_members.centerYAnchor.constraint(equalTo: ui_label_members.centerYAnchor),
            ui_icon_members.widthAnchor.constraint(equalToConstant: 10),
            ui_icon_members.heightAnchor.constraint(equalToConstant: 10)
        ])
    }

    private func setupCancelledIndicators() {
        ui_view_cancelled_wash.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        ui_view_cancelled_wash.isHidden = true
        ui_view_cancelled_wash.isUserInteractionEnabled = false
        ui_view_cancelled_wash.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(ui_view_cancelled_wash, aboveSubview: ui_image_event)
        NSLayoutConstraint.activate([
            ui_view_cancelled_wash.topAnchor.constraint(equalTo: ui_image_event.topAnchor),
            ui_view_cancelled_wash.leadingAnchor.constraint(equalTo: ui_image_event.leadingAnchor),
            ui_view_cancelled_wash.trailingAnchor.constraint(equalTo: ui_image_event.trailingAnchor),
            ui_view_cancelled_wash.bottomAnchor.constraint(equalTo: ui_image_event.bottomAnchor)
        ])

        ui_badge_cancelled.isHidden = true
        ui_badge_cancelled.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_badge_cancelled)
        NSLayoutConstraint.activate([
            ui_badge_cancelled.topAnchor.constraint(equalTo: ui_image_event.topAnchor, constant: 6),
            ui_badge_cancelled.leadingAnchor.constraint(equalTo: ui_image_event.leadingAnchor, constant: 6),
            ui_badge_cancelled.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    
    func configure(event:Event, showMembersCount:Bool = false){
        ui_label_title.text = event.title + "\n"
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else  if let imageUrl = event.metadata?.landscape_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else {
            ui_image_event.image = UIImage.init(named: "ic_placeholder_event")
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
        }
        else if isAmbassador {
            self.ic_entoutou.isHidden = false
            self.ic_entoutou.image = UIImage(named: "ic_entoutou_logo_little")
        }
        else {
            self.ic_entoutou.isHidden = true
        }

        ui_label_date.text = event.startDateFormatted
        let addressComponents = event.addressName?.split(separator: ",")
        if let lastComponent = addressComponents?.last {
            ui_label_place.text = String(lastComponent).trimmingCharacters(in: .whitespaces)
            
        } else {
            ui_label_place.text = event.addressName
        }
        if let _interests = event.interests{
            if _interests.count > 0{
                if let _interest = event.interests?[0]{
                    ui_label_interest.text = TagsUtils.showTagTranslated(_interest)
                    switch _interest {
                    case "activites":
                        ui_image_interest.image = UIImage(named: "interest_activities")
                    case "animaux":
                        ui_image_interest.image = UIImage(named: "interest_animals")
                    case "bien-etre":
                        ui_image_interest.image = UIImage(named: "interest_wellness")
                    case "cuisine":
                        ui_image_interest.image = UIImage(named: "interest_cooking")
                    case "culture":
                        ui_image_interest.image = UIImage(named: "interest_art")
                    case "jeux":
                        ui_image_interest.image = UIImage(named: "interest_game")
                    case "sport":
                        ui_image_interest.image = UIImage(named: "interest_sport")
                    case "nature":
                        ui_image_interest.image = UIImage(named: "interest_nature")
                    case "marauding":
                        ui_image_interest.image = UIImage(named: "interest_nomad")
                    default:
                        ui_image_interest.image = UIImage(named: "interest_others")
                    }
                }
            }else{
                ui_label_interest.text = "Autre"
                ui_image_interest.image = UIImage(named: "interest_others")
            }
        }

        if showMembersCount, let membersCount = event.membersCount {
            let key = membersCount > 1 ? "event_members_cell_list" : "event_member_cell_list"
            ui_label_members.text = String(format: key.localized, membersCount)
            ui_label_members.isHidden = false
            ui_icon_members.isHidden = false
        } else {
            ui_label_members.isHidden = true
            ui_icon_members.isHidden = true
        }

        let isCancelled = event.isCanceled()
        ui_view_cancelled_wash.isHidden = !isCancelled
        ui_badge_cancelled.isHidden = !isCancelled
        ui_label_title.textColor = isCancelled ? .appGris112 : UIColor(named: "grey_dark")
    }
    
    private func updateImage(mainUrl:URL) {
        ui_image_event.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_image_event.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
}
