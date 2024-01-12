//
//  ActionFullMapCell.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit
import MapKit

class ActionFullMapCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_cancel_opacity: UIView!
    @IBOutlet weak var ui_view_map: UIView!
    @IBOutlet weak var ui_mapview: MKMapView!
    
    @IBOutlet weak var ui_lbl_about_title: UILabel!
    @IBOutlet weak var ui_lbl_about_desc: UILabel!
    
    class var identifier:String {return String(describing: self) }
    
    let regionRadius: CLLocationDistance = 500
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_view_cancel_opacity.isHidden = true
        
        ui_mapview.delegate = self
        ui_mapview.layer.cornerRadius = 20
        
        ui_lbl_about_title?.text = "action_detail_title_location".localized
        ui_lbl_about_desc.enableLongPressCopy()
        self.ui_lbl_about_title.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontQuickSandBold(size: 15), color: .black))
        self.ui_lbl_about_desc.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontNunitoRegular(size: 11), color: .black))
    }
    
    func populateCell(action:Action) {
        
        if action.isCanceled() {
            ui_view_cancel_opacity.isHidden = false
        }
        else {
            ui_view_cancel_opacity.isHidden = true
        }
        
        if let _location = action.location, let _lat = _location.latitude, let _long = _location.longitude {
            let _locAnnot = CLLocation(latitude: _lat, longitude: _long)
            
            let annot = PoiAnnot(title: "", coordinate: CLLocationCoordinate2D(latitude: _lat, longitude: _long))
            
            ui_mapview.removeAnnotations(ui_mapview.annotations)
            ui_mapview.addAnnotation(annot)
            centerMapOnLocation(_locAnnot)
        }
        let _address = action.metadata?.displayAddress ?? "-"
        if let _distance = action.distance {
            let _km = _distance.displayDistance()
            ui_lbl_about_desc?.text = "\(_address) \(_km)"
            
        }else{
            let _km = String.init(format: "atKm".localized, "xx")
            ui_lbl_about_desc?.text = "\(_address) \(_km)"
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
extension ActionFullMapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) { return nil }
        
        if let annotation = annotation as? PoiAnnot {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.canShowCallout = false
                view.image = UIImage(named: "ic_radius_location")
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.image = UIImage(named: "ic_radius_location")
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        if (annotation is MKUserLocation) { return }
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

