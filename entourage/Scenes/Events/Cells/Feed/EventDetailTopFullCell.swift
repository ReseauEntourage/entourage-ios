//
//  EventDetailTopFullCell.swift
//  entourage
//
//  Created by Jerome on 08/07/2022.
//

import UIKit
import SDWebImage
import ActiveLabel
import MapKit

class EventDetailTopFullCell: UITableViewCell {
    
    @IBOutlet weak var ui_iv_date: UIImageView!
    @IBOutlet weak var ui_iv_time: UIImageView!
    @IBOutlet weak var ui_iv_place: UIImageView!
    @IBOutlet weak var ui_constraint_listview_top_margin: NSLayoutConstraint?
    @IBOutlet weak var ui_main_view: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_lbl_about_title: UILabel!
    @IBOutlet weak var ui_lbl_about_desc: ActiveLabel!
    @IBOutlet weak var ui_taglist_view: TagListView!
    @IBOutlet weak var ui_start_time: UILabel!
    @IBOutlet weak var ui_start_date: UILabel!
    @IBOutlet weak var ui_view_place_limit: UIView!
    @IBOutlet weak var ui_place_limit_nb: UILabel!
    @IBOutlet weak var adress_view_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_iv_location: UIImageView!
    @IBOutlet weak var ui_location_name: UILabel!
    @IBOutlet weak var ui_label_organised_by: UILabel!
    @IBOutlet weak var ui_view_organised_by: UIView!
    @IBOutlet weak var ui_view_association: UIView!
    @IBOutlet weak var ui_label_association: UILabel!
    @IBOutlet weak var ui_btn_share: UIButton!
    @IBOutlet weak var ui_btn_participate: UIButton!
    @IBOutlet weak var ui_button_go_to_discussion: UIButton!
    @IBOutlet weak var ui_height_map_view: NSLayoutConstraint!
    
    @IBOutlet weak var ui_btn_agenda: UIButton!
    // **Nouvelle IBOutlet** pour la carte
    @IBOutlet weak var ui_mapview: MKMapView!
    @IBOutlet weak var ui_btn_i_participate: UIButton!
    
    weak var delegate: EventDetailTopCellDelegate? = nil
    
    let topMarginConstraint: CGFloat = 24
    let cornerRadiusTag: CGFloat = 15
    
    // Pour zoomer sur l’événement
    let regionRadius: CLLocationDistance = 500

