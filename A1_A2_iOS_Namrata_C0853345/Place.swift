//
//  Place.swift
//  A1_A2_iOS_Ishara_C0852812
//
//  Created by Ishara Abeykoon on 2022-05-24.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    static func getPlaces() -> [Place] {
        guard let path = Bundle.main.path(forResource: "Places", ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return [] }
        
        var places = [Place]()
        
        for item in array {
            let dictionary = item as? [String : Any]
            let title = dictionary?["title"] as? String
            let subtitle = dictionary?["description"] as? String
            let latitude = dictionary?["latitude"] as? Double ?? 0, longitude = dictionary?["longitude"] as? Double ?? 0
            
            let place = Place(title: title, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
            places.append(place)
        }
        
        return places as [Place]
    }
}
