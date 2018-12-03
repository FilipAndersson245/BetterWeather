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
    
    
    @IBOutlet var mapMainView: UIView!
    
    
    @IBOutlet var mapSearchSubView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let searchController = UISearchController(searchResultsController: nil)

    var lon: CLLocationDegrees = 0.0
    var lat: CLLocationDegrees = 0.0
    var name: String = ""
    
    var filteredMapItems: [MKMapItem]  = []
    var unfilteredMapItems: [MKMapItem] = []
    
    
    // Testing Stuff

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set searchbar deligate
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        
        // Setuo addLocationButton styling
        addLocationButton.layer.cornerRadius = 5
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = self.view.tintColor.cgColor
        addLocationButton.titleLabel?.textColor = self.view.tintColor
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        addSearchView()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Create search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            self.removeSearchView()
            
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        removeSearchView()
    }
    
    func addSearchView () {
        view.addSubview(mapSearchSubView)
    }
    
    func removeSearchView () {
        mapSearchSubView.removeFromSuperview()
    }
    
    
    @IBAction func addLocationButtonClicked(_ sender: Any) {
        
    }
    
    
    
    
}