    class var identifier: String { return String(describing: self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_nb_members.setFontBody(size: 15)
        ui_lbl_about_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lbl_about_title?.text = "event_detail_about_title".localized
        ui_lbl_about_desc?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_about_desc.enableLongPressCopy()
        
        ui_taglist_view?.backgroundColor = .appBeigeClair
        ui_taglist_view?.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view?.cornerRadius = cornerRadiusTag
        ui_taglist_view?.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view?.textColor = .appOrange
        ui_taglist_view?.alignment = .left
        
        // Values to align and padding tags
        ui_taglist_view?.marginY = 12
        ui_taglist_view?.marginX = 12
        ui_taglist_view?.paddingX = 15
        ui_taglist_view?.paddingY = 9
        
        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
        
        ui_view_place_limit.isHidden = true
        
        ui_btn_share.addTarget(self, action: #selector(onShareBtnClick), for: .touchUpInside)
        configureWhiteButton(self.ui_btn_share, withTitle: "neighborhood_add_post_send_button".localized)
        configureWhiteButton(self.ui_btn_participate, withTitle: "event_detail_button_participe_ON".localized)
        configureWhiteButton(self.ui_btn_agenda, withTitle: "event_button_add_calendar".localized)
        configureOrangeButton(self.ui_button_go_to_discussion, withTitle: "event_conversation".localized)
        
        self.ui_btn_agenda.addTarget(self, action: #selector(onAgendaClick), for: .touchUpInside)
        self.ui_btn_participate.addTarget(self, action: #selector(onParticipateClick), for: .touchUpInside)
        
        // **Initialisation de la carte**
        ui_mapview.delegate = self
        ui_mapview.layer.cornerRadius = 20
        ui_mapview.isHidden = true // on la masquera si c'est un event en ligne
        ui_btn_i_participate.semanticContentAttribute = .forceRightToLeft

    }
    
    @objc func onShareBtnClick() {
        delegate?.share()
    }
    
    @objc func onParticipateClick() {
        delegate?.joinLeave()
    }
    @objc func onAgendaClick() {
        delegate?.showAgenda()
    }
    
    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 21
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 15)
        button.clipsToBounds = true
        if let image = button.imageView?.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            button.tintColor = .black // Force l'icône en noir
        }
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 15)
        button.clipsToBounds = true
        if let image = button.imageView?.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            button.tintColor = .white // Force l'icône en noir
        }
    }
    
    func populateCell(event: Event?, delegate: EventDetailTopCellDelegate, isEntourageEvent: Bool) {
        
        self.delegate = delegate
        if event?.isMember ?? false {
            self.ui_btn_i_participate.isHidden = false
            self.ui_btn_agenda.isHidden = false
        }else{
            self.ui_btn_i_participate.isHidden = true
            self.ui_btn_agenda.isHidden = true
        }
        
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_img_member_1.image = nil
        ui_img_member_2.image = nil
        ui_img_member_3.image = nil
        
        guard let event = event else {
            return
        }
        
        // --- GESTION DES MEMBRES / AVATARS ---
        if let _members = event.members {
            for i in 0..<_members.count {
                if i > 2 { break }
                switch i {
                case 0:
                    ui_img_member_1.isHidden = false
                    updateImageUrl(image: ui_img_member_1, imageUrl: _members[i].imageUrl)
                case 1:
                    ui_img_member_2.isHidden = false
                    updateImageUrl(image: ui_img_member_2, imageUrl: _members[i].imageUrl)
                case 2:
                    ui_img_member_3.isHidden = false
                    updateImageUrl(image: ui_img_member_3, imageUrl: _members[i].imageUrl)
                default:
                    break
                }
            }
        }
        
        let _membersCount: Int = event.membersCount ?? 0

        ui_lbl_nb_members.text = ""
        var membersCount = ""
        if _membersCount > 1 {
            membersCount = String(format: "event_members_cell_list".localized, _membersCount)
        } else {
            membersCount = String(format: "event_member_cell_list".localized, _membersCount)
        }
        ui_lbl_nb_members.text = membersCount
        
        // --- TITRE et DESCRIPTION ---
        ui_title.text = event.title
        if let _desc = event.descriptionEvent {
            ui_lbl_about_desc.text = _desc
            ui_lbl_about_desc?.handleURLTap({ url in
                delegate.showWebUrl(url: url)
            })
        }
        
        // --- PLACES LIMIT ---
        if let placeLimit = event.metadata?.place_limit, placeLimit > 0 {
            ui_view_place_limit.isHidden = false
            ui_place_limit_nb.text = String(format: "event_places_detail".localized, placeLimit)
        } else {
            ui_view_place_limit.isHidden = true
        }
        
        // --- DATES & HEURE ---
        ui_start_date.text = event.startDateNameFormatted
        ui_start_time.text = event.startTimeFormatted
        
        // --- ADRESSE / ONLINE ---
        var _addressName = ""
        if event.isOnline ?? false {
            _addressName = event.onlineEventUrl ?? "-"
            ui_iv_location.image = event.isCanceled() ? UIImage(named: "ic_web_grey") : UIImage(named: "ic_web")
        } else {
            _addressName = event.addressName ?? "-"
            ui_iv_location.image = event.isCanceled() ? UIImage(named: "ic_location_grey") : UIImage(named: "ic_location")
        }
        
        if event.isCanceled() {
            ui_location_name.text = _addressName
        } else {
            // Si ce n’est pas annulé, on met un texte souligné cliquable (action showPlace)
            ui_location_name.attributedText = Utils.formatStringUnderline(textString: _addressName, textColor: .black)
        }
        
        // --- ORGA + ASSO ---
        if let _author = event.author {
            ui_label_organised_by.text = "event_top_cell_organised_by".localized + _author.displayName
            ui_view_organised_by.isHidden = false
            if let _asso = _author.partner {
                ui_view_association.isHidden = false
                ui_label_association.text = String(format: "event_top_cell_asso".localized, _asso.name)
            } else {
                ui_view_association.isHidden = true
            }
        } else {
            ui_view_organised_by.isHidden = true
            ui_view_association.isHidden = true
        }
        
        if isEntourageEvent {
            ui_label_association.text = String(format: "event_top_cell_asso".localized, "Entourage")
            ui_view_association.isHidden = false
        }
        
        // --- TAGS / INTERETS ---
        if let _interests = event.interests {
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
        
        // --- MAP LOGIC ---
        if let loc = event.location, !(event.isOnline ?? true),
           let lat = loc.latitude, let lon = loc.longitude {
            if lat == 0 && lon == 0 {
                ui_height_map_view.constant = 0
                ui_mapview.isHidden = true
            } else {
                ui_height_map_view.constant = 180
                ui_mapview.isHidden = false
                let location = CLLocation(latitude: lat, longitude: lon)

                // Ajout d’une annotation
                let annot = PoiAnnot(title: "", coordinate: location.coordinate)
                ui_mapview.addAnnotation(annot)

                // Centrage sur la position
                centerMapOnLocation(location)
            }
        } else {
            ui_mapview.isHidden = true
            ui_height_map_view.constant = 0
        }
        
        // Désactive éventuellement le bouton si l’événement est annulé ou passé
        self.disableButtonIfCancelOrPast(event: event)
        
        // Ajuste la contrainte pour l’adresse
        adjustConstraintForLabel(label: ui_location_name, constraint: adress_view_top_constraint)
    }

    
    private func adjustConstraintForLabel(label: UILabel, constraint: NSLayoutConstraint) {
        let text = label.text ?? ""
        let font = label.font ?? UIFont.systemFont(ofSize: 17)
        
        let maxSize = CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let textBoundingRect = NSString(string: text).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        
        let singleLineHeight = "Test".size(withAttributes: [.font: font]).height
        
        if textBoundingRect.height > singleLineHeight {
            // Text occupies more than one line
            constraint.constant = 40
        } else {
            // Text occupies only one line
            constraint.constant = 20
        }
    }
    
    private func disableButtonIfCancelOrPast(event: Event) {
        if event.checkIsEventPassed() {
            //TODO: Gérer éventuellement si l'événement est passé
            // Ex: désactiver le bouton "Participer"
        }
    }
    
    private func updateImageUrl(image: UIImageView, imageUrl: String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            image.sd_setImage(with: mainUrl, placeholderImage: nil) { _image, error, _, _ in
                if error != nil {
                    image.image = UIImage(named: "placeholder_user")
                }
            }
        }
        else {
            image.image = UIImage(named: "placeholder_user")
        }
    }
    
    // Centre la carte sur la location
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        ui_mapview.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        // Optionnel : si vous voulez montrer l’organisateur
    }
    
    @IBAction func action_show_members(_ sender: Any) {
        delegate?.showMembers()
    }
    
    @IBAction func action_show_place(_ sender: Any) {
        delegate?.showPlace()
    }
}

// MARK: - MKMapViewDelegate
extension EventDetailTopFullCell: MKMapViewDelegate {
    // Pour afficher un "pin" personnalisé
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotation = annotation as? PoiAnnot {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.canShowCallout = false
                view.image = UIImage(named: "ic_poi_event_map")
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.image = UIImage(named: "ic_poi_event_map")
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation, !(annotation is MKUserLocation) else {
            return
        }
        Logger.print("Annotation tap sur la map (EventDetailTopFullCell)")
    }
    
    // Empêche l’interaction sur la localisation user
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                view.canShowCallout = false
            }
        }
    }
}

// MARK: - Protocol -
protocol EventDetailTopCellDelegate: AnyObject {
    func showMembers()
    func joinLeave()
    func showDetailFull()
    func showPlace()
    func showWebUrl(url: URL)
    func showUser()
    func share()
    func showAgenda()
}

