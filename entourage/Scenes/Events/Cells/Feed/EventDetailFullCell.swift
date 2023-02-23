//
//  EventDetailFullCell.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit
import MapKit

class EventDetailFullCell: UITableViewCell {

    @IBOutlet weak var ui_bt_map: UIButton!
    @IBOutlet weak var ui_view_buttons: UIView!
    @IBOutlet weak var ui_view_cancel: UIView!
    @IBOutlet weak var ui_lbl_cancel: UILabel!
    
    @IBOutlet weak var ui_iv_date: UIImageView!
    @IBOutlet weak var ui_iv_time: UIImageView!
    @IBOutlet weak var ui_iv_place: UIImageView!
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_create_mod: UILabel!
    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_view_members_more: UIView!
    
    @IBOutlet weak var ui_start_time: UILabel!
    @IBOutlet weak var ui_start_date: UILabel!
    
    @IBOutlet weak var ui_view_place_limit: UIView!
    @IBOutlet weak var ui_place_limit_nb: UILabel!
    
    @IBOutlet weak var ui_location_name: UILabel!
    
    @IBOutlet weak var ui_title_bt_join: UILabel!
    @IBOutlet weak var ui_iv_plus: UIImageView!
    @IBOutlet weak var ui_iv_plus_icon: UIImageView!
    @IBOutlet weak var ui_view_button_join: UIView!
    @IBOutlet weak var ui_view_add_calendar: UIView!
    @IBOutlet weak var ui_view_map: UIView!
    @IBOutlet weak var ui_mapview: MKMapView!
    
    @IBOutlet weak var ui_lbl_about_title: UILabel!
    @IBOutlet weak var ui_lbl_about_desc: UILabel!
    
    @IBOutlet weak var ui_view_organised_by: UIView!
    
    @IBOutlet weak var ui_label_association: UILabel!
    @IBOutlet weak var ui_view_association: UIView!
    @IBOutlet weak var ui_label_organised_by: UILabel!
    @IBOutlet weak var ui_iv_location: UIImageView!
    @IBOutlet weak var ui_label_distance: UILabel!
    @IBOutlet weak var ui_view_distance: UIView!
    
    class var identifier:String {return String(describing: self) }
    
    let regionRadius: CLLocationDistance = 500
    
