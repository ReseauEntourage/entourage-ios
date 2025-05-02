//
//  CustomAnnotation.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var poi: MapPoi?
    
    var coordinate: CLLocationCoordinate2D {
        if let latitude = poi?.latitude, let longitude = poi?.longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D(latitude: PARIS_LAT, longitude: PARIS_LON)
    }
    
    var title: String? {
        return poi?.name
    }
    
    var subtitle: String? {
        return poi?.details
    }
    
    // Identifiant unique pour la réutilisation
    var annotationIdentifier: String {
        return "CustomAnnotationIdentifier"
    }
    func getAnnotationView() -> MKAnnotationView {
        let annotView = MKAnnotationView(annotation: self, reuseIdentifier: annotationIdentifier)
        annotView.canShowCallout = false
        annotView.image = self.poi?.image
        return annotView
    }

    convenience init(poi: MapPoi) {
        self.init()
        self.poi = poi
    }
}

class ClusterAnnotation: NSObject, MKAnnotation {
    let cluster: ClusterPoi
    let coordinate: CLLocationCoordinate2D
    
    init(clusterPoi: ClusterPoi) {
        self.cluster = clusterPoi
        self.coordinate = CLLocationCoordinate2D(latitude: clusterPoi.latitude, longitude: clusterPoi.longitude)
        super.init()
    }
    
    var title: String? {
        return "Cluster"
    }
    
    var subtitle: String? {
        return "Groupe de \(cluster.count) POIs"
    }
    
    // Identifiant unique pour la réutilisation
    var annotationIdentifier: String {
        return "ClusterAnnotationIdentifier"
    }
}
