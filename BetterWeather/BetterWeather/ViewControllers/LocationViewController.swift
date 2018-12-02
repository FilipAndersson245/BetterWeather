//
//  LocationViewController.swift
//  BetterWeather
//
//  Created by Marcus Gullstrand on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix addLocationButton styling
        addLocationButton.layer.cornerRadius = 5
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = self.view.tintColor.cgColor
        addLocationButton.titleLabel?.textColor = self.view.tintColor
        
        // Before use of location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Ignoring User
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Actitity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        // Hide searchbar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
                // PUT ERROR HANDLING HERE
                print("ERROR")
            }
            else
            {
                let annotations = self.mapView.annotations
                for annotation in annotations
                {
                    self.mapView.removeAnnotation(annotation)
                }
                
                // Creating the coordinate
                let lon = response?.boundingRegion.center.longitude
                let lat = response?.boundingRegion.center.latitude
                let searchedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: lat!, longitude: lon!)
                
                // Create the placemark
                let placemark: MKPlacemark = (response?.mapItems.first?.placemark)!
                
                // <-------- REMOVE LATER!!!!!!!!!!!!! -------->
                print(placemark.title)
                
                // Create annotation
                let annotation = MKPointAnnotation()
//                annotation.title = searchBar.text
                annotation.title = placemark.title
                annotation.coordinate = searchedCoordinate
                self.mapView.addAnnotation(annotation)
                
                // Zooming in on location
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let region = MKCoordinateRegion(center: searchedCoordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                
                // Show Add location Button
                self.addLocationButton.setTitle("Add " + placemark.title!, for: .normal)
                self.addLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
                self.addLocationButton.isHidden = false
                
                
                
                // <-------- REMOVE LATER!!!!!!!!!!!!! -------->
                print(lon)
                print(lat)
                
            }
        }
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func addLocationButton(_ sender: Any) {
        // Do stuff when clicked.
        CentralManager.shared.addFavoriteLocation(name: "test", longitude: 14.158, latitude: 57.781)
        navigationController?.popViewController(animated:true)
    }
    
}

extension LocationViewController: CLLocationManagerDelegate {
    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.requestLocation()
//        }
//    }
//
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            print("location:: (location)")
//        }
//    }
//
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("error:: (error)")
//    }
    
}