    weak var delegate:EventDetailFullDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_view_cancel.isHidden = true
        ui_view_cancel.layer.cornerRadius = 8
        ui_lbl_cancel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldBlanc(size: 15))
        ui_lbl_cancel.text = "event_canceled".localized.uppercased()
        
        ui_mapview.delegate = self
        ui_mapview.layer.cornerRadius = 20
        ui_bt_map.layer.cornerRadius = 20
        
        ui_view_add_calendar.layer.cornerRadius = ui_view_add_calendar.frame.height / 2
        ui_view_add_calendar.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_add_calendar.layer.borderWidth = 1
        
        ui_view_button_join.layer.cornerRadius = ui_view_button_join.frame.height / 2
        ui_view_button_join.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_button_join.layer.borderWidth = 1
        
        ui_label_distance.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 13), color: .appGris112))
        
        ui_iv_plus.layer.cornerRadius = ui_iv_plus.frame.height / 2
        
        ui_create_mod.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_about_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lbl_about_title?.text = "event_detail_about_title".localized
        ui_lbl_about_desc?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_title_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
        ui_title_bt_join.text = "event_detail_button_participe_ON".localized
        
        ui_view_button_join.layer.cornerRadius = ui_view_button_join.frame.height / 2
        ui_view_button_join.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_button_join.layer.borderWidth = 1
        
        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
        
        changeLabelsColors(newColor: .black)
    }
    
    private func changeLabelsColors(newColor:UIColor) {
        ui_title.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontQuickSandBold(size: 24), color: newColor))
        self.ui_start_date.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontNunitoRegular(size: 15), color: newColor))
        self.ui_start_time.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontNunitoRegular(size: 15), color: newColor))
        self.ui_place_limit_nb.setupFontAndColor(style:MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: newColor))
        self.ui_location_name.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontNunitoRegular(size: 15), color: newColor))
        self.ui_lbl_about_title.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontQuickSandBold(size: 15), color: newColor))
        self.ui_lbl_about_desc.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontNunitoRegular(size: 15), color: newColor))
    }
    
    func populateCell(event:Event, delegate:EventDetailFullDelegate) {
        
        self.delegate = delegate
        
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_view_members_more.isHidden = true
        
        ui_view_map.isHidden = event.isOnline ?? true
        
        if !(event.isOnline ?? true) {
            ui_iv_location.image = event.isCanceled() ? UIImage.init(named: "ic_location_grey") : UIImage.init(named: "ic_location")
            ui_view_distance.isHidden = false
            if let _location = event.location, let _lat = _location.latitude, let _long = _location.longitude {
                let _locAnnot = CLLocation(latitude: _lat, longitude: _long)
                
                let annot = PoiAnnot(title: "", coordinate: CLLocationCoordinate2D(latitude: _lat, longitude: _long))
                ui_mapview.addAnnotation(annot)
                centerMapOnLocation(_locAnnot)
            }
            if let _distance = event.distance{
                ui_label_distance.text = _distance.displayDistance()
            }else {
                ui_label_distance.text = String.init(format: "AtKm".localized, "xx")
            }
        }
        else {
            ui_label_distance.text = ""
            ui_iv_location.image = event.isCanceled() ? UIImage.init(named: "ic_web_grey") : UIImage.init(named: "ic_web")
            ui_view_distance.isHidden = true
        }
        
        var _addressName = ""
        if event.isOnline ?? false {
            _addressName = event.onlineEventUrl ?? "-"
        }
        else {
            _addressName = event.addressName ?? "-"
        }

        if event.isCanceled() {
            ui_bt_map.backgroundColor = .white.withAlphaComponent(0.3)
            self.ui_view_buttons.isHidden = true
            ui_iv_plus_icon.isHidden = true
            ui_iv_plus.isHidden = true
            self.ui_view_cancel.isHidden = false
            self.changeLabelsColors(newColor: .appGris112)
            
            if let date = event.getChangedStatusDate() {
            let dateStr = Utils.formatEventDateName(date: date)
                ui_create_mod.text = String.init(format: "event_canceled_full".localized, dateStr)
            }
            else {
                ui_create_mod.text = "event_cancel_alone".localized
            }
            
            ui_location_name.text = _addressName
            ui_iv_place.image = UIImage.init(named: "ic_event_group_grey")
            ui_iv_date.image = UIImage.init(named: "ic_event_date_grey")
            ui_iv_time.image = UIImage.init(named: "ic_event_time_grey")
        }
        else {
            ui_bt_map.backgroundColor = .clear
            self.ui_view_buttons.isHidden = false
            ui_iv_plus_icon.isHidden = false
            ui_iv_plus.isHidden = false
            self.changeLabelsColors(newColor: .black)
            self.ui_view_cancel.isHidden = true
            let createUpdate = event.getCreateUpdateDate()
            
            if createUpdate.isCreated {
                ui_create_mod.text = String.init(format: "event_created_full".localized, createUpdate.dateStr)
            }
            else {
                ui_create_mod.text = String.init(format: "event_updated_full".localized, createUpdate.dateStr)
            }
            ui_location_name.attributedText = Utils.formatStringUnderline(textString: _addressName, textColor: .black)
            ui_iv_place.image = UIImage.init(named: "ic_event_group_clear")
            ui_iv_date.image = UIImage.init(named: "ic_event_date")
            ui_iv_time.image = UIImage.init(named: "ic_event_time")
        }
        
        ui_title.text = event.title
        
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
        
        let _membersCount:Int = event.membersCount ?? 0
        
        if _membersCount > 3 {
            ui_view_members_more.isHidden = false
        }
        
        ui_lbl_nb_members.text = ""
        var membersCount = ""
        if _membersCount > 1 {
            membersCount = String.init(format: "event_members_cell_list".localized,_membersCount)
        }
        else {
            membersCount = String.init(format: "event_member_cell_list".localized, _membersCount)
        }
        
        ui_lbl_nb_members.text = membersCount
        
        if let _desc = event.descriptionEvent {
            ui_lbl_about_desc.setTextWithLinksDetected(_desc) { url in
                delegate.showWebviewUrl(url:url)
            }
        }
        
        if let placeLimit = event.metadata?.place_limit, placeLimit > 0 {
            ui_view_place_limit.isHidden = false
            ui_place_limit_nb.text = String.init(format: "event_places_detail_full".localized,placeLimit)
        }
        else {
            ui_view_place_limit.isHidden = true
        }
        
        if event.recurrence == .once {
            ui_start_date.text = event.startDateNameFormatted
        }
        else {
            ui_start_date.text = "\(event.startDateNameFormatted) • \(event.recurrence.getDescription())"
        }
        
        
        ui_start_time.text = String.init(format: "event_time_detail_full".localized, event.startTimeFormatted,event.endTimeFormatted)
        
        let currentUserId = UserDefaults.currentUser?.sid
        if let _ = event.members?.first(where: {$0.uid == currentUserId}) {
            ui_title_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
            ui_view_button_join.backgroundColor = .clear
            ui_title_bt_join.text = "event_detail_button_participe_ON".localized
        }
        else {
            ui_title_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
            ui_view_button_join.backgroundColor = .appOrange
            ui_title_bt_join.text = "event_detail_button_participe_OFF".localized
        }
        
        if let _author = event.author {
            ui_label_organised_by.text = "event_top_cell_organised_by".localized + _author.displayName
            ui_view_organised_by.isHidden = false
            if let _asso = _author.partner {
                ui_view_association.isHidden = false
                ui_label_association.text = String(format: "event_top_cell_asso".localized, _asso.name)
            }else{
                ui_view_association.isHidden = true
            }
            
        }else {
            ui_view_organised_by.isHidden = true
            ui_view_association.isHidden = true
        }
        
    }
    
    @IBAction func action_show_members(_ sender: Any) {
        delegate?.showMembers()
    }
    @IBAction func action_tap_map(_ sender: Any) {
        Logger.print("***** tap map")
        delegate?.showLocation()
    }
    
    @IBAction func action_show_location(_ sender: Any) {
        delegate?.showLocation()
    }
    @IBAction func action_add_calendar(_ sender: Any) {
        delegate?.addToCalendar()
    }
    @IBAction func action_leave(_ sender: Any) {
        delegate?.leaveEvent()
    }
    
    
    private func updateImageUrl(image:UIImageView, imageUrl:String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            image.image = UIImage.init(named: "placeholder_user")
        }
    }
    
    //MARK: center + zoom on map
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                       latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        ui_mapview.setRegion(coordinateRegion, animated: true)
    }
}


//MARK: MapView Delegate
extension EventDetailFullCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) { return nil }
        
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
        let annotation = view.annotation
        if (annotation is MKUserLocation) { return }
        
        if let _ = annotation as? PoiAnnot {
            Logger.print("***** clic annot here")
        }
        else {
            Logger.print("***** clic annot La")
        }
    }
    
    //pour annuler le clic sur la position user
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation!.isKind(of: MKUserLocation.self) {
                view.canShowCallout = false
            }
        }
    }
}

//MARK: - Annotation class -
class PoiAnnot: NSObject,MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}


protocol EventDetailFullDelegate:AnyObject {
    func showMembers()
    func showLocation()
    func leaveEvent()
    func addToCalendar()
    func showWebviewUrl(url:URL)
}
