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
    @IBOutlet weak var searchResultTableView: UITableView!
    
    
    let searchController = UISearchController(searchResultsController: nil)
//    var topBarIsHidden: Bool = false
    
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
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        
        view.addSubview(mapSearchSubView)
    
    }
    
}

