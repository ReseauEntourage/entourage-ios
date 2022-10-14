//
//  CustomAnnotation.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation
import MapKit

class CustomAnnotation : NSObject,MKAnnotation {
    let kAnnotIdentifier = "AnnotationIdentifier"
    var annotationView:MKAnnotationView {
        get {
            return getAnnotationView()
        }
    }
    var annotationIdentifier:String {
        get {return kAnnotIdentifier}
    }
    var poi:MapPoi?
    var coordinate: CLLocationCoordinate2D {
        get {
            if let _pLat = poi?.latitude, let _pLong = poi?.longitude {
                return CLLocationCoordinate2D(latitude: _pLat, longitude: _pLong)
            }
            return CLLocationCoordinate2D(latitude: PARIS_LAT, longitude: PARIS_LON)
        }
    }
    
    var title: String? { get { return poi?.name }}
    
    var subtitle: String? { get { return poi?.details }}
    
    convenience init(poi:MapPoi) {
        self.init()
        self.poi = poi
    }
    
    func getAnnotationView() -> MKAnnotationView {
        let annotView = MKAnnotationView(annotation: self, reuseIdentifier: kAnnotIdentifier)

        annotView.canShowCallout = false
        annotView.image = self.poi?.image

        return annotView
    }
}
