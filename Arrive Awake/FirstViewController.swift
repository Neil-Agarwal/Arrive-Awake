//
//  FirstViewController.swift
//  Arrive Awake
//
//  Created by Neil Agarwal on 2018-01-07.
//  Copyright © 2018 Neil Agarwal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
    func drawRadius(placemark: MKPlacemark)
}


class FirstViewController: UIViewController, MKMapViewDelegate{
    
    // MARK: Variables and Constants
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var circle:MKOverlay? = nil
    let DEFAULTRADIUS = 500.00
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Handles responses asynchronously
        locationManager.delegate = self
        //Overrides defualt accuracy level
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //Triggers Location permission dialog
        locationManager.requestWhenInUseAuthorization()
        //Request user location once
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter Location"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        mapView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.red
            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
extension FirstViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        
    }
}
extension FirstViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        
        print (placemark.location?.coordinate)
        // cache the pin
        selectedPin = placemark
        
        // clear existing annotations
        mapView.removeAnnotations(mapView.annotations)
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = placemark.coordinate
        pinAnnotation.title = placemark.name
        if let city = placemark.locality,
            let province = placemark.administrativeArea {
            pinAnnotation.subtitle = "\(city) \(province)"
        }
        mapView.addAnnotation(pinAnnotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    func drawRadius(placemark: MKPlacemark) {
        //Removes Overlays
        mapView.removeOverlays(mapView.overlays)
        let location = placemark.location!
        let circle = MKCircle(center: location.coordinate, radius:DEFAULTRADIUS)
        mapView.add(circle)
    }
}

