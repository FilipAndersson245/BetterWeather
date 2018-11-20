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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Ignoring User
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Actitity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
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
                // Remove anotations
//                let annotations = self.mapView.annotations
//                self.mapView.removeAnnotation(annotations)
                
//                self.mapView.removeAnnotation(self.mapView?.annotations as! MKAnnotation)
                
                // Getting data
                let lon = response?.boundingRegion.center.longitude
                let lat = response?.boundingRegion.center.latitude
                
                // Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(lat!, lon!)
                self.mapView.addAnnotation(annotation)
                
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
    
    
}
