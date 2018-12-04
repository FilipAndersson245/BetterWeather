//
//  LocationViewController.swift
//  BetterWeather
//
//  Created by Marcus Gullstrand on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    @IBOutlet var mapMainView: UIView!
    
    @IBOutlet var mapSearchSubView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    

    var lon: CLLocationDegrees = 0.0
    var lat: CLLocationDegrees = 0.0
    var locationName: String = ""
    var searchedPlacemark: MKPlacemark? = nil
    
    var filteredMapItems: [MKMapItem]  = []
//    var unfilteredMapItems: [MKMapItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set searchbar deligate
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        
        // Fix tableView (remove empty cells)
//        searchTable.tableFooterView = UIView()
        
        // Setuo addLocationButton styling
        addLocationButton.layer.cornerRadius = 5
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = self.view.tintColor.cgColor
        addLocationButton.titleLabel?.textColor = self.view.tintColor
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        addSearchView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !(searchBar.text == nil || searchBar.text == "") {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchBar.text
            
            let activeSearch = MKLocalSearch(request: searchRequest)
            
            activeSearch.start { (response, error) in
                
                // Create the placemark
                self.filteredMapItems = (response?.mapItems ?? [])!
                
                print("##")
                print(self.filteredMapItems.count)
                
                DispatchQueue.main.async {
                    self.searchTable.reloadData()
                }
            }
        }
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
                self.searchedPlacemark = (response?.mapItems.first?.placemark)!
            
                // Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.searchedPlacemark!.title
                annotation.coordinate = searchedCoordinate
                self.mapView.addAnnotation(annotation)
                
                // Zooming in on location
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let region = MKCoordinateRegion(center: searchedCoordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                // Make generall coordinate
                self.makeGenerallCoordinates(search: (self.searchedPlacemark?.locality)!, coord: searchedCoordinate)
                
                // Show Add location Button
                self.addLocationButton.setTitle("Add " + self.searchedPlacemark!.locality!, for: .normal)
                self.addLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
                self.addLocationButton.isHidden = false
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSearchView()
    }
    
    func addSearchView () {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.addSubview(mapSearchSubView)
        
        
    }
    
    func removeSearchView () {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mapSearchSubView.removeFromSuperview()
    }
    
    // #######################################################
    // #######################################################
    // #######################################################
    // TABLE FUNCTIONS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count")
        print(filteredMapItems.count)
        return filteredMapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SearchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! SearchResultTableViewCell
        cell.title.text = filteredMapItems[indexPath.row].placemark.title
        
        print("#####")
        print(filteredMapItems.count)
        
        
        return cell
    }
    
    
    
    
    
    @IBAction func addLocationButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        CentralManager.shared.addFavoriteLocation(name: self.locationName, longitude: Float(self.lon), latitude: Float(self.lat))
    }
    
    func makeGenerallCoordinates (search: String, coord: CLLocationCoordinate2D) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = search
        searchRequest.region = MKCoordinateRegion(center: coord, latitudinalMeters: CLLocationDistance(exactly: 10000)!, longitudinalMeters: CLLocationDistance(exactly: 10000)!)
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            if response == nil
            {
                // PUT ERROR HANDLING HERE
                print("ERROR")
            }
            else
            {
                self.locationName = (self.searchedPlacemark?.locality!)!
                self.lon = (response?.mapItems.first?.placemark.coordinate.longitude)!
                self.lat = (response?.mapItems.first?.placemark.coordinate.latitude)!
            }
        }
    }
    
    
    
}

