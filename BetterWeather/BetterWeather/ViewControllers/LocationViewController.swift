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
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var addLocationButton: UIButton!
    
    @IBOutlet var mapMainView: UIView!
    
    @IBOutlet var mapSearchSubView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchTable: UITableView!
    
    // MARK: - Properties
    
    var lon: CLLocationDegrees = 0.0
    
    var lat: CLLocationDegrees = 0.0
    
    var locationName: String = ""
    
    var searchedPlacemark: MKPlacemark? = nil
    
    var filteredMapItems: [MKMapItem]  = []
    
    // MARK: - View status methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchTable.tableFooterView = UIView()
        searchTable.backgroundColor = UIColor.clear
        addLocationButton.layer.cornerRadius = 5
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = self.view.tintColor.cgColor
        addLocationButton.titleLabel?.textColor = self.view.tintColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addSearchView()
    }
    
    override func viewDidLayoutSubviews() {
        mapSearchSubView.frame = self.view.frame
    }
    
    // MARK: - Action methods
    
    @IBAction func searchButton(_ sender: Any) {
        addSearchView()
    }
    
    @IBAction func addLocationButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        CentralManager.shared.addFavoriteLocation(name: self.locationName, longitude: Float(self.lon), latitude: Float(self.lat))
    }
    
    // MARK: - Table view delegate data source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! SearchResultTableViewCell
        cell.title.text = filteredMapItems[indexPath.row].placemark.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = filteredMapItems[indexPath.row].placemark.title
        completeSearch(searchRequest: searchRequest)
    }
    
    // MARK: - Search bar delegate methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !(searchBar.text == nil || searchBar.text == "") {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchBar.text
            
            let activeSearch = MKLocalSearch(request: searchRequest)
            
            activeSearch.start { (response, error) in
                self.filteredMapItems = (response?.mapItems ?? [])!
                self.searchTable.reloadData()
            }
        }
        else {
            filteredMapItems.removeAll()
            self.searchTable.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        completeSearch(searchRequest: searchRequest)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSearchView()
    }
    
    // MARK: - Helper methods
    
    func addSearchView () {
        self.filteredMapItems.removeAll()
        self.searchBar.text = ""
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.addSubview(mapSearchSubView)
        self.searchBar.becomeFirstResponder()
    }
    
    func removeSearchView () {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mapSearchSubView.removeFromSuperview()
        filteredMapItems.removeAll()
        searchBar.text?.removeAll()
        self.searchTable.reloadData()
    }
    
    func completeSearch (searchRequest: MKLocalSearch.Request) {
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            self.removeSearchView()
            if response != nil {
                let annotations = self.mapView.annotations
                for annotation in annotations {
                    self.mapView.removeAnnotation(annotation)
                }
                
                let lon = response?.boundingRegion.center.longitude
                let lat = response?.boundingRegion.center.latitude
                let searchedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: lat!, longitude: lon!)
                self.searchedPlacemark = (response?.mapItems.first?.placemark)!
                
                let annotation = MKPointAnnotation()
                annotation.title = self.searchedPlacemark!.title
                annotation.coordinate = searchedCoordinate
                self.mapView.addAnnotation(annotation)
                
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let region = MKCoordinateRegion(center: searchedCoordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.makeGenerallCoordinates(coord: searchedCoordinate)
                
                self.addLocationButton.setTitle("Add " + (self.searchedPlacemark?.locality != nil ? (self.searchedPlacemark?.locality!)! : (self.searchedPlacemark?.country!)!), for: .normal)
                self.addLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
                self.addLocationButton.isHidden = false
            }
        }
    }
    
    func makeGenerallCoordinates (coord: CLLocationCoordinate2D) {
        let searchRequest = MKLocalSearch.Request()
        
        searchRequest.naturalLanguageQuery = self.searchedPlacemark?.locality != nil ? (self.searchedPlacemark?.locality!)! : (self.searchedPlacemark?.country!)!
        searchRequest.region = MKCoordinateRegion(center: coord, latitudinalMeters: CLLocationDistance(exactly: 10000)!, longitudinalMeters: CLLocationDistance(exactly: 10000)!)
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            if response != nil {
                self.locationName = self.searchedPlacemark?.locality != nil ? (self.searchedPlacemark?.locality!)! : (self.searchedPlacemark?.country!)!
                self.lon = (response?.mapItems.first?.placemark.coordinate.longitude)!
                self.lat = (response?.mapItems.first?.placemark.coordinate.latitude)!
            }
        }
    }
}
