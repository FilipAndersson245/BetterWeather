//
//  LocationViewController.swift
//  BetterWeather
//
//  Created by Marcus Gullstrand on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    @IBOutlet var mapMainView: UIView!
    
    @IBOutlet var mapSearchSubView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultTable: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var lon: CLLocationDegrees = 0.0
    var lat: CLLocationDegrees = 0.0
    var name: String = ""
    
    var filteredMapItems: [MKMapItem]  = []
    var unfilteredMapItems: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setuo addLocationButton styling
        addLocationButton.layer.cornerRadius = 5
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = self.view.tintColor.cgColor
        addLocationButton.titleLabel?.textColor = self.view.tintColor
        
        // Setup for the searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
//        navigationItem.searchController = searchController
//        definesPresentationContext = true

        // Setup UITableView for the searchbar
        mapSearchSubView = UIView.init()
        self.mapMainView.addSubview(mapSearchSubView)
//        self.view.addSubview(mapSearchSubView)
    }
    
    func tableView(resultTable: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    @IBAction func searchButton(_ sender: Any) {
//        searchController.searchBar.delegate = self
//        present(searchController, animated: true, completion: nil)
//        performSegue(withIdentifier: "MapSearchSegue", sender: self)
        
//        self.view.addSubview(mapSearchSubView)
        
        mapSearchSubView.bringSubviewToFront(mapMainView)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMapItems = unfilteredMapItems.filter({( mapItem : MKMapItem) -> Bool in
            return (mapItem.placemark.title?.lowercased().contains(searchText.lowercased()))!
        })
        
        
//        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
//        return searchController.isActive && !searchBarIsEmpty()
        return searchController.isActive && (!(searchController.searchBar.text?.isEmpty)!)
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
                self.lon = (response?.boundingRegion.center.longitude)!
                self.lat = (response?.boundingRegion.center.latitude)!
                let searchedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: self.lat, longitude: self.lon)
                
                // Create the placemark
                let placemark: MKPlacemark = (response?.mapItems.first?.placemark)!
                self.name = placemark.title!
                
                // Create annotation
                let annotation = MKPointAnnotation()
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
            }
        }
    }
    
    @IBAction func addLocationButton(_ sender: Any) {
        CentralManager.shared.addFavoriteLocation(name: self.name, longitude: Float(self.lon), latitude: Float(self.lat))
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
