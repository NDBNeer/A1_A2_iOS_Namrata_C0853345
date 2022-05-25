//
//  ViewController.swift
//  A1_A2_iOS_Namrata_C0853345
//
//  Created by Namrata Barot on 2022-05-24.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationViewMap: MKMapView!
    @IBOutlet weak var positionButton: UIButton!
    
    var locationMnager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    
    let places = Place.getPlaces()
    var regionAnnotation: [MKAnnotation] = []
    
    var currentCords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    let GEOFENCE_REGION = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationViewMap.isZoomEnabled = false
        locationViewMap.showsUserLocation = true
        
        positionButton.isHidden = true
        
        // we assign the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // we define the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
        locationViewMap.addGestureRecognizer(uilpgr)
        
        // add double tap
        addDoubleTap()
        
        locationViewMap.delegate = self
        
    }
    
    
    
    func isCloseToPoint(p1: CLLocation, p2: CLLocation ) -> Bool{
        let distance = p1.distance(from: p2)
        print("distance:", String(distance))
        if (abs(distance) > GEOFENCE_REGION ){
            return false
        }
        return true
        
    }
    
    
    //MARK: - draw route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        locationViewMap.removeOverlays(locationViewMap.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationMnager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.locationViewMap.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.locationViewMap.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        removePin()
//        print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        currentCords.latitude = latitude
        currentCords.longitude = longitude
        displayLocation(latitude: latitude, longitude: longitude, title: "my location", subtitle: "you are here")
    }
    

    func addAnnotationsForPlaces() {
        locationViewMap.addAnnotations(places)
        
        let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
        locationViewMap.addOverlays(overlays)
    }
    
   
    func addPolyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        locationViewMap.addOverlay(polyline)
    }
    
    func addTriangle(){
        var coordinates: [CLLocationCoordinate2D] = []
        for annotation in regionAnnotation{
            coordinates.append(annotation.coordinate)
            
        }
        let triangle = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        
        locationViewMap.addOverlay(triangle)
        locationViewMap.addOverlay(polygon)
        
    }
    

    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        locationViewMap.addOverlay(polygon)
    }
    
   
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        locationViewMap.addGestureRecognizer(doubleTap)
        
    }
    
    func reDrawAnnotations(){
        let labels = ["A", "B", "C"]
        for (index, pointAnot) in regionAnnotation.enumerated(){
            let annotation = MKPointAnnotation()
            annotation.title = labels[index]
            let p1 = CLLocation(latitude: pointAnot.coordinate.latitude, longitude: pointAnot.coordinate.longitude)
            let p2 = CLLocation(latitude: currentCords.latitude, longitude: currentCords.longitude)
            let distance = p2.distance(from: p1)
            annotation.coordinate = pointAnot.coordinate
            annotation.subtitle = pointAnot.subtitle as! String
            locationViewMap.addAnnotation(annotation)
        }
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        //removePin()
        
        // add annotation
        let touchPoint = sender.location(in: locationViewMap)
        let coordinate = locationViewMap.convert(touchPoint, toCoordinateFrom: locationViewMap)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let p1 = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let p2 = CLLocation(latitude: currentCords.latitude, longitude: currentCords.longitude)
        if(regionAnnotation.count == 0){
            annotation.title = "A"

            let distance = p2.distance(from: p1)
            annotation.subtitle = "Point is " + String(distance) + " far away from you"
            
            regionAnnotation.append(annotation)
            locationViewMap.addAnnotation(annotation)
            
        }else if(regionAnnotation.count == 1){
            annotation.title = "B"
            let distance = p2.distance(from: p1)
            annotation.subtitle = "Point is " + String(distance) + " far away from you"
            
            regionAnnotation.append(annotation)
            locationViewMap.addAnnotation(annotation)
        }else if(regionAnnotation.count == 2){
            annotation.title = "C"
            let distance = p2.distance(from: p1)
            annotation.subtitle = "Point is " + String(distance) + " far away from you"
            
            regionAnnotation.append(annotation)
            locationViewMap.addAnnotation(annotation)
            addTriangle()
            regionAnnotation.append(annotation)
        }else{
            if(isCloseToPoint(p1: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), p2: CLLocation(
                latitude: regionAnnotation[0].coordinate.latitude,
                longitude:regionAnnotation[0].coordinate.longitude))){
                regionAnnotation.remove(at: 0)
                locationViewMap.removeOverlays(locationViewMap.overlays)
                reDrawAnnotations()
                
            }else if(isCloseToPoint(p1: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), p2: CLLocation(
                latitude: regionAnnotation[1].coordinate.latitude,
                longitude:regionAnnotation[1].coordinate.longitude))){
                regionAnnotation.remove(at: 1)
                locationViewMap.removeOverlays(locationViewMap.overlays)
                reDrawAnnotations()
                        
                }else if(isCloseToPoint(p1: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), p2: CLLocation(
                    latitude: regionAnnotation[2].coordinate.latitude,
                    longitude:regionAnnotation[2].coordinate.longitude))){
                    regionAnnotation.remove(at: 2)
                    locationViewMap.removeOverlays(locationViewMap.overlays)
                    reDrawAnnotations()
                    
                }else{
                    removeTriangleAnnotations()
                    print("Remove All")
                    annotation.title = "A"
                    let p1 = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    let p2 = CLLocation(latitude: currentCords.latitude, longitude: currentCords.longitude)
                    let distance = p2.distance(from: p1)
                    annotation.subtitle = "Point is " + String(distance) + " far away from you"
                    annotation.coordinate = coordinate
                    regionAnnotation.append(annotation)
                    locationViewMap.addAnnotation(annotation)
                }
                
            }
        destination = coordinate
        positionButton.isHidden = false
        }
        
        

        
        
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: locationViewMap)
        let coordinate = locationViewMap.convert(touchPoint, toCoordinateFrom: locationViewMap)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        annotation.title = "my favorite"
        annotation.coordinate = coordinate
        locationViewMap.addAnnotation(annotation)
    }
    

    func removePin() {
        for annotation in locationViewMap.annotations {
            locationViewMap.removeAnnotation(annotation)
        }
        

    }
    
    
    func removeTriangleAnnotations() {
        for annotation in regionAnnotation {
            locationViewMap.removeAnnotation(annotation)
        }
        regionAnnotation = []
        let overlays = locationViewMap.overlays
        locationViewMap.removeOverlays(overlays)

    }
    
    

    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        locationViewMap.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        locationViewMap.addAnnotation(annotation)
    }

}

extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "my location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "my destination":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        case "my favorite":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        case "A":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        case "B":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        case "C":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Favorite", message: "A nice place to visit", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.yellow
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}


